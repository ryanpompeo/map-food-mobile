import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class _AdapterFalso implements HttpClientAdapter {
  _AdapterFalso({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

StoreService _serviceQueResponde({int statusCode = 200, required String body}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = _AdapterFalso(statusCode: statusCode, body: body)
    ..interceptors.add(ErrorInterceptor());
  return StoreService(client: ApiClient(dio: dio));
}

class _AdapterEspiao implements HttpClientAdapter {
  final List<RequestOptions> chamadas = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    chamadas.add(options);
    return ResponseBody.fromString('', 204, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

StoreDto _lojaDeTeste() => const StoreDto(
      id: 7,
      nome: 'Carrinho do Zé',
      descricao: 'Cachorro-quente',
      statusLoja: 'ATIVA',
      categoria: 'Lanches',
      categoriaIds: [3],
      categoriaNomes: ['Lanches'],
      latitude: -22.9068,
      longitude: -43.1729,
    );

void main() {
  group('atualizarPosicao', () {
    late _AdapterEspiao espiao;
    late StoreService service;

    setUp(() {
      espiao = _AdapterEspiao();
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
        ..httpClientAdapter = espiao
        ..interceptors.add(ErrorInterceptor());
      service = StoreService(client: ApiClient(dio: dio));
    });

    test('sobe só as coordenadas, sem reescrever o cadastro da loja', () async {
      await service.atualizarPosicao(_lojaDeTeste(), -22.92, -43.19);

      expect(espiao.chamadas, hasLength(1));
      final chamada = espiao.chamadas.single;
      expect(chamada.method, 'PATCH');
      expect(chamada.path, '/lojas/7/posicao');
      expect(chamada.data, {'latitude': -22.92, 'longitude': -43.19});
    });

    test('devolve a loja reposicionada sem uma segunda ida à API', () async {
      final atualizada = await service.atualizarPosicao(_lojaDeTeste(), -22.92, -43.19);

      expect(espiao.chamadas, hasLength(1));
      expect(atualizada.latitude, -22.92);
      expect(atualizada.longitude, -43.19);
      expect(atualizada.nome, 'Carrinho do Zé');
      expect(atualizada.categoriaIds, [3]);
    });
  });

  group('getActive', () {
    test('converte o payload em StoreDto', () async {
      final service = _serviceQueResponde(body: '''
        [
          {
            "id": 1,
            "nome": "Padaria do João",
            "statusLoja": "ATIVA",
            "categorias": [{"id": 3, "nome": "Padaria"}],
            "mediaAvaliacao": 4.7,
            "totalAvaliacoes": 12,
            "latitude": -22.9,
            "longitude": -43.1
          }
        ]
      ''');

      final lojas = await service.getActive();

      expect(lojas, hasLength(1));
      expect(lojas.single.nome, 'Padaria do João');
      expect(lojas.single.avaliacao, 4.7);
      expect(lojas.single.categoriaIds, [3]);
      expect(lojas.single.categoriaNomes, ['Padaria']);
      expect(lojas.single.temLocalizacao, isTrue);
    });

    test('loja sem coordenada não é dada como localizada', () async {
      final service = _serviceQueResponde(
        body: '[{"id": 2, "nome": "Sem GPS", "statusLoja": "ATIVA"}]',
      );

      final lojas = await service.getActive();

      expect(lojas.single.temLocalizacao, isFalse);
      expect(lojas.single.avaliacao, isNull);
      expect(lojas.single.totalAvaliacoes, 0);
      expect(lojas.single.galeria, isEmpty);
    });

    test('id ausente vira ParseException nomeada, não TypeError', () async {
      final service = _serviceQueResponde(body: '[{"nome": "Loja sem id"}]');

      await expectLater(
        service.getActive(),
        throwsA(isA<ParseException>().having((e) => e.message, 'message', contains('id'))),
      );
    });

    test('corpo vazio numa rota de lista vira ParseException', () async {
      final service = _serviceQueResponde(body: '');

      await expectLater(service.getActive(), throwsA(isA<ParseException>()));
    });

    test('objeto onde se esperava lista vira ParseException, não crash', () async {
      final service = _serviceQueResponde(body: '{"erro": "formato trocado"}');

      await expectLater(service.getActive(), throwsA(isA<ParseException>()));
    });
  });

  group('erros de transporte continuam tipados', () {
    test('500 vira ServerException', () async {
      final service = _serviceQueResponde(
        statusCode: 500,
        body: '{"message": "Falha interna"}',
      );

      await expectLater(service.getActive(), throwsA(isA<ServerException>()));
    });

    test('404 vira NotFoundException', () async {
      final service = _serviceQueResponde(statusCode: 404, body: '{}');

      await expectLater(service.getById(99), throwsA(isA<NotFoundException>()));
    });
  });
}
