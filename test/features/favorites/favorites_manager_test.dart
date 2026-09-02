import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/favorites/data/services/favorito_service.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

const _loja = StoreDto(id: 1, nome: 'Padaria', statusLoja: 'ATIVA', categoria: 'Padaria');
const _outra = StoreDto(id: 2, nome: 'Lanchonete', statusLoja: 'ATIVA', categoria: 'Lanches');

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

void _apiRespondendo({int statusCode = 200, String body = '[]'}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = _AdapterFalso(statusCode: statusCode, body: body)
    ..interceptors.add(ErrorInterceptor());
  final client = ApiClient(dio: dio);
  ApiClient.overrideInstance(client);
  FavoritesManager.instance.service = FavoritoService(client: client);
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FavoritesManager.instance.clear();
  });

  tearDownAll(ApiClient.resetInstance);

  group('índice de consulta', () {
    test('add e remove mantêm lista e Set em sincronia', () async {
      _apiRespondendo(body: '[{"id": 1, "nome": "Padaria", "statusLoja": "ATIVA"}]');
      await FavoritesManager.instance.load();

      expect(FavoritesManager.instance.isFavorite(1), isTrue);
      expect(FavoritesManager.instance.favorites.map((e) => e.id), [1]);
      expect(FavoritesManager.instance.isFavorite(999), isFalse);
    });

    test('toggle otimista reflete antes da resposta da API', () async {
      _apiRespondendo(statusCode: 200, body: '{}');

      final futuro = FavoritesManager.instance.toggle(_loja);
      expect(FavoritesManager.instance.isFavorite(1), isTrue);
      await futuro;
      expect(FavoritesManager.instance.favorites, hasLength(1));
    });

    test('falha na API reverte lista E índice juntos', () async {
      _apiRespondendo(statusCode: 500, body: '{"message": "boom"}');

      await expectLater(FavoritesManager.instance.toggle(_loja), throwsA(anything));

      expect(FavoritesManager.instance.isFavorite(1), isFalse);
      expect(FavoritesManager.instance.favorites, isEmpty);
    });

    test('clear zera os dois', () async {
      _apiRespondendo(statusCode: 200, body: '{}');
      await FavoritesManager.instance.toggle(_loja);
      await FavoritesManager.instance.toggle(_outra);

      FavoritesManager.instance.clear();

      expect(FavoritesManager.instance.favorites, isEmpty);
      expect(FavoritesManager.instance.isFavorite(1), isFalse);
      expect(FavoritesManager.instance.isFavorite(2), isFalse);
    });
  });

  group('erro de carga vira estado observável', () {
    test('load com API fora do ar preenche errorMessage em vez de lançar', () async {
      _apiRespondendo(statusCode: 500, body: '{"message": "indisponível"}');

      await FavoritesManager.instance.load();

      expect(FavoritesManager.instance.errorMessage, isNotNull);
      expect(FavoritesManager.instance.isLoading, isFalse);
    });

    test('carga bem-sucedida limpa o erro anterior', () async {
      _apiRespondendo(statusCode: 500, body: '{}');
      await FavoritesManager.instance.load();
      expect(FavoritesManager.instance.errorMessage, isNotNull);

      _apiRespondendo(body: '[]');
      await FavoritesManager.instance.load();

      expect(FavoritesManager.instance.errorMessage, isNull);
    });
  });
}
