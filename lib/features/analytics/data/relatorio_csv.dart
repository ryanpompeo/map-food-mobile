import 'package:map_food/features/analytics/data/models/acesso_metricas.dart';
import 'package:map_food/features/analytics/presentation/controllers/analytics_controller.dart';

const String _separador = ';';

String _numero(double valor) => valor.toStringAsFixed(1).replaceAll('.', ',');

String _dataBr(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/'
    '${data.month.toString().padLeft(2, '0')}/${data.year}';

String _mesAno(DateTime mes) =>
    '${mes.month.toString().padLeft(2, '0')}/${mes.year}';

String relatorioCsv({
  required AnalyticsSnapshot snapshot,
  required DateTime inicio,
  required DateTime fim,
  required String escopo,
}) {
  final linhas = <String>[
    'MapFood${_separador}relatório do comerciante',
    'Escopo$_separador$escopo',
    'Período$_separador${_dataBr(inicio)} a ${_dataBr(fim)}',
    '',
    'Resumo',
    'Total de visitas$_separador${snapshot.acessos.indisponivel ? 'não carregou' : snapshot.acessos.total}',
    'Total de avaliações$_separador${snapshot.totalAvaliacoes}',
    'Média das avaliações$_separador'
        '${snapshot.mediaAvaliacao == null ? 'sem avaliação' : _numero(snapshot.mediaAvaliacao!)}',
    'Denúncias no período$_separador'
        '${snapshot.denuncias.indisponivel ? 'não carregou' : snapshot.denuncias.total}',
    '',
    'Visitas por dia',
    'Data${_separador}Visitas',
  ];

  for (final dia in snapshot.acessos.porDia) {
    linhas.add('${aaaaMmDd(dia.data)}$_separador${dia.quantidade}');
  }
  if (snapshot.acessos.porDia.isEmpty) {
    linhas.add('sem visitas no período${_separador}0');
  }

  linhas
    ..add('')
    ..add('Avaliações por mês')
    ..add('Mês${_separador}Quantidade${_separador}Média');

  for (final mes in snapshot.porMes) {
    linhas.add(
      '${_mesAno(mes.mes)}$_separador${mes.quantidade}$_separador'
      '${mes.media == null ? '' : _numero(mes.media!)}',
    );
  }

  linhas
    ..add('')
    ..add('Denúncias por motivo')
    ..add('Motivo${_separador}Quantidade');

  for (final motivo in snapshot.denuncias.porMotivo) {
    linhas.add('${motivo.label}$_separador${motivo.quantidade}');
  }
  if (snapshot.denuncias.porMotivo.isEmpty) {
    linhas.add('sem denúncias no período${_separador}0');
  }

  return linhas.join('\r\n');
}

String nomeDoArquivoCsv(DateTime inicio, DateTime fim) =>
    'mapfood-${aaaaMmDd(inicio)}-a-${aaaaMmDd(fim)}.csv';
