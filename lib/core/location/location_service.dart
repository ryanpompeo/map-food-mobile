import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
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
  static List<Duration> _esperas = _esperasPadrao;
  static final Map<PerfilLocalizacao, _CanalDePosicao> _canais = {};

  static Stream<Position> get positionStream => streamDe(PerfilLocalizacao.consumidor);

  static Stream<Position> streamDe(PerfilLocalizacao perfil) => _canalDe(perfil).stream;

  static void reiniciar(PerfilLocalizacao perfil) => _canais[perfil]?.reiniciar();

  static Stream<bool> get servicoAtivo =>
      _fonte.statusDoServico().map((status) => status == ServiceStatus.enabled);

  static Future<AcessoLocalizacao> verificarAcesso() => _fonte.verificarAcesso();

  static Future<Position> posicaoAtual(PerfilLocalizacao perfil) =>
      _fonte.posicaoAtual(configuracaoPara(perfil, defaultTargetPlatform));

  static Future<Position?> ultimaConhecida() => _fonte.ultimaConhecida();

  static _CanalDePosicao _canalDe(PerfilLocalizacao perfil) => _canais.putIfAbsent(
        perfil,
        () => _CanalDePosicao(configuracaoPara(perfil, defaultTargetPlatform), _fonte, _esperas),
      );

  @visibleForTesting
  static void substituirFonte(FontePosicao fonte, {List<Duration>? esperas}) {
    _canais.clear();
    _fonte = fonte;
    _esperas = esperas ?? _esperasPadrao;
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

class _CanalDePosicao {
  _CanalDePosicao(this._configuracao, this._fonte, this._esperas) {
    _saida = StreamController<Position>.broadcast(onListen: _assinar, onCancel: _encerrar);
  }

  final LocationSettings _configuracao;
  final FontePosicao _fonte;
  final List<Duration> _esperas;
  late final StreamController<Position> _saida;
  StreamSubscription<Position>? _assinatura;
  Timer? _religamento;
  int _tentativa = 0;

  Stream<Position> get stream => _saida.stream;

  void reiniciar() {
    if (_saida.hasListener) _assinar();
  }

  void _assinar() {
    _religamento?.cancel();
    _religamento = null;
    _assinatura?.cancel();
    _assinatura = _fonte.posicoes(_configuracao).listen(
          _aoReceber,
          onError: _saida.addError,
          onDone: _aoTerminar,
        );
  }

  void _aoReceber(Position posicao) {
    _tentativa = 0;
    _saida.add(posicao);
  }

  void _aoTerminar() {
    _assinatura = null;
    if (!_saida.hasListener) return;
    final espera = _esperas[math.min(_tentativa, _esperas.length - 1)];
    _tentativa++;
    _religamento = Timer(espera, _assinar);
  }

  void _encerrar() {
    _religamento?.cancel();
    _religamento = null;
    _assinatura?.cancel();
    _assinatura = null;
    _tentativa = 0;
  }
}
