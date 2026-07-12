/// Avaliação feita pelo consumidor logado, do ponto de vista de "Minhas
/// Avaliações" — retornada por GET /avaliacoes/consumidor/{id}. Carrega
/// [lojaId]/[nomeLoja] direto (sem objeto Loja aninhado) para montar o
/// deep link pra tela da loja sem round-trip extra.
class MinhaAvaliacaoModel {
  final int lojaId;
  final String nomeLoja;
  final int nota;
  final String? comentario;
  final String? dataCriacao;

  const MinhaAvaliacaoModel({
    required this.lojaId,
    required this.nomeLoja,
    required this.nota,
    this.comentario,
    this.dataCriacao,
  });

  factory MinhaAvaliacaoModel.fromJson(Map<String, dynamic> json) => MinhaAvaliacaoModel(
        lojaId: (json['lojaId'] as num).toInt(),
        nomeLoja: json['nomeLoja']?.toString() ?? '',
        nota: (json['nota'] as num).toInt(),
        comentario: json['comentario'] as String?,
        dataCriacao: json['dataCriacao']?.toString(),
      );
}
