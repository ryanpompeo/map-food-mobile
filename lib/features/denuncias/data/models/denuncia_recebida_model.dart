import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';

class DenunciaRecebidaModel {
  final int id;

  final String motivo;

  final String? descricao;
  final DateTime? dataDenuncia;

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

  bool get emAberto => statusDenuncia == 'PENDENTE' || statusDenuncia == 'EM_ANALISE';

  String get motivoLabel => MotivosDenuncia.fromApi(motivo);
}
