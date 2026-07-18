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
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final double? latitude;
  final double? longitude;

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
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.latitude,
    this.longitude,
  });

  /// true quando a loja tem coordenadas suficientes para aparecer no mapa.
  bool get temLocalizacao => latitude != null && longitude != null;

  /// Endereço legível pra exibição (ex: "Rua X, Cidade - UF").
  String? get enderecoCompleto {
    final partes = [
      if (endereco != null && endereco!.isNotEmpty) endereco,
      if (cidade != null && cidade!.isNotEmpty)
        estado != null && estado!.isNotEmpty ? '$cidade - $estado' : cidade,
    ];
    return partes.isEmpty ? null : partes.join(', ');
  }

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
        endereco: json['endereco'] as String?,
        cidade: json['cidade'] as String?,
        estado: json['estado'] as String?,
        cep: json['cep'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
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
  /// Suporta: `categorias: [{id, nome}]` (endpoints legados) ou
  /// `categorias: ["nome", ...]` (endpoints /mobile/api/v1/lojas, que não
  /// expõem id — só nome, pra listagem/leitura, não pra edição).
  static List<String> _parseCategoriaNames(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List) {
      return cats
          .map<String>((e) {
            if (e is Map) return e['nome']?.toString() ?? '';
            return e.toString();
          })
          .where((name) => name.isNotEmpty)
          .toList();
    }
    final fallback = json['categoria']?.toString();
    if (fallback != null && fallback.isNotEmpty) return [fallback];
    return [];
  }

  /// Extrai lista de IDs das categorias. Suporta `categorias: [{id, nome}]`
  /// ou `categorias: [int]`; entradas sem id (ex: lista de nomes crus vinda
  /// de /mobile/api/v1/lojas) são ignoradas — essas telas não editam a loja,
  /// só listam/exibem.
  static List<int> _parseCategoriaIds(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List) {
      return cats
          .map<int?>((e) {
            if (e is Map) return (e['id'] as num?)?.toInt();
            if (e is num) return e.toInt();
            return null;
          })
          .whereType<int>()
          .toList();
    }
    return [];
  }
}
