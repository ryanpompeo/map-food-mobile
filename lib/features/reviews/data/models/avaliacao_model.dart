/// Modelo de avaliação retornado pela API `/avaliacoes`.
class AvaliacaoModel {
  final int id;
  final int nota;
  final String? comentario;
  final String? dataAvaliacao;
  final ConsumidorResumido? consumidor;
  final int? lojaId;

  const AvaliacaoModel({
    required this.id,
    required this.nota,
    this.comentario,
    this.dataAvaliacao,
    this.consumidor,
    this.lojaId,
  });

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    ConsumidorResumido? consumidor;
    final c = json['consumidor'];
    if (c is Map<String, dynamic>) {
      consumidor = ConsumidorResumido.fromJson(c);
    }

    return AvaliacaoModel(
      id: (json['id'] as num).toInt(),
      nota: (json['nota'] as num).toInt(),
      comentario: json['comentario'] as String?,
      dataAvaliacao: json['dataAvaliacao']?.toString(),
      consumidor: consumidor,
      lojaId: (json['loja'] as Map<String, dynamic>?)?['id'] != null
          ? ((json['loja'] as Map<String, dynamic>)['id'] as num).toInt()
          : null,
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
