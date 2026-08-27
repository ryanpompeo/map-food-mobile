import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

/// Adapter que devolve uma resposta fixa sem tocar na rede — é o que a costura
/// de DI do `ApiClient` passou a permitir. Antes deste PR, exercitar
/// service + model exigia uma API real rodando em localhost:8080.
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
    // Sem AuthInterceptor: ele leria SharedPreferences, que não existe fora de
    // um binding de teste. O ErrorInterceptor é o que interessa aqui.
    ..interceptors.add(ErrorInterceptor());
  return StoreService(client: ApiClient(dio: dio));
}

void main() {
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
      // Campos ausentes caem nos padrões, sem estourar.
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
      // Um 200 com corpo vazio antes produzia `null as List<dynamic>` —
      // TypeError que escapava de todo `on AppException` do app.
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
