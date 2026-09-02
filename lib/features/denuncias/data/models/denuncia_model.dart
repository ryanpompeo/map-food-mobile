class DenunciaModel {
  final int id;
  final String motivo;
  final String? descricao;
  final String statusDenuncia;
  final String? dataDenuncia;
  final String lojaNome;

  const DenunciaModel({
    required this.id,
    required this.motivo,
    this.descricao,
    required this.statusDenuncia,
    this.dataDenuncia,
    required this.lojaNome,
  });

  factory DenunciaModel.fromJson(Map<String, dynamic> json) => DenunciaModel(
        id: (json['id'] as num).toInt(),
        motivo: json['motivo']?.toString() ?? '',
        descricao: json['descricao'] as String?,
        statusDenuncia: json['statusDenuncia']?.toString() ?? 'PENDENTE',
        dataDenuncia: json['dataDenuncia']?.toString(),
        lojaNome: (json['loja'] as Map<String, dynamic>?)?['nome']?.toString() ?? 'Comércio removido',
      );
}

class MotivosDenuncia {
  static const Map<String, String> uiParaApi = {
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

  static List<String> get uiLabels => uiParaApi.keys.toList();
}
