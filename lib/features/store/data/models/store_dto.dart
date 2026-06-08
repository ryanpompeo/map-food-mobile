class StoreDto {
  final int id;
  final String nome;
  final String? descricao;
  final String statusLoja;
  final String? dataCadastro;
  final String categoria;
  final List<String>? imagens;
  final double? avaliacao;

  const StoreDto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.statusLoja,
    this.dataCadastro,
    required this.categoria,
    this.imagens,
    this.avaliacao,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) => StoreDto(
    id: json['id'] as int,
    nome: json['nome'] as String,
    descricao: json['descricao'] as String?,
    statusLoja: json['statusLoja'] as String,
    dataCadastro: json['dataCadastro'] as String?,
    categoria: json['categoria'] as String,
    imagens: (json['imagens'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    avaliacao: json['avaliacao']?.toDouble(),
  );
}
