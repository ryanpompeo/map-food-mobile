import 'package:map_food/core/network/json_reader.dart';

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
        token: json.requireString('token'),
        tipo: json.requireString('tipo'),
        id: json.requireInt('id'),
        nome: json.stringOr('nome', ''),
        email: json.stringOr('email', ''),
      );
}
