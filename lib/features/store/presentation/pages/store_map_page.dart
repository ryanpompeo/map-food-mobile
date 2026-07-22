import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/route_service.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

/// Tela cheia com o mapa focado numa única loja — destino do botão
/// "Visualizar no mapa" na tela de detalhe. Mostra a posição atual do
/// usuário, traça a rota a pé até a loja (OSRM; linha reta como fallback)
/// e exibe a distância.
class StoreMapPage extends StatefulWidget {
  final StoreDto store;

  const StoreMapPage({super.key, required this.store});

  @override
  State<StoreMapPage> createState() => _StoreMapPageState();
}

class _StoreMapPageState extends State<StoreMapPage> {
  final _routeService = RouteService();

  final ValueNotifier<LatLng?> _userPosition = ValueNotifier(null);
  List<LatLng>? _routePoints;
  double? _distanciaMetros;
  bool _carregandoRota = false;
  bool _semPermissao = false;

  @override
  void initState() {
    super.initState();
    _carregarPosicaoERota();
  }

  @override
  void dispose() {
    _userPosition.dispose();
    super.dispose();
  }

  Future<void> _carregarPosicaoERota() async {
    if (!widget.store.temLocalizacao) return;

    setState(() => _carregandoRota = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _semPermissao = true;
            _carregandoRota = false;
          });
        }
        return;
      }

      final destino = LatLng(widget.store.latitude!, widget.store.longitude!);

      // `getCurrentPosition` espera um fix "fresco" de GPS — isso, e não o
      // cálculo da rota em si, é o que demora (às vezes vários segundos),
      // mesmo quando a rota já está no cache do RouteService. Por isso, se
      // já existe uma última posição conhecida (leitura instantânea, sem
      // esperar o hardware), traça a rota com ela primeiro — na prática cai
      // direto no cache quando é a mesma loja de uma visita recente — e só
      // depois refina com a posição atual.
      final ultimaConhecida = await Geolocator.getLastKnownPosition();
      if (ultimaConhecida != null && mounted) {
        await _tracarRotaPara(LatLng(ultimaConhecida.latitude, ultimaConhecida.longitude), destino);
      }

      final posicaoAtual = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;
      await _tracarRotaPara(LatLng(posicaoAtual.latitude, posicaoAtual.longitude), destino);
    } catch (_) {
      if (mounted) setState(() => _carregandoRota = false);
    }
  }

  /// Busca (ou pega do cache) a rota entre [origem] e [destino] e atualiza o
  /// estado da tela. Chamado até duas vezes por carregamento — uma vez
  /// (opcional) com a última posição conhecida, pra sentir instantâneo, e
  /// outra com o fix atual do GPS, pra corrigir caso o usuário tenha andado.
  Future<void> _tracarRotaPara(LatLng origem, LatLng destino) async {
    final rota = await _routeService.getRoute(origem, destino);
    if (!mounted) return;
    _userPosition.value = origem;
    setState(() {
      if (rota != null) {
        _routePoints = rota.pontos;
        _distanciaMetros = rota.distanciaMetros;
      } else {
        // OSRM indisponível — linha reta como fallback.
        _routePoints = [origem, destino];
        _distanciaMetros = const Distance().as(LengthUnit.Meter, origem, destino);
      }
      _carregandoRota = false;
    });
  }

  String get _distanciaLabel {
    final metros = _distanciaMetros;
    if (metros == null) return '';
    if (metros < 1000) return '≈ ${metros.round()} m';
    return '≈ ${(metros / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasUnsavedChanges: _carregandoRota,
      confirmDialog: confirmarSairDuranteCalculoDeRota,
      child: Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        backgroundColor: context.mapColors.mainBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          // maybePop (não pop) consulta o PopScope do UnsavedChangesGuard
          // antes de sair — Navigator.pop força a saída e só avisa o guard
          // depois de já ter saído, então o diálogo nunca chegava a aparecer
          // pelo botão visual (só pelo gesto/botão físico de voltar).
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(PhosphorIconsRegular.caretLeft, color: ColorsPalette.redComponents),
        ),
        title: Text(
          widget.store.nome,
          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText),
        ),
      ),
      body: Stack(
        children: [
          StoreMapView(
            stores: [widget.store],
            focusedStore: widget.store,
            userPosition: _userPosition,
            routePoints: _routePoints,
          ),
          if (_carregandoRota)
            Positioned(
              bottom: 24.0,
              left: 0,
              right: 0,
              child: Center(child: _buildPill(child: _buildPillLoading())),
            )
          else if (_distanciaMetros != null)
            Positioned(
              bottom: 24.0,
              left: 0,
              right: 0,
              child: Center(
                child: _buildPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.footprints, size: 16.0, color: ColorsPalette.redComponents),
                      const SizedBox(width: 6.0),
                      Text(
                        _distanciaLabel,
                        style: AppText.legenda(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.mapColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_semPermissao)
            Positioned(
              bottom: 24.0,
              left: 24.0,
              right: 24.0,
              child: Center(
                child: _buildPill(
                  child: Text(
                    "Ative a localização para traçar a rota até a loja",
                    textAlign: TextAlign.center,
                    // Sem override de cor: legenda() já resolve pra secondaryText.
                    style: AppText.legenda(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        // Elemento flutuante sobre o mapa — cardSurface (Lote 4B).
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(100.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPillLoading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 14.0,
          height: 14.0,
          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsPalette.redComponents),
        ),
        const SizedBox(width: 8.0),
        Text(
          "Traçando rota...",
          // Sem override de cor: legenda() já resolve pra secondaryText.
          style: AppText.legenda(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
