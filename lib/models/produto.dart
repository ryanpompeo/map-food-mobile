
import 'package:map_food/models/categoria.dart';
import 'package:map_food/models/loja.dart';

class Produto {
  int? id;
  String nome;
  double preco;
  String descricao;
  Categoria categoria;
  Loja? loja;

  Produto({
    this.id,
    required this.nome,
    required this.preco,
    required this.descricao,
    required this.categoria,
    this.loja,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      preco: (json['preco'] as num).toDouble(),
      descricao: json['descricao'],
      categoria: Categoria.fromJson(json['categoria']),
      loja: json['loja'] != null ? Loja.fromJson(json['loja']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'descricao': descricao,
      'categoria': categoria.toJson(),
      if (loja != null) 'loja': loja!.toJson(),
    };
  }
}
