import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

import '../../support/aguardar.dart';

class _ApiDeLojas implements HttpClientAdapter {
  List<Map<String, dynamic>> lojas = [];
  Completer<void>? segurar;
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    chamadas++;
    final corpo = jsonEncode(lojas);
    await segurar?.future;
    return ResponseBody.fromString(corpo, 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _loja(int id, {double lat = -22.9068, int? semSinal}) => {
      'id': id,
      'nome': 'Loja $id',
      'statusLoja': 'ATIVA',
      'latitude': lat,
      'longitude': -43.1729,
      'segundosSemSinal': semSinal,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _ApiDeLojas api;
  late DateTime agora;
  final manager = ActiveStoresManager.instance;
  var notificacoes = 0;
  void contar() => notificacoes++;

  List<int> idsVisiveis() => manager.stores.map((l) => l.id).toList();

  Future<void> ouvirECarregar() async {
    manager.addListener(contar);
    await aguardarAte(() => manager.stores.isNotEmpty && !manager.isLoading);
    await escoar();
  }

  setUp(() {
    manager.limparParaTeste();
    api = _ApiDeLojas();
    manager.service = StoreService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = api
          ..interceptors.add(ErrorInterceptor()),
      ),
    );
    agora = DateTime(2026, 9, 13, 10);
    manager.relogio = () => agora;
    notificacoes = 0;
  });

  tearDown(() {
    manager.removeListener(contar);
    manager.limparParaTeste();
  });

  group('cargas', () {
    test('duas cargas ao mesmo tempo viram uma requisição só', () async {
      api.lojas = [_loja(7)];
      api.segurar = Completer<void>();

      final primeira = manager.load();
      final segunda = manager.load();
      api.segurar!.complete();
      await Future.wait([primeira, segunda]);

      expect(api.chamadas, 1);
      expect(idsVisiveis(), [7]);
    });

    test('consulta sem mudança não reconstrói quem está ouvindo', () async {
      api.lojas = [_loja(7, semSinal: 60)];
      await ouvirECarregar();
      final antes = notificacoes;

      agora = agora.add(const Duration(seconds: 20));
      api.lojas = [_loja(7, semSinal: 80)];
      await manager.load();

      expect(notificacoes, antes, reason: 'a idade cresceu junto com o relógio: nada mudou');
    });

    test('latência e arredondamento da API não viram mudança falsa a cada consulta', () async {
      api.lojas = [_loja(7, semSinal: 60)];
      await ouvirECarregar();
      final antes = notificacoes;

      for (final (passo, semSinal) in [(20, 79), (20, 101), (20, 118)]) {
        agora = agora.add(Duration(seconds: passo));
        api.lojas = [_loja(7, semSinal: semSinal)];
        await manager.load();
      }

      expect(notificacoes, antes, reason: 'variações de 1 a 2 s são ruído, não um ping novo');
      expect(manager.semSinalHa(7), const Duration(seconds: 120));
    });

    test('loja que andou avisa quem está ouvindo', () async {
      api.lojas = [_loja(7)];
      await ouvirECarregar();
      final antes = notificacoes;

      api.lojas = [_loja(7, lat: -22.9100)];
      await manager.load();

      expect(notificacoes, antes + 1);
      expect(manager.stores.single.latitude, -22.9100);
    });

    test('ping novo com a loja parada atualiza o "visto há"', () async {
      api.lojas = [_loja(7, semSinal: 60)];
      await ouvirECarregar();
      final antes = notificacoes;

      agora = agora.add(const Duration(seconds: 20));
      api.lojas = [_loja(7, semSinal: 5)];
      await manager.load();

      expect(notificacoes, antes + 1);
      expect(manager.semSinalHa(7), const Duration(seconds: 5));
    });
  });

  group('defasagem', () {
    test('loja sem sinal há 15 min some do mapa; loja fixa nunca some', () async {
      api.lojas = [_loja(7, semSinal: 60), _loja(8)];
      await manager.load();

      agora = agora.add(const Duration(minutes: 13));
      manager.reavaliarDefasagem();
      expect(idsVisiveis(), [7, 8]);

      agora = agora.add(const Duration(minutes: 1));
      manager.reavaliarDefasagem();
      expect(idsVisiveis(), [8]);
    });

    test('a loja volta quando o comerciante manda sinal de novo', () async {
      api.lojas = [_loja(7, semSinal: 60)];
      await manager.load();
      agora = agora.add(const Duration(minutes: 20));
      manager.reavaliarDefasagem();
      expect(idsVisiveis(), isEmpty);

      api.lojas = [_loja(7, semSinal: 3)];
      await manager.load();

      expect(idsVisiveis(), [7]);
    });

    test('"sem sinal há" conta desde o último ping, no relógio do celular', () async {
      api.lojas = [_loja(7, semSinal: 60), _loja(8)];
      await manager.load();

      expect(manager.semSinalHa(7), const Duration(seconds: 60));
      agora = agora.add(const Duration(seconds: 30));
      expect(manager.semSinalHa(7), const Duration(seconds: 90));
      expect(manager.semSinalHa(8), isNull);
    });

    test('a remoção por defasagem avisa quem está ouvindo', () async {
      api.lojas = [_loja(7, semSinal: 60), _loja(8)];
      await ouvirECarregar();
      final antes = notificacoes;

      agora = agora.add(const Duration(minutes: 15));
      manager.reavaliarDefasagem();

      expect(notificacoes, antes + 1);
    });
  });

  group('observar uma loja', () {
    test('só avisa quando aquela loja muda, e vira nulo quando ela sai', () async {
      api.lojas = [_loja(7), _loja(8)];
      await manager.load();
      final ValueListenable<StoreDto?> loja7 = manager.observar(7);
      var avisos = 0;
      loja7.addListener(() => avisos++);

      api.lojas = [_loja(7), _loja(8, lat: -22.95)];
      await manager.load();
      expect(avisos, 0, reason: 'outra loja mudou, não esta');

      api.lojas = [_loja(7, lat: -22.91), _loja(8, lat: -22.95)];
      await manager.load();
      expect(avisos, 1);
      expect(loja7.value?.latitude, -22.91);

      api.lojas = [_loja(8, lat: -22.95)];
      await manager.load();
      expect(avisos, 2);
      expect(loja7.value, isNull);
    });
  });
}
