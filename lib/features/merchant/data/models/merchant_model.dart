/// Modelo completo de comerciante retornado por GET /comerciantes/{id}.
///
/// PUT /comerciantes/{id} faz replace completo no backend (não faz merge de
/// campos), então toda edição precisa reenviar cpf/telefone mesmo quando a
/// tela não permite editá-los, senão eles são sobrescritos com null.
class MerchantModel {
  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String? celular;
  final String? telefone;
  final String? cnpj;

  const MerchantModel({
    required this.id,
    required this.nome,
    required this.email,
    this.cpf,
    this.celular,
    this.telefone,
    this.cnpj,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
        id: ((json['id_comerciante'] ?? json['id']) as num).toInt(),
        nome: json['nome']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        cpf: json['cpf'] as String?,
        celular: json['celular'] as String?,
        telefone: json['telefone'] as String?,
        cnpj: json['cnpj'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        if (cpf != null) 'cpf': cpf,
        if (celular != null) 'celular': celular,
        if (telefone != null) 'telefone': telefone,
        if (cnpj != null) 'cnpj': cnpj,
      };
}
