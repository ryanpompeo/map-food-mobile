class MerchantRegisterRequest {
  final String nome;
  final String email;
  final String cpf;
  final String? cnpj;
  final String celular;
  final String? telefone;
  final String senha;

  const MerchantRegisterRequest({
    required this.nome,
    required this.email,
    required this.cpf,
    this.cnpj,
    required this.celular,
    this.telefone,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'celular': celular,
      'senha': senha,
    };
    if (cnpj != null && cnpj!.isNotEmpty) map['cnpj'] = cnpj;
    if (telefone != null && telefone!.isNotEmpty) map['telefone'] = telefone;
    return map;
  }
}