class ConsumerModel {
  final int? id;
  final String nome;
  final String email;
  final String cpf;
  final String celular;
  final String? senha;

  ConsumerModel({
    this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.celular,
    this.senha,
  });

  ConsumerModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? cpf,
    String? celular,
    String? senha,
  }) {
    return ConsumerModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      celular: celular ?? this.celular,
      senha: senha ?? this.senha,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'celular': celular,
      if (senha != null) 'senha': senha,
    };
  }

  factory ConsumerModel.fromMap(Map<String, dynamic> map) {
    return ConsumerModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      celular: map['celular'] ?? '',
      senha: map['senha'],
    );
  }
}
