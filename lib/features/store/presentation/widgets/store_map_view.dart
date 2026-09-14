import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/ui/theme/map_tiles.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/map_cluster.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';
import 'package:map_food/features/store/presentation/widgets/map_controls.dart';
import 'package:map_food/features/store/presentation/widgets/store_markers_layer.dart';

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
    widget.userPosition?.removeListener(_aoMoverUsuario);
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
    _ctrl.modo.value = _modoPadrao;
    _ctrl.rotacaoTravada.addListener(_onRotacaoExternaMudou);
    widget.userPosition?.addListener(_aoMoverUsuario);
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
    _trocarOuvinteDePosicao(oldWidget.userPosition);
    if (_rotaNova(oldWidget)) {
      _aoChegarRota();
      return;
    }
    _seguirAlvo();
  }

  ModoCamera get _modoPadrao {
    if (_rotaValida(widget.routePoints)) return ModoCamera.enquadrandoRota;
    if (widget.controller == null && _posicaoDaLojaFocada != null) return ModoCamera.seguindoLoja;
    return ModoCamera.seguindoUsuario;
  }

  ModoCamera get _modoDoRecentralizar =>
      widget.userPosition?.value != null ? ModoCamera.seguindoUsuario : _modoPadrao;

  LatLng? get _posicaoDaLojaFocada {
    final focada = widget.focusedStore;
    if (focada == null || !focada.temLocalizacao) return null;
    return LatLng(focada.latitude!, focada.longitude!);
  }

  LatLng? get _posicaoInicial {
    final latitude = widget.initialLatitude;
    final longitude = widget.initialLongitude;
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  LatLng? get _alvoDoModo => switch (_ctrl.modo.value) {
        ModoCamera.seguindoLoja => _posicaoDaLojaFocada,
        ModoCamera.seguindoUsuario => widget.userPosition?.value ?? _posicaoInicial,
        _ => null,
      };

  bool get _temAlvoParaRecentralizar =>
      widget.userPosition != null ||
      _posicaoDaLojaFocada != null ||
      _rotaValida(widget.routePoints);

  static bool _rotaValida(List<LatLng>? rota) => rota != null && rota.length >= 2;

  bool _rotaNova(StoreMapView antigo) =>
      _rotaValida(widget.routePoints) && antigo.routePoints != widget.routePoints;

  void _trocarOuvinteDePosicao(ValueListenable<LatLng?>? anterior) {
    if (identical(anterior, widget.userPosition)) return;
    anterior?.removeListener(_aoMoverUsuario);
    widget.userPosition?.addListener(_aoMoverUsuario);
  }

  void _aoChegarRota() {
    if (_ctrl.modo.value == ModoCamera.livre) return;
    _ctrl.modo.value = ModoCamera.enquadrandoRota;
    _enquadrarRota();
  }

  void _enquadrarRota() {
    final rota = widget.routePoints;
    if (!_rotaValida(rota)) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(rota!),
        padding: const EdgeInsets.all(48.0),
      ),
    );
  }

  void _aoMoverUsuario() {
    if (_ctrl.modo.value == ModoCamera.seguindoUsuario) _seguirAlvo();
  }

  void _seguirAlvo() {
    final alvo = _alvoDoModo;
    if (alvo == null || !_afastouDoUltimoAlvo(alvo)) return;
    _centroRastreadoAnterior = alvo;
    _mapController.move(alvo, _mapController.camera.zoom);
  }

  bool _afastouDoUltimoAlvo(LatLng alvo) {
    final anterior = _centroRastreadoAnterior;
    return anterior == null ||
        _distance.as(LengthUnit.Meter, anterior, alvo) > _limiarRecentralizarMetros;
  }

  void _recentralizar() {
    _ctrl.modo.value = _modoDoRecentralizar;
    if (_ctrl.modo.value == ModoCamera.enquadrandoRota) {
      _enquadrarRota();
      return;
    }
    final alvo = _alvoDoModo;
    if (alvo == null) return;
    _centroRastreadoAnterior = alvo;
    final zoomAtual = _mapController.camera.zoom;
    _mapController.move(alvo, zoomAtual < 15.0 ? 16.0 : zoomAtual);
  }

  void _alternarTravaDeRotacao() => _ctrl.alternarTravaDeRotacao();

  void _abrirLoja(StoreDto store) {
    final onTap = widget.onStoreTap;
    if (onTap != null) {
      onTap(store);
      return;
    }
    abrirDetalheDaLoja(context, store);
  }

  void _aproximarNoGrupo(MapCluster cluster) {
    _ctrl.modo.value = ModoCamera.livre;
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: [
          for (final loja in cluster.lojas) LatLng(loja.latitude!, loja.longitude!),
        ],
        padding: const EdgeInsets.all(72.0),
        maxZoom: StoreMapController.zoomMaximo,
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

  Widget _buildBotaoRecentralizar() {
    final userPosition = widget.userPosition;
    return ListenableBuilder(
      listenable: Listenable.merge([_ctrl.modo, ?userPosition]),
      builder: (context, _) => MapControlButton(
        icon: AppIcons.gpsFix,
        tooltip: 'Recentralizar',
        isActive: _ctrl.modo.value == _modoDoRecentralizar,
        onTap: _recentralizar,
      ),
    );
  }

  Widget _buildFloatingControls() {
    return Positioned(
      right: AppSpacing.md,
      bottom: widget.floatingControlsBottomPadding,
      child: Column(
        children: [
          MapZoomControls(controller: _ctrl),
          const SizedBox(height: AppSpacing.sm),
          if (_temAlvoParaRecentralizar) ...[
            _buildBotaoRecentralizar(),
            const SizedBox(height: AppSpacing.sm),
          ],
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
    final semLocalizacao = !widget.stores.any((s) => s.temLocalizacao);
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
            onMapEvent: _ctrl.aoEventoDoMapa,
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
            StoreMarkersLayer(
              stores: widget.stores,
              focusedStore: widget.focusedStore,
              onStoreTap: _abrirLoja,
              onClusterTap: _aproximarNoGrupo,
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
        if (semLocalizacao && widget.showEmptyBanner)
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
