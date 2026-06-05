class StoreDto {
  final int id;
  final String nome;
  final String? descricao;
  final String statusLoja;
  final String? dataCadastro;

  const StoreDto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.statusLoja,
    this.dataCadastro,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) => StoreDto(
        id: json['id'] as int,
        nome: json['nome'] as String,
        descricao: json['descricao'] as String?,
        statusLoja: json['statusLoja'] as String,
        dataCadastro: json['dataCadastro'] as String?,
      );
}