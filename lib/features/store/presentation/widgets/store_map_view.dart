import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

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

  /// Posição do usuário — desenha o marker "minha posição" (bolinha azul).
  final double? userLatitude;
  final double? userLongitude;

  /// Traçado de rota (ex: usuário → loja no "Visualizar no mapa"),
  /// desenhado sob os markers.
  final List<LatLng>? routePoints;

  /// Espaço reservado abaixo dos botões flutuantes de câmera (centralizar /
  /// travar rotação), pra não ficarem escondidos atrás de bottom bars ou
  /// pills que ficam por cima do mapa em algumas telas.
  final double floatingControlsBottomPadding;

  const StoreMapView({
    super.key,
    required this.stores,
    this.focusedStore,
    this.initialLatitude,
    this.initialLongitude,
    this.userLatitude,
    this.userLongitude,
    this.routePoints,
    this.floatingControlsBottomPadding = 16.0,
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

  LatLng? _centroRastreadoAnterior;
  bool _rotacaoTravada = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Centro que o mapa deve seguir, na mesma ordem de prioridade usada
  /// pra escolher o centro inicial. Null quando não há nada a seguir
  /// (câmera fica livre pro usuário).
  LatLng? get _centroRastreado {
    final focused = widget.focusedStore;
    if (focused != null && focused.temLocalizacao) {
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
    if (widget.userLatitude == null || widget.userLongitude == null) return;
    final zoomAtual = _mapController.camera.zoom;
    _mapController.move(
      LatLng(widget.userLatitude!, widget.userLongitude!),
      zoomAtual < 15.0 ? 16.0 : zoomAtual,
    );
  }

  /// Alterna o travamento de rotação do mapa. Ao travar, alinha o mapa de
  /// volta pro norte — não faz sentido travar "torto".
  void _alternarTravaDeRotacao() {
    setState(() => _rotacaoTravada = !_rotacaoTravada);
    if (_rotacaoTravada) _mapController.rotate(0);
  }

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
        LucideIcons.store,
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
    return Positioned(
      right: AppSpacing.md,
      bottom: widget.floatingControlsBottomPadding,
      child: Column(
        children: [
          if (widget.userLatitude != null && widget.userLongitude != null) ...[
            _MapControlButton(
              icon: LucideIcons.locate,
              tooltip: 'Centralizar na minha posição',
              onTap: _centralizarNaMinhaPosicao,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _MapControlButton(
            icon: _rotacaoTravada ? LucideIcons.lock : LucideIcons.compass,
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
            MarkerLayer(
              markers: [
                if (widget.userLatitude != null && widget.userLongitude != null)
                  Marker(
                    point: LatLng(widget.userLatitude!, widget.userLongitude!),
                    width: 22.0,
                    height: 22.0,
                    child: _buildUserMarker(),
                  ),
                ...comLocalizacao.map((store) {
                  final isFocused = widget.focusedStore?.id == store.id;
                  return Marker(
                    point: LatLng(store.latitude!, store.longitude!),
                    width: isFocused ? 60.0 : 48.0,
                    height: isFocused ? 60.0 : 48.0,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MoreInfoStorePage(store: store)),
                      ),
                      child: _buildStoreMarker(store, isFocused: isFocused),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        _buildFloatingControls(),
        if (comLocalizacao.isEmpty)
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                "Nenhuma loja com localização cadastrada por aqui ainda",
                textAlign: TextAlign.center,
                style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}

/// Botão flutuante circular usado pelos controles de câmera do mapa
/// (centralizar / travar rotação) — mesmo visual dos "pills" de vidro já
/// usados em outros lugares do app, só que circular.
class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? ColorsPalette.redComponents : Colors.white,
        shape: const CircleBorder(),
        elevation: 3.0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              icon,
              size: AppIconSize.md,
              color: isActive ? Colors.white : ColorsPalette.black,
            ),
          ),
        ),
      ),
    );
  }
}
