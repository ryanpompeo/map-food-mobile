class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Sessão expirada, entre de novo'])
      : super(statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Recurso não encontrado'])
      : super(statusCode: 404);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Erro no servidor, tente de novo'])
      : super(statusCode: 500);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Sem conexão, verifique sua internet']);
}

class ParseException extends AppException {
  const ParseException([super.message = 'Resposta inesperada do servidor']);
}
