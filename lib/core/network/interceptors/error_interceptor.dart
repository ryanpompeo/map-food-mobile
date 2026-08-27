import 'package:dio/dio.dart';
import 'package:map_food/core/errors/exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        // `sendTimeout` entrou junto com o `sendTimeout` do ApiClient: antes
        // ele não estava configurado, então esse tipo nunca chegava aqui e
        // caía no `else`, virando "Erro desconhecido." num upload lento.
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      exception = const NetworkException();
    } else {
      final status = err.response?.statusCode;
      final data = err.response?.data;
      final message = _extractMessage(data);

      exception = switch (status) {
        400 => AppException(
          _extractValidationMessage(data) ?? message ?? 'Dados inválidos.',
          statusCode: 400,
        ),
        401 => UnauthorizedException(message ?? 'Credenciais inválidas.'),
        403 => AppException(message ?? 'Acesso negado.', statusCode: 403),
        404 => NotFoundException(message ?? 'Não encontrado.'),
        409 => AppException(message ?? 'Conflito de dados.', statusCode: 409),
        _ when (status ?? 0) >= 500 => ServerException(
          message ?? 'Erro no servidor.',
        ),
        _ => AppException(message ?? 'Erro desconhecido.', statusCode: status),
      };
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      final message = _textoNaoVazio(data['message']);
      if (message != null) return message;

      // `error` só serve quando NÃO é o corpo de erro padrão do Spring — lá
      // essa chave carrega o nome do status em inglês ("Bad Request"), que não
      // diz nada a quem está usando o app em português.
      if (!_ehErroPadraoDoSpring(data)) {
        final error = _textoNaoVazio(data['error']);
        if (error != null) return error;
      }

      return _textoNaoVazio(data['erro']);
    }
    // Corpo de texto puro pode ser uma página HTML de proxy/gateway — jogar
    // isso na tela do usuário é pior do que a mensagem genérica.
    if (data is String && data.isNotEmpty && !data.trimLeft().startsWith('<')) {
      return data;
    }
    return null;
  }

  /// Assinatura do `{"timestamp":..., "status":..., "error":..., "path":...}`
  /// que o Spring Boot devolve quando nenhum handler tratou a exceção.
  bool _ehErroPadraoDoSpring(Map<dynamic, dynamic> data) =>
      data.containsKey('timestamp') &&
      data.containsKey('status') &&
      data.containsKey('path');

  String? _textoNaoVazio(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String? _extractValidationMessage(dynamic data) {
    if (data is! Map) return null;

    for (final key in const ['fieldErrors', 'errors']) {
      final errosDeValidacao = data[key];

      if (errosDeValidacao is List && errosDeValidacao.isNotEmpty) {
        final first = errosDeValidacao.first;
        if (first is Map) {
          final msg =
              first['defaultMessage']?.toString() ??
              first['message']?.toString();
          if (msg != null && msg.isNotEmpty) return msg;
        }
        if (first is String && first.isNotEmpty) return first;
      }

      // Bean Validation também devolve `{"errors": {"nome": "não pode ser vazio"}}`.
      if (errosDeValidacao is Map && errosDeValidacao.isNotEmpty) {
        final msg = errosDeValidacao.values.first?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
      }
    }

    // Não há mais fallback para `data.values.first`. O corpo de erro padrão do
    // Spring é `{timestamp, status, error, path}` — e o primeiro valor dele é o
    // timestamp, que era exibido ao usuário como se fosse a mensagem de erro
    // ("2026-08-24T14:32:11.482+00:00"). Sem mensagem aqui, o texto genérico do
    // `switch` acima entra, que é o comportamento correto.
    return null;
  }
}
