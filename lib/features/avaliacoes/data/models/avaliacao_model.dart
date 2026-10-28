class AvaliacaoModel {
  final int id;
  final int nota;
  final String? comentario;
  final String? dataAvaliacao;
  final ConsumidorResumido? consumidor;
  final int? lojaId;
  final String? lojaNome;
  final String? lojaImagemUrl;

  final int totalLikes;
  final int totalDeslikes;
  final String? meuVoto;

  const AvaliacaoModel({
    required this.id,
    required this.nota,
    this.comentario,
    this.dataAvaliacao,
    this.consumidor,
    this.lojaId,
    this.lojaNome,
    this.lojaImagemUrl,
    this.totalLikes = 0,
    this.totalDeslikes = 0,
    this.meuVoto,
  });

  bool get curti => meuVoto == 'LIKE';

  bool get naoCurti => meuVoto == 'DESLIKE';

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
      totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
      totalDeslikes: (json['totalDeslikes'] as num?)?.toInt() ?? 0,
      meuVoto: json['meuVoto']?.toString(),
    );
  }

  AvaliacaoModel comVotos(VotosDaAvaliacao votos) => AvaliacaoModel(
        id: id,
        nota: nota,
        comentario: comentario,
        dataAvaliacao: dataAvaliacao,
        consumidor: consumidor,
        lojaId: lojaId,
        lojaNome: lojaNome,
        lojaImagemUrl: lojaImagemUrl,
        totalLikes: votos.totalLikes,
        totalDeslikes: votos.totalDeslikes,
        meuVoto: votos.meuVoto,
      );

  Map<String, dynamic> toJson() => {
        'nota': nota,
        if (comentario != null) 'comentario': comentario,
        'loja': {'id': lojaId},
      };
}

class VotosDaAvaliacao {
  final int totalLikes;
  final int totalDeslikes;
  final String? meuVoto;

  const VotosDaAvaliacao({
    required this.totalLikes,
    required this.totalDeslikes,
    this.meuVoto,
  });

  factory VotosDaAvaliacao.fromJson(Map<String, dynamic> json) => VotosDaAvaliacao(
        totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
        totalDeslikes: (json['totalDeslikes'] as num?)?.toInt() ?? 0,
        meuVoto: json['meuVoto']?.toString(),
      );
}

class ConsumidorResumido {
  final int id;
  final String nome;

  final String? imagemUrl;

  const ConsumidorResumido({
    required this.id,
    required this.nome,
    this.imagemUrl,
  });

  factory ConsumidorResumido.fromJson(Map<String, dynamic> json) =>
      ConsumidorResumido(
        id: (json['id'] as num).toInt(),
        nome: json['nome']?.toString() ?? '',
        imagemUrl: json['imagemUrl']?.toString(),
      );
}
