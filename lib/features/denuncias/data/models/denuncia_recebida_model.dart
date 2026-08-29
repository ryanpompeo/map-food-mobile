import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';

/// Denúncia **contra** uma loja do comerciante, como devolvida por
/// `GET /denuncias/loja/comerciante/{id}` (`DenunciaRecebidaResponse` na API).
///
/// É um formato diferente do [DenunciaModel] usado pelo consumidor: a API
/// omite de propósito quem denunciou (sigilo do denunciante) e envia a loja
/// achatada em `lojaId`/`lojaNome`, em vez do objeto `loja` aninhado. Ler esta
/// resposta com o model do consumidor devolvia "Comércio removido" em todo
/// nome de loja — passou despercebido porque o único consumo até aqui usava
/// apenas o tamanho da lista.
class DenunciaRecebidaModel {
  final int id;

  /// Enum cru da API (`FRAUDE_OU_GOLPE`, `SPAM`...). Use
  /// [MotivosDenuncia.fromApi] para exibir.
  final String motivo;

  final String? descricao;
  final DateTime? dataDenuncia;

  /// `PENDENTE`, `EM_ANALISE`, `RESOLVIDA` ou `ARQUIVADA`.
  final String statusDenuncia;

  final int lojaId;
  final String lojaNome;

  const DenunciaRecebidaModel({
    required this.id,
    required this.motivo,
    this.descricao,
    this.dataDenuncia,
    required this.statusDenuncia,
    required this.lojaId,
    required this.lojaNome,
  });

  factory DenunciaRecebidaModel.fromJson(Map<String, dynamic> json) {
    return DenunciaRecebidaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      motivo: json['motivo']?.toString() ?? 'OUTRO',
      descricao: json['descricao'] as String?,
      dataDenuncia: DateTime.tryParse(json['dataDenuncia']?.toString() ?? ''),
      statusDenuncia: json['statusDenuncia']?.toString() ?? 'PENDENTE',
      lojaId: (json['lojaId'] as num?)?.toInt() ?? 0,
      lojaNome: json['lojaNome']?.toString() ?? '',
    );
  }

  /// Denúncia que ainda pesa contra a loja. `RESOLVIDA`/`ARQUIVADA` já passaram
  /// pela moderação e não exigem mais nada do comerciante — contá-las junto
  /// faria o painel cobrar por algo que já foi encerrado.
  bool get emAberto => statusDenuncia == 'PENDENTE' || statusDenuncia == 'EM_ANALISE';

  /// Rótulo de exibição do motivo.
  String get motivoLabel => MotivosDenuncia.fromApi(motivo);
}
