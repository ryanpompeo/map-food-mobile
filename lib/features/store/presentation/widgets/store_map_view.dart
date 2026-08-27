import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';
import 'package:map_food/features/store/presentation/widgets/map_controls.dart';

/// Mapa com pins das lojas, reaproveitado na home (guest/consumer) e no
/// botão "Visualizar no mapa" da tela de detalhe de uma loja. Lojas sem
/// latitude/longitude (cadastradas antes dessa feature existir, ou com
/// endereço que o geocoding não conseguiu resolver) são ignoradas.
///
/// A câmera segue o centro rastreado (loja em foco ou posição do usuário):
/// quando ele muda entre rebuilds — ex: novo fix de GPS da NearbyStoresSection
/// ou da ronda do comerciante — o mapa recentraliza preservando o zoom que o
/// usuário ajustou manualmente. `MapOptions.initialCenter` sozinho não faz
/// isso, pois o flutter_map só o lê no primeiro build.
class StoreMapView extends StatefulWidget {
  final List<StoreDto> stores;
  final StoreDto? focusedStore;
  final double? initialLatitude;
  final double? initialLongitude;

  /// Posição "ao vivo" do usuário — desenha o marker "minha posição" (bolinha
  /// azul) num MarkerLayer isolado via ValueListenableBuilder. Propositalmente
  /// um ValueListenable em vez de double/double: assim, quem alimenta isso a
  /// cada tick de GPS (ex: NearbyStoresSection) atualiza só esse marcador,
  /// sem reconstruir StoreMapView inteiro nem os marcadores das lojas.
  final ValueListenable<LatLng?>? userPosition;

  /// Traçado de rota (ex: usuário → loja no "Visualizar no mapa"),
  /// desenhado sob os markers.
  final List<LatLng>? routePoints;

  /// Espaço reservado abaixo dos botões flutuantes de câmera (centralizar /
  /// travar rotação), pra não ficarem escondidos atrás de bottom bars ou
  /// pills que ficam por cima do mapa em algumas telas.
  final double floatingControlsBottomPadding;

  /// Distância do topo pro banner de "sem lojas com localização" — precisa
  /// crescer quando há uma busca/filtro flutuante por cima do mapa, senão o
  /// banner nasce embaixo desses controles.
  final double topBannerOffset;

  /// Comando externo da câmera (ver [StoreMapController]). A home usa para
  /// focar um pin acima do sheet e para o botão de recentralizar, que lá vive
  /// fora do mapa.
  final StoreMapController? controller;

  /// Toque num pin. `null` mantém o comportamento padrão — abrir a tela da
  /// loja —, que é o certo nas telas onde o mapa é a única coisa na tela.
  final ValueChanged<StoreDto>? onStoreTap;

  /// Desliga os botões de câmera internos. A home desenha os seus, ancorados
  /// acima da bottom bar flutuante do app.
  final bool showFloatingControls;

  /// Banner de "nenhuma loja com localização por aqui". Desligado na home,
  /// onde ele colidia com a barra de busca flutuante.
  final bool showEmptyBanner;

  const StoreMapView({
    super.key,
    required this.stores,
    this.focusedStore,
    this.initialLatitude,
    this.initialLongitude,
    this.userPosition,
    this.routePoints,
    this.floatingControlsBottomPadding = 16.0,
    this.topBannerOffset = 16.0,
    this.controller,
    this.onStoreTap,
    this.showFloatingControls = true,
    this.showEmptyBanner = true,
  });

  @override
  State<StoreMapView> createState() => _StoreMapViewState();
}

class _StoreMapViewState extends State<StoreMapView> {
  // Fallback quando não há localização do usuário nem lojas com pin —
  // evita renderizar o mapa centralizado em (0,0), no meio do oceano.
  static const _fallbackCenter = LatLng(-22.9068, -43.1729);

  // Só recentraliza se o centro rastreado andou mais que isso — evita
  // micro-movimentos de ruído de GPS mexendo na câmera o tempo todo.
  static const double _limiarRecentralizarMetros = 10.0;

  final MapController _mapController = MapController();
  static const Distance _distance = Distance();

  /// Controller da tela quando ela fornece um; senão, um próprio. Ter sempre
  /// um evita duplicar aqui dentro o estado de zoom/rotação que ele já
  /// guarda — os controles de zoom precisam desse estado tanto na home (onde
  /// vivem fora do mapa) quanto nas telas que usam os botões internos.
  late final StoreMapController _ctrl;

  /// `true` quando o controller nasceu aqui — só nesse caso ele é descartado
  /// aqui; o da tela pertence a quem o criou.
  late final bool _ctrlProprio;

  LatLng? _centroRastreadoAnterior;
  bool _rotacaoTravada = false;

  @override
  void dispose() {
    _ctrl.rotacaoTravada.removeListener(_onRotacaoExternaMudou);
    _ctrl.detach();
    if (_ctrlProprio) _ctrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Centro que o mapa deve seguir, na mesma ordem de prioridade usada
  /// pra escolher o centro inicial. Null quando não há nada a seguir
  /// (câmera fica livre pro usuário).
  LatLng? get _centroRastreado {
    final focused = widget.focusedStore;
    // Com controller externo, quem enquadra o foco é a tela — ela precisa
    // deslocar o alvo para cima do sheet, e centralizar aqui desfaria isso.
    if (widget.controller == null && focused != null && focused.temLocalizacao) {
      return LatLng(focused.latitude!, focused.longitude!);
    }
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      return LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
    return null;
  }

  (LatLng, double) _centroEZoomIniciais() {
    final comLocalizacao = widget.stores.where((s) => s.temLocalizacao).toList();
    final rastreado = _centroRastreado;

    if (widget.focusedStore != null && widget.focusedStore!.temLocalizacao) {
      return (rastreado!, 16.0);
    }
    if (rastreado != null) {
      return (rastreado, 14.0);
    }
    if (comLocalizacao.isNotEmpty) {
      return (LatLng(comLocalizacao.first.latitude!, comLocalizacao.first.longitude!), 13.0);
    }
    return (_fallbackCenter, 12.0);
  }

  @override
  void initState() {
    super.initState();
    _centroRastreadoAnterior = _centroRastreado;
    _ctrlProprio = widget.controller == null;
    _ctrl = widget.controller ?? StoreMapController();
    _ctrl.attach(_mapController);
    _ctrl.zoom.value = _centroEZoomIniciais().$2;
    // Com controller externo, quem alterna a trava é o botão da tela (fora
    // do mapa) — este listener traz a decisão de volta para cá, que é onde
    // as `interactionOptions` do FlutterMap são montadas.
    _ctrl.rotacaoTravada.addListener(_onRotacaoExternaMudou);
  }

  void _onRotacaoExternaMudou() {
    final travada = _ctrl.rotacaoTravada.value;
    if (travada != _rotacaoTravada && mounted) {
      setState(() => _rotacaoTravada = travada);
    }
  }

  @override
  void didUpdateWidget(StoreMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Quando uma rota chega (ex: usuário → loja no "Visualizar no mapa"),
    // enquadra o traçado inteiro — mostrar só a loja cortaria o caminho.
    final rota = widget.routePoints;
    if (rota != null && rota.length >= 2 && oldWidget.routePoints != rota) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(rota),
          padding: const EdgeInsets.all(48.0),
        ),
      );
      return;
    }

    final novoCentro = _centroRastreado;
    if (novoCentro == null) return;

    final anterior = _centroRastreadoAnterior;
    if (anterior == null ||
        _distance.as(LengthUnit.Meter, anterior, novoCentro) > _limiarRecentralizarMetros) {
      _centroRastreadoAnterior = novoCentro;
      // Move só o centro, preservando o zoom atual escolhido pelo usuário.
      _mapController.move(novoCentro, _mapController.camera.zoom);
    }
  }

  /// Centraliza a câmera na posição atual do usuário (estilo Uber), mantendo
  /// o zoom atual — ou um zoom mínimo de "rua" se o usuário estiver com o
  /// mapa muito distante.
  void _centralizarNaMinhaPosicao() {
    final pos = widget.userPosition?.value;
    if (pos == null) return;
    final zoomAtual = _mapController.camera.zoom;
    _mapController.move(pos, zoomAtual < 15.0 ? 16.0 : zoomAtual);
  }

  /// Alterna o travamento de rotação do mapa. Delega ao controller (que
  /// alinha de volta pro norte ao travar) e deixa o `_onRotacaoExternaMudou`
  /// devolver o novo valor — assim o botão interno e o da tela nunca ficam
  /// contando histórias diferentes sobre o mesmo mapa.
  void _alternarTravaDeRotacao() => _ctrl.alternarTravaDeRotacao();

  /// Pin de loja: círculo com borda branca contendo a foto do comércio —
  /// cai pro ícone padrão (fundo vermelho) se não houver foto ou a imagem
  /// falhar ao carregar. A loja em foco fica maior e com borda mais grossa.
  Widget _buildStoreMarker(StoreDto store, {required bool isFocused}) {
    final imagemUrl = resolveImagemUrl(store.capaUrl);
    final tamanho = isFocused ? 52.0 : 42.0;

    return RepaintBoundary(
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: isFocused ? 3.5 : 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isFocused ? 0.3 : 0.18),
              blurRadius: isFocused ? 10.0 : 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: imagemUrl != null
              ? Image.network(
                  imagemUrl,
                  fit: BoxFit.cover,
                  // Decorativa: o marcador em si (fora do escopo deste
                  // widget) já tem o nome da loja acessível na tela de
                  // detalhe pra onde ele navega ao ser tocado.
                  excludeFromSemantics: true,
                  // Marcador é um círculo de 42-52dp — sem isso, cada pin no
                  // mapa decodificava a foto inteira da loja, pesando muito
                  // no pan/zoom quando há vários marcadores com foto na tela.
                  // Só cacheWidth: com os dois definidos o decoder ignora a
                  // proporção original e estica a imagem.
                  cacheWidth: (tamanho * MediaQuery.devicePixelRatioOf(context)).round(),
                  errorBuilder: (context, error, stackTrace) => _buildStoreMarkerFallback(isFocused),
                )
              : _buildStoreMarkerFallback(isFocused),
        ),
      ),
    );
  }

  Widget _buildStoreMarkerFallback(bool isFocused) {
    return Container(
      color: isFocused ? ColorsPalette.redComponents : ColorsPalette.redComponents.withValues(alpha: 0.12),
      child: Icon(
        AppIcons.storefront,
        color: isFocused ? Colors.white : ColorsPalette.redComponents,
        size: isFocused ? 24.0 : 18.0,
      ),
    );
  }

  /// Marker "minha posição": bolinha azul com borda branca, padrão de mapas.
  Widget _buildUserMarker() {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2979FF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingControls() {
    final userPosition = widget.userPosition;
    return Positioned(
      right: AppSpacing.md,
      bottom: widget.floatingControlsBottomPadding,
      child: Column(
        children: [
          // Zoom no topo da pilha: é o controle usado com mais frequência, e
          // aqui fica o mais longe da borda inferior, onde o polegar alcança
          // com menos esforço em telas grandes.
          MapZoomControls(controller: _ctrl),
          const SizedBox(height: AppSpacing.sm),
          // Botão "Centralizar" só existe se há um ValueListenable de posição
          // — reconstrói só este pedaço pequeno (não o mapa inteiro) quando a
          // posição chega pela primeira vez ou muda.
          if (userPosition != null)
            ValueListenableBuilder<LatLng?>(
              valueListenable: userPosition,
              builder: (context, pos, _) {
                if (pos == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    MapControlButton(
                      icon: AppIcons.gpsFix,
                      tooltip: 'Centralizar na minha posição',
                      onTap: _centralizarNaMinhaPosicao,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                );
              },
            ),
          MapControlButton(
            icon: _rotacaoTravada ? AppIcons.lock : AppIcons.compass,
            tooltip: _rotacaoTravada ? 'Destravar rotação do mapa' : 'Travar rotação do mapa',
            isActive: _rotacaoTravada,
            onTap: _alternarTravaDeRotacao,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comLocalizacao = widget.stores.where((s) => s.temLocalizacao).toList();
    final (center, zoom) = _centroEZoomIniciais();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            // Mesmos limites dos botões de ampliar/reduzir: pinça e botão
            // param no mesmo lugar.
            minZoom: StoreMapController.zoomMinimo,
            maxZoom: StoreMapController.zoomMaximo,
            // Realimenta o zoom do controller a cada movimento. Só atualiza um
            // ValueNotifier — os botões de zoom reconstroem sozinhos, o mapa
            // não é reconstruído junto.
            onMapEvent: (evento) => _ctrl.zoom.value = evento.camera.zoom,
            interactionOptions: InteractionOptions(
              flags: _rotacaoTravada ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.map_food',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
            if (widget.routePoints != null && widget.routePoints!.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints!,
                    color: ColorsPalette.redComponents,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            // Marcadores de loja num MarkerLayer próprio — só reconstrói
            // quando `stores`/`focusedStore` mudam (ou seja, quando
            // StoreMapView.build() roda de novo), não a cada tick de GPS.
            MarkerLayer(
              markers: comLocalizacao.map((store) {
                final isFocused = widget.focusedStore?.id == store.id;
                return Marker(
                  point: LatLng(store.latitude!, store.longitude!),
                  width: isFocused ? 60.0 : 48.0,
                  height: isFocused ? 60.0 : 48.0,
                  // SemanticTapArea, e não GestureDetector cru: sem o nó de
                  // semântica os pins são o único conteúdo do mapa e ficavam
                  // invisíveis ao leitor de tela — quem não enxerga não tinha
                  // como saber que havia comércios ali, nem como abri-los.
                  child: SemanticTapArea(
                    label: store.nome,
                    hint: 'Abre os detalhes do comércio',
                    selected: isFocused ? true : null,
                    // O pin já cresce quando está em foco e é pequeno demais
                    // para comportar escala de pressão sem tremer.
                    pressFeedback: false,
                    onTap: () {
                      final onTap = widget.onStoreTap;
                      if (onTap != null) {
                        onTap(store);
                        return;
                      }
                      Navigator.push(
                        context,
                        appPageRoute(builder: (_) => MoreInfoStorePage(store: store)),
                      );
                    },
                    child: _buildStoreMarker(store, isFocused: isFocused),
                  ),
                );
              }).toList(),
            ),
            // Marcador "minha posição" isolado num MarkerLayer próprio,
            // dentro de um ValueListenableBuilder: cada tick de GPS reconstrói
            // só esta bolinha azul, sem tocar no MarkerLayer das lojas acima
            // nem em StoreMapView.build() como um todo.
            if (widget.userPosition != null)
              ValueListenableBuilder<LatLng?>(
                valueListenable: widget.userPosition!,
                builder: (context, pos, _) {
                  return MarkerLayer(
                    markers: pos == null
                        ? const []
                        : [
                            Marker(
                              point: pos,
                              width: 22.0,
                              height: 22.0,
                              child: _buildUserMarker(),
                            ),
                          ],
                  );
                },
              ),
          ],
        ),
        if (widget.showFloatingControls) _buildFloatingControls(),
        if (comLocalizacao.isEmpty && widget.showEmptyBanner)
          Positioned(
            top: widget.topBannerOffset,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                // Elemento flutuante sobre o mapa — cardSurface (Lote 4B).
                color: context.mapColors.cardSurface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                "Nenhuma loja com localização cadastrada por aqui ainda",
                textAlign: TextAlign.center,
                // Sem override de cor: legenda() já resolve pra secondaryText.
                style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}

// O botão flutuante dos controles de câmera virou `MapControlButton`, em
// `map_controls.dart` — a home desenhava um clone dele, e as duas cópias já
// tinham divergido em tamanho de alvo (40 aqui, 48 lá) e em superfície.
