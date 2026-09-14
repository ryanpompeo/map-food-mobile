import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/leitura_compartilhada.dart';
import 'package:map_food/core/location/perfil_localizacao.dart';

enum LocationStatus { granted, denied, serviceDisabled }

class LocationResult {
  final LocationStatus status;
  final String? label;
  final double? latitude;
  final double? longitude;

  const LocationResult(this.status, {this.label, this.latitude, this.longitude});
}

class LocationService {
  static const List<Duration> _esperasPadrao = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 30),
  ];

  static FontePosicao _fonte = const FontePosicaoGeolocator();
  static LeituraCompartilhada _leitura = LeituraCompartilhada(_fonte, _esperasPadrao);

  static Stream<Position> get positionStream => streamDe(PerfilLocalizacao.consumidor);

  static Stream<Position> streamDe(PerfilLocalizacao perfil) => _leitura.streamDe(perfil);

  static void reiniciar(PerfilLocalizacao perfil) => _leitura.reiniciar(perfil);

  static Stream<bool> get servicoAtivo =>
      _fonte.statusDoServico().map((status) => status == ServiceStatus.enabled);

  static Future<AcessoLocalizacao> verificarAcesso() => _fonte.verificarAcesso();

  static Future<Position> posicaoAtual(PerfilLocalizacao perfil) =>
      _fonte.posicaoAtual(configuracaoPara(perfil, defaultTargetPlatform));

  static Future<Position?> ultimaConhecida() => _fonte.ultimaConhecida();

  @visibleForTesting
  static void substituirFonte(FontePosicao fonte, {List<Duration>? esperas}) {
    _leitura.descartar();
    _fonte = fonte;
    _leitura = LeituraCompartilhada(fonte, esperas ?? _esperasPadrao);
  }

  @visibleForTesting
  static void restaurarFonte() => substituirFonte(const FontePosicaoGeolocator());

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
