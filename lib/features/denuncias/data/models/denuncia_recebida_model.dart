import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';

class DenunciaRecebidaModel {
  final int id;

  final String motivo;

  final String? descricao;
  final DateTime? dataDenuncia;

  final String statusDenuncia;

  final int lojaId;
  final String lojaNome;

  final DateTime? dataConsumo;
  final String? itemConsumido;
  final String? fotoUrl;

  final String? respostaComerciante;
  final DateTime? dataResposta;
  final DateTime? prazoResposta;

  const DenunciaRecebidaModel({
    required this.id,
    required this.motivo,
    this.descricao,
    this.dataDenuncia,
    required this.statusDenuncia,
    required this.lojaId,
    required this.lojaNome,
    this.dataConsumo,
    this.itemConsumido,
    this.fotoUrl,
    this.respostaComerciante,
    this.dataResposta,
    this.prazoResposta,
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
      dataConsumo: DateTime.tryParse(json['dataConsumo']?.toString() ?? ''),
      itemConsumido: json['itemConsumido'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      respostaComerciante: json['respostaComerciante'] as String?,
      dataResposta: DateTime.tryParse(json['dataResposta']?.toString() ?? ''),
      prazoResposta: DateTime.tryParse(json['prazoResposta']?.toString() ?? ''),
    );
  }

  bool get emAberto => statusDenuncia == 'PENDENTE' || statusDenuncia == 'EM_ANALISE';

  String get motivoLabel => MotivosDenuncia.fromApi(motivo);

  bool get jaRespondida => (respostaComerciante?.trim().isNotEmpty) ?? false;

  bool get abreDireitoDeResposta => prazoResposta != null;

  bool prazoAberto(DateTime agora) =>
      prazoResposta != null && prazoResposta!.isAfter(agora);

  bool podeResponder(DateTime agora) => !jaRespondida && prazoAberto(agora);

  DenunciaRecebidaModel comResposta(String texto, DateTime quando) =>
      DenunciaRecebidaModel(
        id: id,
        motivo: motivo,
        descricao: descricao,
        dataDenuncia: dataDenuncia,
        statusDenuncia: 'EM_ANALISE',
        lojaId: lojaId,
        lojaNome: lojaNome,
        dataConsumo: dataConsumo,
        itemConsumido: itemConsumido,
        fotoUrl: fotoUrl,
        respostaComerciante: texto,
        dataResposta: quando,
        prazoResposta: prazoResposta,
      );
}
