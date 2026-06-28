class ApiConstants {
  static const String baseUrl = 'http://localhost:8080';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String login = '/auth/login';
  static const String consumidores = '/consumidores';
  static const String comerciantes = '/comerciantes';
  static const String lojas = '/lojas';
  static const String lojasAtivas = '/lojas/ativas';
  static const String avaliacoes = '/avaliacoes';
  static const String categorias = '/categorias';
  static const String denuncias = '/denuncias';
}
