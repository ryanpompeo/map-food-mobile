import 'package:map_food/models/produto.dart';

class Loja {
  String? id;
  String? nome;
  String? descricao;
  String? endereco;
  List<String>? categorias; // várias categorias agora
  List<Produto>? produtos; // lista de produtos
  String? idVendedor; // vínculo com vendedor

  Loja({
    this.id,
    this.nome,
    this.descricao,
    this.endereco,
    this.categorias,
    this.produtos,
    this.idVendedor,
  });

  Loja.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    descricao = json['descricao'];
    endereco = json['endereco'];
    categorias = json['categorias'] != null
        ? List<String>.from(json['categorias'])
        : [];
    produtos = json['produtos'] != null
        ? (json['produtos'] as List).map((p) => Produto.fromJson(p)).toList()
        : [];
    idVendedor = json['idVendedor'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    data['descricao'] = descricao;
    data['endereco'] = endereco;
    data['categorias'] = categorias ?? [];
    data['produtos'] = produtos?.map((p) => p.toJson()).toList() ?? [];
    data['idVendedor'] = idVendedor;
    return data;
  }
}
