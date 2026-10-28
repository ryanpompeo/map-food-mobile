class DenunciaModel {
  final int id;
  final String motivo;
  final String? descricao;
  final String statusDenuncia;
  final String? dataDenuncia;
  final String lojaNome;

  final String? respostaComerciante;
  final DateTime? dataResposta;
  final DateTime? prazoResposta;

  const DenunciaModel({
    required this.id,
    required this.motivo,
    this.descricao,
    required this.statusDenuncia,
    this.dataDenuncia,
    required this.lojaNome,
    this.respostaComerciante,
    this.dataResposta,
    this.prazoResposta,
  });

  bool get temResposta => (respostaComerciante?.trim().isNotEmpty) ?? false;

  bool esperandoResposta(DateTime agora) =>
      !temResposta && prazoResposta != null && prazoResposta!.isAfter(agora);

  factory DenunciaModel.fromJson(Map<String, dynamic> json) => DenunciaModel(
        id: (json['id'] as num).toInt(),
        motivo: json['motivo']?.toString() ?? '',
        descricao: json['descricao'] as String?,
        statusDenuncia: json['statusDenuncia']?.toString() ?? 'PENDENTE',
        dataDenuncia: json['dataDenuncia']?.toString(),
        lojaNome: (json['loja'] as Map<String, dynamic>?)?['nome']?.toString() ?? 'Comércio removido',
        respostaComerciante: json['respostaComerciante'] as String?,
        dataResposta: DateTime.tryParse(json['dataResposta']?.toString() ?? ''),
        prazoResposta: DateTime.tryParse(json['prazoResposta']?.toString() ?? ''),
      );
}

class MotivosDenuncia {
  static const Map<String, String> uiParaApi = {
    'Risco sanitário': 'RISCO_SANITARIO',
    'Conteúdo inapropriado': 'CONTEUDO_INAPROPRIADO',
    'Fraude ou golpe': 'FRAUDE_OU_GOLPE',
    'Informações falsas': 'INFORMACOES_FALSAS',
    'Spam': 'SPAM',
    'Outro': 'OUTRO',
  };

  static String toApi(String uiLabel) =>
      uiParaApi[uiLabel] ?? 'OUTRO';

  static String fromApi(String apiValue) {
    for (final entry in uiParaApi.entries) {
      if (entry.value == apiValue) return entry.key;
    }
    return 'Outro';
  }

  static const Set<String> motivosQueOAppAindaNaoCria = {'Risco sanitário'};

  static List<String> get uiLabels => uiParaApi.keys
      .where((rotulo) => !motivosQueOAppAindaNaoCria.contains(rotulo))
      .toList();
}
