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

  /// `token`, `tipo` e `id` são obrigatórios: sem qualquer um deles não há
  /// sessão utilizável, e falhar aqui com [ParseException] nomeada é melhor do
  /// que gravar uma sessão pela metade (era o que `json['token'].toString()`
  /// fazia: um token nulo virava a string "null" e só quebrava na requisição
  /// autenticada seguinte, como 401 sem explicação).
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json.requireString('token'),
        tipo: json.requireString('tipo'),
        id: json.requireInt('id'),
        nome: json.stringOr('nome', ''),
        email: json.stringOr('email', ''),
      );
}