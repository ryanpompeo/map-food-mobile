class StoreCreateRequest {
  final String nome;
  final String? descricao;
  final String statusLoja;
  final List<int> categoriaIds;

  const StoreCreateRequest({
    required this.nome,
    this.descricao,
    required this.statusLoja,
    required this.categoriaIds,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        if (descricao != null) 'descricao': descricao,
        'statusLoja': statusLoja,
        'categorias': categoriaIds.map((id) => {'id': id}).toList(),
      };
}
