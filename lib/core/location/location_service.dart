import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Resultado da tentativa de obter a localização legível do usuário.
enum LocationStatus { granted, denied, serviceDisabled }

class LocationResult {
  final LocationStatus status;
  final String? label;
  final double? latitude;
  final double? longitude;

  const LocationResult(this.status, {this.label, this.latitude, this.longitude});
}

class LocationService {
  static StreamController<Position>? _positionController;
  static StreamSubscription<Position>? _geolocatorSub;

  /// Stream de posição compartilhado por todo o app (mapa de lojas próximas,
  /// ronda do comerciante...): o hardware de GPS é assinado uma única vez,
  /// e desliga quando o último ouvinte cancela. Quem chama já deve ter
  /// verificado serviço/permissão (como os widgets fazem hoje).
  static Stream<Position> get positionStream {
    _positionController ??= StreamController<Position>.broadcast(
      onListen: () {
        _geolocatorSub ??= Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 50,
          ),
        ).listen(
          (posicao) => _positionController?.add(posicao),
          onError: (Object e) => _positionController?.addError(e),
        );
      },
      onCancel: () {
        _geolocatorSub?.cancel();
        _geolocatorSub = null;
      },
    );
    return _positionController!.stream;
  }

  /// Retorna "Bairro, Cidade" (ou só "Cidade" se não houver bairro) a partir
  /// da posição atual do dispositivo, ou o motivo pelo qual não foi possível.
  Future<LocationResult> getCurrentAddressLabel() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(LocationStatus.serviceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationResult(LocationStatus.denied);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );

    // O pacote geocoding não tem implementação web — devolve as coordenadas
    // sem label em vez de estourar MissingPluginException.
    if (kIsWeb) {
      return LocationResult(
        LocationStatus.granted,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) {
      return LocationResult(
        LocationStatus.granted,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    final placemark = placemarks.first;
    final bairro = placemark.subLocality ?? '';
    final cidade = placemark.locality ?? '';

    final label = bairro.isNotEmpty && cidade.isNotEmpty
        ? '$bairro, $cidade'
        : (cidade.isNotEmpty ? cidade : bairro);

    return LocationResult(
      LocationStatus.granted,
      label: label.isNotEmpty ? label : null,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
