import 'package:map_food/core/network/json_reader.dart';

class AuthResponse {
  final String token;
  final String tipo;
  final int id;
  final String nome;
  final String email;

  final bool emailVerificado;

  const AuthResponse({
    required this.token,
    required this.tipo,
    required this.id,
    required this.nome,
    required this.email,
    this.emailVerificado = true,
  });

  AuthResponse comEmailVerificado(bool verificado) => AuthResponse(
        token: token,
        tipo: tipo,
        id: id,
        nome: nome,
        email: email,
        emailVerificado: verificado,
      );

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json.requireString('token'),
        tipo: json.requireString('tipo'),
        id: json.requireInt('id'),
        nome: json.stringOr('nome', ''),
        email: json.stringOr('email', ''),
        emailVerificado: json['emailVerificado'] is bool ? json['emailVerificado'] as bool : true,
      );
}
