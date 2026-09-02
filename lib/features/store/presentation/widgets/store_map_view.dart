import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/ui/theme/map_tiles.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';
import 'package:map_food/features/store/presentation/widgets/map_controls.dart';

class StoreMapView extends StatefulWidget {
  final List<StoreDto> stores;
  final StoreDto? focusedStore;
  final double? initialLatitude;
  final double? initialLongitude;

  final ValueListenable<LatLng?>? userPosition;

  final List<LatLng>? routePoints;

  final double floatingControlsBottomPadding;

  final double topBannerOffset;

  final StoreMapController? controller;

  final ValueChanged<StoreDto>? onStoreTap;

  final bool showFloatingControls;

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
  static const _fallbackCenter = LatLng(-22.9068, -43.1729);

  static const double _limiarRecentralizarMetros = 10.0;

  final MapController _mapController = MapController();
  static const Distance _distance = Distance();

  late final StoreMapController _ctrl;

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

  LatLng? get _centroRastreado {
    final focused = widget.focusedStore;
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
      _mapController.move(novoCentro, _mapController.camera.zoom);
    }
  }

  void _centralizarNaMinhaPosicao() {
    final pos = widget.userPosition?.value;
    if (pos == null) return;
    final zoomAtual = _mapController.camera.zoom;
    _mapController.move(pos, zoomAtual < 15.0 ? 16.0 : zoomAtual);
  }

  void _alternarTravaDeRotacao() => _ctrl.alternarTravaDeRotacao();

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
          child: AppNetworkImage(
            path: imagemUrl,
            displayWidth: tamanho,
            fallback: _buildStoreMarkerFallback(isFocused),
          ),
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

  Widget _buildUserMarker() {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: MfColor.userDot,
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
          MapZoomControls(controller: _ctrl),
          const SizedBox(height: AppSpacing.sm),
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
            minZoom: StoreMapController.zoomMinimo,
            maxZoom: StoreMapController.zoomMaximo,
            onMapEvent: (evento) => _ctrl.zoom.value = evento.camera.zoom,
            interactionOptions: InteractionOptions(
              flags: _rotacaoTravada ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.all,
            ),
          ),
          children: [
            MapTiles.layer(context),
            RichAttributionWidget(attributions: MapTiles.attributions(context)),
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
              markers: comLocalizacao.map((store) {
                final isFocused = widget.focusedStore?.id == store.id;
                return Marker(
                  point: LatLng(store.latitude!, store.longitude!),
                  width: isFocused ? 60.0 : 48.0,
                  height: isFocused ? 60.0 : 48.0,
                  child: SemanticTapArea(
                    label: store.nome,
                    hint: 'Abre os detalhes do comércio',
                    selected: isFocused ? true : null,
                    pressFeedback: false,
                    onTap: () {
                      final onTap = widget.onStoreTap;
                      if (onTap != null) {
                        onTap(store);
                        return;
                      }
                      abrirDetalheDaLoja(context, store);
                    },
                    child: _buildStoreMarker(store, isFocused: isFocused),
                  ),
                );
              }).toList(),
            ),
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
                color: context.mapColors.cardSurface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                "Nenhuma loja com localização cadastrada por aqui ainda",
                textAlign: TextAlign.center,
                style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}
