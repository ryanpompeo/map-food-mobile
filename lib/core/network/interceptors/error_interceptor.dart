import 'package:dio/dio.dart';
import 'package:map_food/core/errors/exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
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
        _ when (status ?? 0) >= 500 => ServerException(message ?? 'Erro no servidor.'),
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
    if (data is Map) return data['message']?.toString() ?? data['error']?.toString();
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  /// Extrai a primeira mensagem de validação do corpo retornado pelo Spring
  /// para erros 400 gerados por @Valid (MethodArgumentNotValidException).
  /// O Spring retorna um array em "fieldErrors" ou "errors", cada item com
  /// um campo "defaultMessage".
  String? _extractValidationMessage(dynamic data) {
    if (data is! Map) return null;

    for (final key in ['fieldErrors', 'errors']) {
      final list = data[key];
      if (list is List && list.isNotEmpty) {
        final first = list.first;
        if (first is Map) {
          final msg = first['defaultMessage']?.toString() ??
              first['message']?.toString();
          if (msg != null && msg.isNotEmpty) return msg;
        }
      }
    }
    return null;
  }
}