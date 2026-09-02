import 'package:map_food/features/consumer/presentation/widgets/activity_chart.dart';

enum ActivityPeriod {
  semana('Semana'),
  mes('Mês'),
  ano('Ano');

  final String label;

  const ActivityPeriod(this.label);
}

class ActivitySummary {
  final List<ActivityPoint> points;

  final int total;

  final int? deltaPercentual;

  const ActivitySummary({
    required this.points,
    required this.total,
    required this.deltaPercentual,
  });
}

const _iniciaisDiaSemana = {1: 'S', 2: 'T', 3: 'Q', 4: 'Q', 5: 'S', 6: 'S', 7: 'D'};
const _iniciaisMes = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

ActivitySummary resumirAtividade(List<DateTime> datas, ActivityPeriod periodo) {
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);

  switch (periodo) {
    case ActivityPeriod.semana:
      return _porDia(datas, hoje, baldes: 7, diasPorBalde: 1);
    case ActivityPeriod.mes:
      return _porDia(datas, hoje, baldes: 6, diasPorBalde: 5);
    case ActivityPeriod.ano:
      return _porMes(datas, hoje);
  }
}

ActivitySummary _porDia(
  List<DateTime> datas,
  DateTime hoje, {
  required int baldes,
  required int diasPorBalde,
}) {
  final totalDias = baldes * diasPorBalde;
  final inicio = hoje.subtract(Duration(days: totalDias - 1));
  final inicioAnterior = inicio.subtract(Duration(days: totalDias));

  final contagem = List<int>.filled(baldes, 0);
  var anterior = 0;

  for (final data in datas) {
    final dia = DateTime(data.year, data.month, data.day);
    if (dia.isBefore(inicio)) {
      if (!dia.isBefore(inicioAnterior)) anterior++;
      continue;
    }
    if (dia.isAfter(hoje)) continue;
    final indice = dia.difference(inicio).inDays ~/ diasPorBalde;
    if (indice >= 0 && indice < baldes) contagem[indice]++;
  }

  final points = <ActivityPoint>[];
  for (var i = 0; i < baldes; i++) {
    final inicioBalde = inicio.add(Duration(days: i * diasPorBalde));
    points.add(ActivityPoint(
      label: diasPorBalde == 1
          ? _iniciaisDiaSemana[inicioBalde.weekday]!
          : '${inicioBalde.day}/${inicioBalde.month}',
      value: contagem[i],
    ));
  }

  return _montar(points, anterior);
}

ActivitySummary _porMes(List<DateTime> datas, DateTime hoje) {
  const baldes = 12;
  final inicio = DateTime(hoje.year, hoje.month - (baldes - 1), 1);
  final inicioAnterior = DateTime(hoje.year, hoje.month - (baldes * 2 - 1), 1);

  final contagem = List<int>.filled(baldes, 0);
  var anterior = 0;

  for (final data in datas) {
    final mes = DateTime(data.year, data.month, 1);
    if (mes.isBefore(inicio)) {
      if (!mes.isBefore(inicioAnterior)) anterior++;
      continue;
    }
    final indice = (mes.year - inicio.year) * 12 + (mes.month - inicio.month);
    if (indice >= 0 && indice < baldes) contagem[indice]++;
  }

  final points = <ActivityPoint>[];
  for (var i = 0; i < baldes; i++) {
    final mes = DateTime(inicio.year, inicio.month + i, 1);
    points.add(ActivityPoint(label: _iniciaisMes[mes.month - 1], value: contagem[i]));
  }

  return _montar(points, anterior);
}

ActivitySummary _montar(List<ActivityPoint> points, int anterior) {
  final total = points.fold(0, (soma, p) => soma + p.value);
  return ActivitySummary(
    points: points,
    total: total,
    deltaPercentual: anterior == 0 ? null : (((total - anterior) / anterior) * 100).round(),
  );
}
