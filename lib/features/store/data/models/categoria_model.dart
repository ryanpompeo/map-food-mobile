/// Modelo de categoria retornado por GET /categorias.
class CategoriaModel {
  final int id;
  final String nome;

  const CategoriaModel({required this.id, required this.nome});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) => CategoriaModel(
        id: (json['id'] as num).toInt(),
        nome: json['nome']?.toString() ?? '',
      );
}
