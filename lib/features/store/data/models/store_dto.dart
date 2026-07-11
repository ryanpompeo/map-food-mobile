class StoreDto {
  final int id;
  final String nome;
  final String? descricao;
  final String statusLoja;
  final String? dataCadastro;
  final String categoria;       // Nome da 1ª categoria (cards / chips de busca)
  final List<int> categoriaIds; // IDs para edição de loja
  final List<String> categoriaNomes; // Todos os nomes (tela de detalhes)
  final String? imagemUrl; // Foto de capa
  final List<String> galeria; // Fotos internas (cardápio/vitrine)
  final double? avaliacao;
  final int totalAvaliacoes;

  const StoreDto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.statusLoja,
    this.dataCadastro,
    required this.categoria,
    this.categoriaIds = const [],
    this.categoriaNomes = const [],
    this.imagemUrl,
    this.galeria = const [],
    this.avaliacao,
    this.totalAvaliacoes = 0,
  });

  /// Uma foto representativa da loja, pra widgets que só precisam de uma
  /// imagem (cards de busca, favoritos): a capa, ou a primeira da galeria
  /// se não houver capa definida.
  String? get capaUrl => imagemUrl ?? (galeria.isNotEmpty ? galeria.first : null);

  factory StoreDto.fromJson(Map<String, dynamic> json) => StoreDto(
        id: (json['id'] as num).toInt(),
        nome: json['nome']?.toString() ?? '',
        descricao: json['descricao'] as String?,
        statusLoja: json['statusLoja']?.toString() ?? 'INATIVA',
        dataCadastro: json['dataCadastro'] as String?,
        categoria: _parseCategoriaName(json),
        categoriaIds: _parseCategoriaIds(json),
        categoriaNomes: _parseCategoriaNames(json),
        imagemUrl: json['imagemUrl'] as String?,
        galeria: (json['galeria'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        // Suporta campo 'avaliacao' (legado) ou 'mediaAvaliacao' (endpoint /search)
        avaliacao: (json['mediaAvaliacao'] as num?)?.toDouble() ??
            (json['avaliacao'] as num?)?.toDouble(),
        totalAvaliacoes: (json['totalAvaliacoes'] as num?)?.toInt() ?? 0,
      );

  /// Extrai o nome da primeira categoria para exibição nos cards.
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

  /// Extrai todos os nomes de categoria para exibição na tela de detalhes.
  /// Suporta: `categorias: [{id, nome}]`.
  static List<String> _parseCategoriaNames(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List) {
      return cats
          .map<String>((e) {
            if (e is Map) return e['nome']?.toString() ?? '';
            return '';
          })
          .where((name) => name.isNotEmpty)
          .toList();
    }
    final fallback = json['categoria']?.toString();
    if (fallback != null && fallback.isNotEmpty) return [fallback];
    return [];
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
