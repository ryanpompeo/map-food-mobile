class ConsumerRegisterRequest {
  final String nome;
  final String email;
  final String cpf;
  final String celular;
  final String senha;

  const ConsumerRegisterRequest({
    required this.nome,
    required this.email,
    required this.cpf,
    required this.celular,
    required this.senha,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'celular': celular,
        'senha': senha,
      };
}