/// Modelo de avaliação retornado pela API `/avaliacoes`.
class AvaliacaoModel {
  final int id;
  final int nota;
  final String? comentario;
  final String? dataAvaliacao;
  final ConsumidorResumido? consumidor;
  final int? lojaId;
  final String? lojaNome;
  final String? lojaImagemUrl;

  const AvaliacaoModel({
    required this.id,
    required this.nota,
    this.comentario,
    this.dataAvaliacao,
    this.consumidor,
    this.lojaId,
    this.lojaNome,
    this.lojaImagemUrl,
  });

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    ConsumidorResumido? consumidor;
    final c = json['consumidor'];
    if (c is Map<String, dynamic>) {
      consumidor = ConsumidorResumido.fromJson(c);
    }

    final loja = json['loja'] as Map<String, dynamic>?;

    return AvaliacaoModel(
      id: (json['id'] as num).toInt(),
      nota: (json['nota'] as num).toInt(),
      comentario: json['comentario'] as String?,
      dataAvaliacao: json['dataAvaliacao']?.toString(),
      consumidor: consumidor,
      lojaId: loja?['id'] != null ? (loja!['id'] as num).toInt() : null,
      lojaNome: loja?['nome'] as String?,
      lojaImagemUrl: loja?['imagemUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'nota': nota,
        if (comentario != null) 'comentario': comentario,
        'loja': {'id': lojaId},
      };
}

class ConsumidorResumido {
  final int id;
  final String nome;

  const ConsumidorResumido({required this.id, required this.nome});

  factory ConsumidorResumido.fromJson(Map<String, dynamic> json) =>
      ConsumidorResumido(
        id: (json['id'] as num).toInt(),
        nome: json['nome']?.toString() ?? '',
      );
}
