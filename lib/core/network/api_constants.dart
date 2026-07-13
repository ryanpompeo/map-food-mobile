class ApiConstants {
  /// Base da API, configurável em build/run:
  ///   flutter run --dart-define=API_URL=http://192.168.x.x:8080  (celular físico, IP da máquina na rede)
  ///   flutter run --dart-define=API_URL=http://10.0.2.2:8080     (emulador Android)
  /// Sem --dart-define, usa localhost (web/desktop na própria máquina).
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );
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
  static const String favoritos = '/favoritos';
}
