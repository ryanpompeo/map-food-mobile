import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/location/perfil_localizacao.dart';

class _FonteFalsa implements FontePosicao {
  final List<LocationSettings> pedidos = [];
  final List<StreamController<Position>> emissores = [];
  final StreamController<ServiceStatus> servico = StreamController<ServiceStatus>.broadcast();

  StreamController<Position> get atual => emissores.last;

  @override
  Stream<Position> posicoes(LocationSettings configuracao) {
    pedidos.add(configuracao);
    final emissor = StreamController<Position>();
    emissores.add(emissor);
    return emissor.stream;
  }

  @override
  Stream<ServiceStatus> statusDoServico() => servico.stream;

  @override
  Future<AcessoLocalizacao> verificarAcesso() async => AcessoLocalizacao.liberado;

  @override
  Future<Position> posicaoAtual(LocationSettings configuracao) async => _posicao(-22.9);

  @override
  Future<Position?> ultimaConhecida() async => null;

  Future<void> fechar() async {
    await servico.close();
    for (final emissor in emissores) {
      await emissor.close();
    }
  }
}

Position _posicao(double latitude) => Position(
      latitude: latitude,
      longitude: -43.1729,
      timestamp: DateTime(2026, 9, 13, 10),
      accuracy: 8,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

Future<void> _escoarEventos() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late _FonteFalsa fonte;

  setUp(() {
    fonte = _FonteFalsa();
    LocationService.substituirFonte(fonte, esperas: const [Duration(milliseconds: 1)]);
  });

  tearDown(() async {
    LocationService.restaurarFonte();
    await fonte.fechar();
  });

  group('perfis de acurácia', () {
    test('consumidor segue com precisão média e filtro de 50 m', () {
      final c = configuracaoPara(PerfilLocalizacao.consumidor, TargetPlatform.android);

      expect(c.accuracy, LocationAccuracy.medium);
      expect(c.distanceFilter, 50);
    });

    test('ronda no Android usa GPS, filtro de 20 m e leitura a cada 5 s', () {
      final c = configuracaoPara(PerfilLocalizacao.ronda, TargetPlatform.android);

      expect(c, isA<AndroidSettings>());
      expect(c.accuracy, LocationAccuracy.high);
      expect(c.distanceFilter, 20);
      expect((c as AndroidSettings).intervalDuration, const Duration(seconds: 5));
    });

    test('ronda no iOS não pausa sozinha nem pede segundo plano antes da hora', () {
      final c = configuracaoPara(PerfilLocalizacao.ronda, TargetPlatform.iOS) as AppleSettings;

      expect(c.accuracy, LocationAccuracy.high);
      expect(c.distanceFilter, 20);
      expect(c.activityType, ActivityType.otherNavigation);
      expect(c.pauseLocationUpdatesAutomatically, isFalse);
      expect(c.allowBackgroundLocationUpdates, isFalse);
    });
  });

  group('canal compartilhado', () {
    test('dois ouvintes do mesmo perfil usam uma única leitura do GPS', () async {
      final a = LocationService.streamDe(PerfilLocalizacao.ronda).listen((_) {});
      final b = LocationService.streamDe(PerfilLocalizacao.ronda).listen((_) {});
      addTearDown(a.cancel);
      addTearDown(b.cancel);

      expect(fonte.pedidos, hasLength(1));
    });

    test('perfis diferentes abrem leituras separadas, cada uma com a sua precisão', () async {
      final a = LocationService.streamDe(PerfilLocalizacao.consumidor).listen((_) {});
      final b = LocationService.streamDe(PerfilLocalizacao.ronda).listen((_) {});
      addTearDown(a.cancel);
      addTearDown(b.cancel);

      expect(fonte.pedidos.map((c) => c.accuracy),
          [LocationAccuracy.medium, LocationAccuracy.high]);
    });

    test('positionStream continua sendo o perfil do consumidor', () async {
      final a = LocationService.positionStream.listen((_) {});
      addTearDown(a.cancel);

      expect(fonte.pedidos.single.accuracy, LocationAccuracy.medium);
    });

    test('o último ouvinte a sair desliga o GPS', () async {
      final a = LocationService.streamDe(PerfilLocalizacao.ronda).listen((_) {});
      await a.cancel();

      expect(fonte.emissores.single.hasListener, isFalse);
    });
  });

  group('recuperação', () {
    test('posições chegam a quem está ouvindo', () async {
      final recebidas = <double>[];
      final a = LocationService.streamDe(PerfilLocalizacao.ronda).listen((p) => recebidas.add(p.latitude));
      addTearDown(a.cancel);

      fonte.atual.add(_posicao(-22.90));
      fonte.atual.add(_posicao(-22.91));
      await _escoarEventos();

      expect(recebidas, [-22.90, -22.91]);
    });

    test('se o stream do GPS morre com alguém ouvindo, ele é religado sozinho', () async {
      final recebidas = <double>[];
      final a = LocationService.streamDe(PerfilLocalizacao.ronda).listen((p) => recebidas.add(p.latitude));
      addTearDown(a.cancel);

      await fonte.atual.close();
      await _escoarEventos();

      expect(fonte.pedidos, hasLength(2));
      fonte.atual.add(_posicao(-22.95));
      await _escoarEventos();
      expect(recebidas, [-22.95]);
    });

    test('sem ninguém ouvindo, o fim do stream não religa o GPS', () async {
      final a = LocationService.streamDe(PerfilLocalizacao.ronda).listen((_) {});
      await a.cancel();

      await fonte.emissores.single.close();
      await _escoarEventos();

      expect(fonte.pedidos, hasLength(1));
    });

    test('erro do GPS é repassado sem derrubar a leitura', () async {
      final erros = <Object>[];
      final recebidas = <double>[];
      final a = LocationService.streamDe(PerfilLocalizacao.ronda).listen(
            (p) => recebidas.add(p.latitude),
            onError: erros.add,
          );
      addTearDown(a.cancel);

      fonte.atual.addError(const LocationServiceDisabledException());
      fonte.atual.add(_posicao(-22.97));
      await _escoarEventos();

      expect(erros.single, isA<LocationServiceDisabledException>());
      expect(recebidas, [-22.97]);
      expect(fonte.pedidos, hasLength(1));
    });

    test('reiniciar força uma leitura nova, para o watchdog da ronda', () async {
      final a = LocationService.streamDe(PerfilLocalizacao.ronda).listen((_) {});
      addTearDown(a.cancel);

      LocationService.reiniciar(PerfilLocalizacao.ronda);

      expect(fonte.pedidos, hasLength(2));
      expect(fonte.emissores.first.hasListener, isFalse);
    });

    test('status do serviço vira um booleano simples', () async {
      final estados = <bool>[];
      final a = LocationService.servicoAtivo.listen(estados.add);
      addTearDown(a.cancel);

      fonte.servico.add(ServiceStatus.disabled);
      fonte.servico.add(ServiceStatus.enabled);
      await _escoarEventos();

      expect(estados, [false, true]);
    });
  });
}
