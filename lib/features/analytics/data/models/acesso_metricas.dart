class AcessoDiario {
  final DateTime data;
  final int quantidade;

  const AcessoDiario({required this.data, required this.quantidade});

  factory AcessoDiario.fromJson(Map<String, dynamic> json) => AcessoDiario(
        data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime(1970),
        quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
      );
}

class AcessoMetricas {
  final int totalAcessos;
  final List<AcessoDiario> porDia;

  const AcessoMetricas({required this.totalAcessos, required this.porDia});

  static const vazio = AcessoMetricas(totalAcessos: 0, porDia: []);

  factory AcessoMetricas.fromJson(Map<String, dynamic> json) {
    final dias = json['porDia'];
    return AcessoMetricas(
      totalAcessos: (json['totalAcessos'] as num?)?.toInt() ?? 0,
      porDia: dias is List
          ? dias
              .whereType<Map<String, dynamic>>()
              .map(AcessoDiario.fromJson)
              .toList()
          : const [],
    );
  }
}

String aaaaMmDd(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-'
    '${data.month.toString().padLeft(2, '0')}-'
    '${data.day.toString().padLeft(2, '0')}';
