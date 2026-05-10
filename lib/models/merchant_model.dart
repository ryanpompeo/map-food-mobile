import 'package:map_food/models/store_model.dart';

class MerchantModel {
  final int? id;
  final String nome;
  final String email;
  final String cpf;
  final String celular;
  final String? cnpj;
  final String? telefone;
  final String? senha;
  final DateTime? dataCadastro;

  final StoreModel? loja;

  MerchantModel({
    this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.celular,
    this.cnpj,
    this.telefone,
    this.senha,
    this.dataCadastro,
    this.loja,
  });

  MerchantModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? cpf,
    String? celular,
    String? cnpj,
    String? telefone,
    String? senha,
    DateTime? dataCadastro,
    StoreModel? loja,
  }) {
    return MerchantModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      celular: celular ?? this.celular,
      cnpj: cnpj ?? this.cnpj,
      telefone: telefone ?? this.telefone,
      senha: senha ?? this.senha,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      loja: loja ?? this.loja,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'celular': celular,
      if (cnpj != null && cnpj!.isNotEmpty) 'cnpj': cnpj,
      if (telefone != null && telefone!.isNotEmpty) 'telefone': telefone,
      if (senha != null) 'senha': senha,
      if (dataCadastro != null)
        'data_cadastro': dataCadastro!.toIso8601String(),
    };
  }

  factory MerchantModel.fromMap(Map<String, dynamic> map) {
    return MerchantModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      celular: map['celular'] ?? '',
      cnpj: map['cnpj'],
      telefone: map['telefone'],
      senha: map['senha'],
      dataCadastro: map['data_cadastro'] != null
          ? DateTime.tryParse(map['data_cadastro'].toString())
          : null,
      loja: map['loja'] != null
          ? StoreModel.fromMap(map['loja'] as Map<String, dynamic>)
          : null,
    );
  }
}
