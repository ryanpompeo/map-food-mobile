import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';

Future<AppException> _traduzir({
  int? status,
  dynamic body,
  DioExceptionType tipo = DioExceptionType.badResponse,
}) async {
  final options = RequestOptions(path: '/lojas');
  final erro = DioException(
    requestOptions: options,
    type: tipo,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status, data: body),
  );

  AppException? capturada;
  final handler = _HandlerEspiao((rejeitada) {
    capturada = rejeitada.error as AppException;
  });

  ErrorInterceptor().onError(erro, handler);
  return capturada!;
}

class _HandlerEspiao extends ErrorInterceptorHandler {
  _HandlerEspiao(this.aoRejeitar);
  final void Function(DioException) aoRejeitar;

  @override
  void reject(DioException error) => aoRejeitar(error);
}

void main() {
  group('mensagem exibida ao usuário', () {
    test('erro de validação do Spring usa defaultMessage do primeiro campo', () async {
      final e = await _traduzir(status: 400, body: {
        'fieldErrors': [
          {'field': 'nome', 'defaultMessage': 'Nome é obrigatório'},
        ],
      });
      expect(e.message, 'Nome é obrigatório');
      expect(e.statusCode, 400);
    });

    test('errors como mapa campo→mensagem também é lido', () async {
      final e = await _traduzir(status: 400, body: {
        'errors': {'cep': 'CEP inválido'},
      });
      expect(e.message, 'CEP inválido');
    });

    test('body com "message" usa essa mensagem', () async {
      final e = await _traduzir(status: 409, body: {'message': 'E-mail já cadastrado.'});
      expect(e.message, 'E-mail já cadastrado.');
      expect(e.statusCode, 409);
    });

    test(
      'corpo de erro padrão do Spring NÃO vaza o timestamp como mensagem',
      () async {
        final e = await _traduzir(status: 400, body: {
          'timestamp': '2026-08-24T14:32:11.482+00:00',
          'status': 400,
          'error': 'Bad Request',
          'path': '/lojas',
        });
        expect(e.message, isNot(contains('2026')));
        expect(e.message, isNot('Bad Request'));
        expect(e.message, 'Dados inválidos.');
      },
    );

    test('corpo HTML de proxy não é exibido ao usuário', () async {
      final e = await _traduzir(status: 502, body: '<html><body>502 Bad Gateway</body></html>');
      expect(e, isA<ServerException>());
      expect(e.message, isNot(contains('<html>')));
    });
  });

  group('tipo de exceção por status', () {
    test('401 vira UnauthorizedException', () async {
      expect(await _traduzir(status: 401, body: null), isA<UnauthorizedException>());
    });

    test('404 vira NotFoundException', () async {
      expect(await _traduzir(status: 404, body: null), isA<NotFoundException>());
    });

    test('500 vira ServerException', () async {
      expect(await _traduzir(status: 500, body: null), isA<ServerException>());
    });

    test('timeout de conexão vira NetworkException', () async {
      expect(
        await _traduzir(tipo: DioExceptionType.connectionTimeout),
        isA<NetworkException>(),
      );
    });

    test('timeout de envio (upload) também vira NetworkException', () async {
      expect(
        await _traduzir(tipo: DioExceptionType.sendTimeout),
        isA<NetworkException>(),
      );
    });
  });
}
