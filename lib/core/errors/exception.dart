class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Sessão expirada. Faça login novamente.'])
      : super(statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Recurso não encontrado.'])
      : super(statusCode: 404);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Erro no servidor. Tente novamente.'])
      : super(statusCode: 500);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Sem conexão. Verifique sua internet.']);
}