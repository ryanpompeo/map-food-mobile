import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/auth/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

AuthService _serviceQueResponde({int statusCode = 200, required String body}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = _AdapterFalso(statusCode: statusCode, body: body)
    ..interceptors.add(ErrorInterceptor());
  return AuthService(client: ApiClient(dio: dio));
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('login bem-sucedido', () {
    test('devolve a sessão e a persiste', () async {
      final service = _serviceQueResponde(body: '''
        {"token": "jwt-abc", "tipo": "CONSUMIDOR", "id": 5,
         "nome": "Ana", "email": "ana@mapfood.com"}
      ''');

      final sessao = await service.login('ana@mapfood.com', 'senha', 'CONSUMIDOR');

      expect(sessao.token, 'jwt-abc');
      expect(sessao.tipo, 'CONSUMIDOR');
      expect(sessao.id, 5);

      final persistida = await AuthStorage.getSession();
      expect(persistida?.token, 'jwt-abc');
      expect(persistida?.nome, 'Ana');
    });

    test('sem e-mail no corpo, preserva o que o usuário digitou', () async {
      final service = _serviceQueResponde(
        body: '{"token": "jwt-abc", "tipo": "COMERCIANTE", "id": 9, "nome": "João"}',
      );

      final sessao = await service.login('joao@mapfood.com', 'senha', 'COMERCIANTE');

      expect(sessao.email, 'joao@mapfood.com');
      expect((await AuthStorage.getSession())?.email, 'joao@mapfood.com');
    });
  });

  group('erros traduzidos pelo pipeline unificado', () {
    test('401 vira UnauthorizedException', () async {
      final service = _serviceQueResponde(statusCode: 401, body: '{}');

      await expectLater(
        service.login('ana@mapfood.com', 'errada', 'CONSUMIDOR'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('401 no login NÃO derruba a sessão existente no aparelho', () async {
      // Cenário: já logado como consumidor, tenta entrar noutra conta e erra a
      // senha. Se o 401 fosse tratado como "sessão expirada", o SessionManager
      // limparia o AuthStorage e mandaria a pessoa para a tela de login.
      SharedPreferences.setMockInitialValues({
        'auth_token': 'jwt-da-sessao-atual',
        'user_id': 1,
        'user_nome': 'Ana',
        'user_tipo': 'CONSUMIDOR',
        'user_email': 'ana@mapfood.com',
      });

      final service = _serviceQueResponde(statusCode: 401, body: '{}');

      await expectLater(
        service.login('outra@mapfood.com', 'errada', 'CONSUMIDOR'),
        throwsA(isA<UnauthorizedException>()),
      );

      // Espera um tick para o caso de alguma limpeza assíncrona ter sido
      // disparada por engano.
      await Future<void>.delayed(Duration.zero);
      expect(await AuthStorage.getToken(), 'jwt-da-sessao-atual');
    });

    test('500 vira ServerException', () async {
      final service = _serviceQueResponde(statusCode: 500, body: '{"message": "boom"}');

      await expectLater(
        service.login('ana@mapfood.com', 'senha', 'CONSUMIDOR'),
        throwsA(isA<ServerException>()),
      );
    });

    test('token ausente na resposta vira ParseException, não sessão quebrada', () async {
      // Antes, `json['token'].toString()` gravava a string "null" como token e
      // o problema só aparecia na primeira requisição autenticada.
      final service = _serviceQueResponde(
        body: '{"tipo": "CONSUMIDOR", "id": 5, "nome": "Ana"}',
      );

      await expectLater(
        service.login('ana@mapfood.com', 'senha', 'CONSUMIDOR'),
        throwsA(isA<ParseException>()),
      );
      expect(await AuthStorage.getToken(), isNull);
    });
  });
}
