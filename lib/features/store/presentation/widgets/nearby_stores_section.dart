import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
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

  const NearbyStoresSection({
    super.key,
    required this.stores,
    this.initialLatitude,
    this.initialLongitude,
    this.raioKm,
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
    if (_lat != null && _lng != null)
      _userPosition.value = LatLng(_lat!, _lng!);
    _iniciarRastreamento();
  }

  Future<void> _iniciarRastreamento() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
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
          );
          _userPosition.value = LatLng(posicao.latitude, posicao.longitude);
          if (mounted)
            setState(() {
              _lat = posicao.latitude;
              _lng = posicao.longitude;
            });
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

  List<StoreDto> get _lojasNoRaio {
    final raio = widget.raioKm;
    if (raio == null || _lat == null || _lng == null) return widget.stores;
    final raioMetros = raio * 1000;
    return widget.stores.where((loja) {
      if (!loja.temLocalizacao) return false;
      final distancia = Geolocator.distanceBetween(
        _lat!,
        _lng!,
        loja.latitude!,
        loja.longitude!,
      );
      return distancia <= raioMetros;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StoreMapView(
      stores: _lojasNoRaio,
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
