/// Modelo completo de consumidor retornado por GET /consumidores/{id}.
///
/// PUT /consumidores/{id} faz replace completo no backend (não faz merge de
/// campos), então toda edição precisa reenviar cpf mesmo quando a tela não
/// permite editá-lo, senão ele é sobrescrito com null.
class ConsumerModel {
  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String? celular;

  const ConsumerModel({
    required this.id,
    required this.nome,
    required this.email,
    this.cpf,
    this.celular,
  });

  factory ConsumerModel.fromJson(Map<String, dynamic> json) => ConsumerModel(
        id: (json['id'] as num).toInt(),
        nome: json['nome']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        cpf: json['cpf'] as String?,
        celular: json['celular'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        if (cpf != null) 'cpf': cpf,
        if (celular != null) 'celular': celular,
      };
}
