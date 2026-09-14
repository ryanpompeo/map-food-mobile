import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/route_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/controllers/rota_reativa_controller.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

class StoreMapPage extends StatefulWidget {
  final StoreDto store;

  final CalcularRota? calcularRota;

  const StoreMapPage({super.key, required this.store, this.calcularRota});

  @override
  State<StoreMapPage> createState() => _StoreMapPageState();
}

class _StoreMapPageState extends State<StoreMapPage> {
  final ValueNotifier<LatLng?> _userPosition = ValueNotifier(null);
  final ValueNotifier<bool> _hasUnsavedChanges = ValueNotifier(false);
  late final ValueNotifier<StoreDto> _lojaNoMapa = ValueNotifier(widget.store);
  late final ValueListenable<StoreDto?> _lojaAoVivo =
      ActiveStoresManager.instance.observar(widget.store.id);

  RotaReativaController? _rota;
  StreamSubscription<Position>? _posicoes;
  bool _semPermissao = false;
  bool _lojaJaApareceu = false;

  @override
  void initState() {
    super.initState();
    _rota = _criarRota();
    _rota?.estado.addListener(_aoMudarRota);
    _lojaAoVivo.addListener(_aoMudarLoja);
    ActiveStoresManager.instance.addListener(_manterConsultaAtiva);
    _aoMudarLoja();
    unawaited(_acompanharUsuario());
  }

  @override
  void dispose() {
    _posicoes?.cancel();
    ActiveStoresManager.instance.removeListener(_manterConsultaAtiva);
    _lojaAoVivo.removeListener(_aoMudarLoja);
    _rota?.estado.removeListener(_aoMudarRota);
    _rota?.dispose();
    _userPosition.dispose();
    _hasUnsavedChanges.dispose();
    _lojaNoMapa.dispose();
    super.dispose();
  }

  RotaReativaController? _criarRota() {
    final loja = widget.store;
    if (!loja.temLocalizacao) return null;
    return RotaReativaController(
      calcular: widget.calcularRota ?? RouteService().getRoute,
      destinoInicial: LatLng(loja.latitude!, loja.longitude!),
    );
  }

  void _manterConsultaAtiva() {}

  void _aoMudarLoja() {
    final loja = _lojaAoVivo.value;
    if (loja == null) {
      if (_lojaJaApareceu) _rota?.lojaSaiu();
      return;
    }
    _lojaJaApareceu = true;
    _lojaNoMapa.value = loja;
    if (loja.temLocalizacao) _rota?.atualizarDestino(LatLng(loja.latitude!, loja.longitude!));
  }

  void _aoMudarRota() {
    _hasUnsavedChanges.value = _rota?.estado.value.primeiroCalculo ?? false;
  }

  Future<void> _acompanharUsuario() async {
    if (_rota == null) return;
    if (await LocationService.verificarAcesso() != AcessoLocalizacao.liberado) {
      if (mounted) setState(() => _semPermissao = true);
      return;
    }
    final ultima = await LocationService.ultimaConhecida();
    if (!mounted) return;
    if (ultima != null) _aoReceberPosicao(ultima);
    _posicoes = LocationService.positionStream.listen(_aoReceberPosicao, onError: (Object _) {});
  }

  void _aoReceberPosicao(Position posicao) {
    if (!mounted) return;
    final ponto = LatLng(posicao.latitude, posicao.longitude);
    _userPosition.value = ponto;
    _rota?.atualizarOrigem(ponto);
  }

  static String _distanciaLabel(double metros) {
    if (metros < 1000) return '≈ ${metros.round()} m';
    return '≈ ${(metros / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedChanges,
      confirmDialog: confirmarSairDuranteCalculoDeRota,
      child: Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        backgroundColor: context.mapColors.mainBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
        ),
        title: Text(
          widget.store.nome,
          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_lojaNoMapa, ?_rota?.estado]),
        builder: (context, _) {
          final estado = _rota?.estado.value;
          final aviso = _avisoPara(estado);
          return Stack(
            children: [
              StoreMapView(
                stores: [_lojaNoMapa.value],
                focusedStore: _lojaNoMapa.value,
                userPosition: _userPosition,
                routePoints: estado?.pontos,
              ),
              if (aviso != null)
                Positioned(
                  bottom: 24.0,
                  left: 24.0,
                  right: 24.0,
                  child: Center(child: _buildPill(child: aviso)),
                ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget? _avisoPara(EstadoDaRota? estado) {
    if (estado?.lojaIndisponivel ?? false) {
      return _buildPillTexto('A loja saiu do mapa — fechou ou ficou sem sinal');
    }
    if (_semPermissao) return _buildPillTexto('Ative a localização para traçar a rota até a loja');
    if (estado == null) return null;
    if (estado.primeiroCalculo) return _buildPillLoading();
    final metros = estado.distanciaMetros;
    return metros == null ? null : _buildPillDistancia(metros);
  }

  Widget _buildPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPillTexto(String texto) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildPillDistancia(double metros) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(AppIcons.footprints, size: 16.0, color: ColorsPalette.redComponents),
        const SizedBox(width: 6.0),
        Text(
          _distanciaLabel(metros),
          style: AppText.legenda(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.mapColors.primaryText,
          ),
        ),
      ],
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
          "Traçando rota",
          style: AppText.legenda(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
