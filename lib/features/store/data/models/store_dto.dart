class StoreDto {
  final int id;
  final String nome;
  final String? descricao;
  final String statusLoja;
  final String? dataCadastro;
  final String categoria; // nome da 1ª categoria (para exibição)
  final List<int> categoriaIds; // IDs para edição
  final List<String>? imagens;
  final double? avaliacao;

  const StoreDto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.statusLoja,
    this.dataCadastro,
    required this.categoria,
    this.categoriaIds = const [],
    this.imagens,
    this.avaliacao,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) => StoreDto(
        id: (json['id'] as num).toInt(),
        nome: json['nome']?.toString() ?? '',
        descricao: json['descricao'] as String?,
        statusLoja: json['statusLoja']?.toString() ?? 'INATIVA',
        dataCadastro: json['dataCadastro'] as String?,
        categoria: _parseCategoriaName(json),
        categoriaIds: _parseCategoriaIds(json),
        imagens: (json['imagens'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        avaliacao: (json['avaliacao'] as num?)?.toDouble(),
      );

  /// Extrai o nome da primeira categoria.
  /// Suporta: `categorias: [{id, nome}]`, `categorias: [int]` ou `categoria: "string"`
  static String _parseCategoriaName(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List && cats.isNotEmpty) {
      final first = cats.first;
      if (first is Map) return first['nome']?.toString() ?? '';
      return first.toString();
    }
    return json['categoria']?.toString() ?? '';
  }

  /// Extrai lista de IDs das categorias.
  /// Suporta: `categorias: [{id, nome}]` ou `categorias: [int]`
  static List<int> _parseCategoriaIds(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List) {
      return cats.map<int>((e) {
        if (e is Map) return (e['id'] as num).toInt();
        return (e as num).toInt();
      }).toList();
    }
    return [];
  }
}
