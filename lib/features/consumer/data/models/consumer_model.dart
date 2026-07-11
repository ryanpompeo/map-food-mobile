/// Modelo completo de consumidor retornado por GET /consumidores/{id}.
///
/// PUT /consumidores/{id} faz replace completo no backend (não faz merge de
/// campos), então toda edição precisa reenviar cpf/imagemUrl mesmo quando a
/// tela não permite editá-los, senão são sobrescritos com null — inclusive
/// apagando a foto de perfil enviada por POST /consumidores/{id}/imagem.
class ConsumerModel {
  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String? celular;
  final String? imagemUrl;

  const ConsumerModel({
    required this.id,
    required this.nome,
    required this.email,
    this.cpf,
    this.celular,
    this.imagemUrl,
  });

  factory ConsumerModel.fromJson(Map<String, dynamic> json) => ConsumerModel(
        id: (json['id'] as num).toInt(),
        nome: json['nome']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        cpf: json['cpf'] as String?,
        celular: json['celular'] as String?,
        imagemUrl: json['imagemUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        if (cpf != null) 'cpf': cpf,
        if (celular != null) 'celular': celular,
        if (imagemUrl != null) 'imagemUrl': imagemUrl,
      };
}
