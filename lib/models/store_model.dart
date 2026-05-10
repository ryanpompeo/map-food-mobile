class StoreModel {
  final int? id;
  final String? nome;
  final String? descricao;
  final String? statusLoja;
  final int? idComerciante;
  final DateTime? dataCadastro;

  StoreModel({
    this.id,
    this.nome,
    this.descricao,
    this.statusLoja,
    this.idComerciante,
    this.dataCadastro,
  });

  StoreModel copyWith({
    int? id,
    String? nome,
    String? descricao,
    String? statusLoja,
    int? idComerciante,
    DateTime? dataCadastro,
  }) {
    return StoreModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      statusLoja: statusLoja ?? this.statusLoja,
      idComerciante: idComerciante ?? this.idComerciante,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (descricao != null) 'descricao': descricao,
      if (statusLoja != null) 'status_loja': statusLoja,
      if (idComerciante != null) 'id_comerciante': idComerciante,
      // Se a data for nula no app, não mandamos pro banco
      if (dataCadastro != null)
        'data_cadastro': dataCadastro!.toIso8601String(),
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      nome: map['nome'],
      descricao: map['descricao'],
      statusLoja: map['status_loja'],
      idComerciante: map['id_comerciante'] != null
          ? int.tryParse(map['id_comerciante'].toString())
          : null,
      dataCadastro: map['data_cadastro'] != null
          ? DateTime.tryParse(map['data_cadastro'].toString())
          : null,
    );
  }
}
