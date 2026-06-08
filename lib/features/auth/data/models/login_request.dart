class LoginRequest {
  final String email;
  final String senha;
  final String tipo;

  const LoginRequest({required this.email, required this.senha, required this.tipo});

  Map<String, dynamic> toJson() => {'email': email, 'senha': senha, 'tipo': tipo};
}