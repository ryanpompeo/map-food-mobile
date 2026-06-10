class AuthResponse {
  final String token;
  final String tipo;
  final int id;
  final String nome;

  const AuthResponse({
    required this.token,
    required this.tipo,
    required this.id,
    required this.nome,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'].toString(),
        tipo: json['tipo'].toString(),
        id: (json['id'] as num).toInt(),
        nome: json['nome'].toString(),
      );
}