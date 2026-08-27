import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/nearby_filter.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

/// Mapa de lojas próximas em tela cheia, usado na aba "Início" de guest,
/// consumidor e comerciante. Mantém sua própria assinatura de GPS (só em
/// primeiro plano) pra atualizar a posição do usuário conforme ele anda,
/// recalculando quais lojas caem dentro do raio. O raio em si é controlado
/// de fora (modal de filtros da home) — este widget só aplica o corte.
class NearbyStoresSection extends StatefulWidget {
  /// Lojas já filtradas por categoria pelo widget pai — este widget só
  /// aplica o filtro de distância por cima.
  final List<StoreDto> stores;
  final double? initialLatitude;
  final double? initialLongitude;

  /// Raio em km escolhido no modal de filtros; null = "Todos" (sem corte).
  final double? raioKm;

  /// Loja destacada no mapa (pin maior).
  final StoreDto? focusedStore;

  final StoreMapController? mapController;
  final ValueChanged<StoreDto>? onStoreTap;
  final bool showFloatingControls;
  final bool showEmptyBanner;

  /// Avisa quem monta esta seção sobre o resultado do corte por raio e a
  /// posição do usuário — assim a tela dona do mapa reage a essas mudanças
  /// (ex: o botão de recentralizar da home) sem abrir uma segunda assinatura
  /// de GPS nem duplicar o cálculo de distância.
  final void Function(List<StoreDto> lojas, LatLng? posicaoUsuario)? onNearbyChanged;

  const NearbyStoresSection({
    super.key,
    required this.stores,
    this.initialLatitude,
    this.initialLongitude,
    this.raioKm,
    this.focusedStore,
    this.mapController,
    this.onStoreTap,
    this.showFloatingControls = true,
    this.showEmptyBanner = true,
    this.onNearbyChanged,
  });

  @override
  State<NearbyStoresSection> createState() => _NearbyStoresSectionState();
}

class _NearbyStoresSectionState extends State<NearbyStoresSection> {
  static const double _limiarAtualizarListaMetros = 15.0;

  double? _lat;
  double? _lng;
  StreamSubscription<Position>? _positionSub;

  final ValueNotifier<LatLng?> _userPosition = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLatitude;
    _lng = widget.initialLongitude;
    if (_lat != null && _lng != null) {
      _userPosition.value = LatLng(_lat!, _lng!);
    }
    _iniciarRastreamento();
  }

  Future<void> _iniciarRastreamento() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 10));
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 10));
      if (permission == LocationPermission.denied) {
        // No Flutter Web o prompt é nativo do navegador, fora do canvas do
        // Flutter — sem timeout, um usuário que não percebe/ignora esse
        // prompt trava este `await` pra sempre (e junto com ele, qualquer
        // outro widget esperando o mesmo tipo de permissão, ex: SearchPage).
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 10));
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      // O diálogo de permissão do SO pode levar segundos pra ser respondido —
      // se o widget já foi descartado nesse meio-tempo, não assina o stream
      // (senão a subscription nunca é cancelada e o GPS fica ligado à toa).
      if (!mounted) return;

      if (_lat == null || _lng == null) {
        try {
          final posicao = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
            ),
          ).timeout(const Duration(seconds: 10));
          _userPosition.value = LatLng(posicao.latitude, posicao.longitude);
          if (mounted) {
            setState(() {
              _lat = posicao.latitude;
              _lng = posicao.longitude;
            });
          }
        } catch (_) {
          // Segue sem posição inicial — o mapa cai no fallback padrão.
        }
      }

      // getCurrentPosition acima também pode ter levado um tempo — confere
      // de novo antes de assinar o stream compartilhado.
      if (!mounted) return;

      // Stream compartilhado com a ronda do comerciante — um único consumo
      // de GPS mesmo com as duas telas vivas no IndexedStack.
      _positionSub = LocationService.positionStream.listen((posicao) {
        // Sempre atualiza o marcador ao vivo — barato, não reconstrói a seção
        // nem os marcadores de loja do StoreMapView.
        _userPosition.value = LatLng(posicao.latitude, posicao.longitude);

        // Só reconstrói a lista de lojas/câmera se andou o suficiente pra
        // fazer diferença no filtro de raio — evita rebuild em massa a cada
        // tick de GPS.
        final andouOSuficiente =
            _lat == null ||
            _lng == null ||
            Geolocator.distanceBetween(
                  _lat!,
                  _lng!,
                  posicao.latitude,
                  posicao.longitude,
                ) >
                _limiarAtualizarListaMetros;
        if (andouOSuficiente && mounted) {
          setState(() {
            _lat = posicao.latitude;
            _lng = posicao.longitude;
          });
        }
      });
    } catch (_) {
      // Sem GPS disponível — mapa mostra todas as lojas recebidas, sem filtro de raio.
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _userPosition.dispose();
    super.dispose();
  }

  /// O corte em si mora em `data/nearby_filter.dart` — função pura, coberta
  /// por teste. Aqui fica só a ligação com o estado do widget (a posição do
  /// GPS e o raio vindo do modal de filtros).
  List<StoreDto> get _lojasNoRaio => lojasDentroDoRaio(
        widget.stores,
        lat: _lat,
        lng: _lng,
        raioKm: widget.raioKm,
      );

  @override
  Widget build(BuildContext context) {
    final lojas = _lojasNoRaio;

    // Notifica fora do frame de build: chamar setState do pai durante o build
    // do filho é erro de framework.
    final aviso = widget.onNearbyChanged;
    if (aviso != null) {
      final posicao = _lat != null && _lng != null ? LatLng(_lat!, _lng!) : null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) aviso(lojas, posicao);
      });
    }

    return StoreMapView(
      stores: lojas,
      focusedStore: widget.focusedStore,
      controller: widget.mapController,
      onStoreTap: widget.onStoreTap,
      showFloatingControls: widget.showFloatingControls,
      showEmptyBanner: widget.showEmptyBanner,
      initialLatitude: _lat,
      initialLongitude: _lng,
      userPosition: _userPosition,
      // A bottom bar flutuante (glass) e a busca/filtro flutuantes ficam por
      // cima do mapa aqui — sem esse respiro, os controles de câmera e o
      // banner de "sem lojas" ficariam embaixo deles.
      floatingControlsBottomPadding: 110.0,
      topBannerOffset: 84.0,
    );
  }
}
