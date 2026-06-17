class AuthResponse {
  final String token;
  final String tipo;
  final int id;
  final String nome;
  final String email;

  const AuthResponse({
    required this.token,
    required this.tipo,
    required this.id,
    required this.nome,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'].toString(),
        tipo: json['tipo'].toString(),
        id: (json['id'] as num).toInt(),
        nome: json['nome'].toString(),
        email: json['email']?.toString() ?? '',
      );
}