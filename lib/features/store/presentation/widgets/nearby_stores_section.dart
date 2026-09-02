import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/nearby_filter.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

class NearbyStoresSection extends StatefulWidget {
  final List<StoreDto> stores;
  final double? initialLatitude;
  final double? initialLongitude;

  final double? raioKm;

  final StoreDto? focusedStore;

  final StoreMapController? mapController;
  final ValueChanged<StoreDto>? onStoreTap;
  final bool showFloatingControls;
  final bool showEmptyBanner;

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
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 10));
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
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
        }
      }

      if (!mounted) return;

      _positionSub = LocationService.positionStream.listen((posicao) {
        _userPosition.value = LatLng(posicao.latitude, posicao.longitude);

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
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _userPosition.dispose();
    super.dispose();
  }

  List<StoreDto> get _lojasNoRaio => lojasDentroDoRaio(
        widget.stores,
        lat: _lat,
        lng: _lng,
        raioKm: widget.raioKm,
      );

  @override
  Widget build(BuildContext context) {
    final lojas = _lojasNoRaio;

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
      floatingControlsBottomPadding: 110.0,
      topBannerOffset: 84.0,
    );
  }
}
