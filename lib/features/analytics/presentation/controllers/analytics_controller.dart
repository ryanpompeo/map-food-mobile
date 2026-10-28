import 'package:flutter/foundation.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/utils/async_load_mixin.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/analytics/data/models/acesso_metricas.dart';
import 'package:map_food/features/analytics/data/services/acesso_service.dart';
import 'package:map_food/features/consumer/presentation/widgets/activity_chart.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

enum AnalyticsRange {
  seteDias('7 dias', 7),
  quinzeDias('15 dias', 15),
  trintaDias('30 dias', 30),
  noventaDias('90 dias', 90);

  final String label;
  final int dias;

  const AnalyticsRange(this.label, this.dias);
}

@immutable
class RatingBucket {
  final int nota;
  final int quantidade;

  const RatingBucket({required this.nota, required this.quantidade});
}

@immutable
class MotivoDenuncia {
  final String label;
  final int quantidade;

  const MotivoDenuncia({required this.label, required this.quantidade});
}

@immutable
class DenunciaResumo {
  final int total;
  final int emAberto;
  final int encerradas;

  final int? deltaPercentual;

  final List<MotivoDenuncia> porMotivo;

  final bool indisponivel;

  const DenunciaResumo({
    required this.total,
    required this.emAberto,
    required this.encerradas,
    required this.deltaPercentual,
    required this.porMotivo,
    this.indisponivel = false,
  });

  static const vazio = DenunciaResumo(
    total: 0,
    emAberto: 0,
    encerradas: 0,
    deltaPercentual: null,
    porMotivo: [],
  );

  static const naoCarregou = DenunciaResumo(
    total: 0,
    emAberto: 0,
    encerradas: 0,
    deltaPercentual: null,
    porMotivo: [],
    indisponivel: true,
  );

  bool get limpo => total == 0;
}

@immutable
class AcessoResumo {
  final int total;

  final List<AcessoDiario> porDia;

  final bool indisponivel;

  const AcessoResumo({
    required this.total,
    required this.porDia,
    this.indisponivel = false,
  });

  static const vazio = AcessoResumo(total: 0, porDia: []);

  static const naoCarregou = AcessoResumo(total: 0, porDia: [], indisponivel: true);
}

List<ActivityPoint> pontosDeAcesso(AcessoResumo acessos, int dias) {
  if (acessos.porDia.isEmpty) return const [];

  final ordenados = [...acessos.porDia]..sort((a, b) => a.data.compareTo(b.data));
  if (dias <= 7) {
    return [
      for (final dia in ordenados)
        ActivityPoint(label: _rotuloCurto(dia.data), value: dia.quantidade),
    ];
  }

  const blocos = 6;
  final tamanho = (ordenados.length / blocos).ceil();
  final pontos = <ActivityPoint>[];
  for (var inicio = 0; inicio < ordenados.length; inicio += tamanho) {
    final fim = (inicio + tamanho) > ordenados.length ? ordenados.length : inicio + tamanho;
    final fatia = ordenados.sublist(inicio, fim);
    pontos.add(ActivityPoint(
      label: _rotuloCurto(fatia.first.data),
      value: fatia.fold(0, (soma, dia) => soma + dia.quantidade),
    ));
  }
  return pontos;
}

String _rotuloCurto(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';

@immutable
class MesDeAvaliacoes {
  final DateTime mes;
  final int quantidade;
  final double? media;

  const MesDeAvaliacoes({
    required this.mes,
    required this.quantidade,
    required this.media,
  });
}

List<MesDeAvaliacoes> avaliacoesPorMes(
  List<AvaliacaoModel> avaliacoes,
  DateTime hoje, {
  int meses = 12,
}) {
  final soma = <DateTime, int>{};
  final total = <DateTime, int>{};

  for (final avaliacao in avaliacoes) {
    final data = DateTime.tryParse(avaliacao.dataAvaliacao ?? '');
    if (data == null) continue;
    final mes = DateTime(data.year, data.month);
    soma[mes] = (soma[mes] ?? 0) + avaliacao.nota;
    total[mes] = (total[mes] ?? 0) + 1;
  }

  final referencia = DateTime(hoje.year, hoje.month);
  return [
    for (var atras = meses - 1; atras >= 0; atras--)
      () {
        final mes = DateTime(referencia.year, referencia.month - atras);
        final quantidade = total[mes] ?? 0;
        return MesDeAvaliacoes(
          mes: mes,
          quantidade: quantidade,
          media: quantidade == 0 ? null : soma[mes]! / quantidade,
        );
      }(),
  ];
}

List<ActivityPoint> pontosPorMes(List<MesDeAvaliacoes> meses) => [
      for (final mes in meses)
        ActivityPoint(
          label: _rotuloDeMes(mes.mes),
          value: mes.quantidade,
        ),
    ];

const List<String> _mesesCurtos = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

String _rotuloDeMes(DateTime mes) => _mesesCurtos[mes.month - 1];

@immutable
class AnalyticsSnapshot {
  final List<RatingBucket> distribuicaoNotas;

  final double? mediaAvaliacao;
  final int totalAvaliacoes;

  final DenunciaResumo denuncias;

  final AcessoResumo acessos;

  final List<MesDeAvaliacoes> porMes;

  const AnalyticsSnapshot({
    required this.distribuicaoNotas,
    required this.mediaAvaliacao,
    required this.totalAvaliacoes,
    required this.denuncias,
    this.acessos = AcessoResumo.vazio,
    this.porMes = const [],
  });

  bool get semAvaliacoes => totalAvaliacoes == 0;
}

class AnalyticsController extends ChangeNotifier {
  AnalyticsController({
    required List<StoreDto> lojas,
    required this.comercianteId,
    AvaliacaoService? avaliacaoService,
    DenunciaService? denunciaService,
    AcessoService? acessoService,
  })  : _lojas = lojas,
        _avaliacaoService = avaliacaoService ?? AvaliacaoService(),
        _denunciaService = denunciaService ?? DenunciaService(),
        _acessoService = acessoService ?? AcessoService();

  final int? comercianteId;

  final AvaliacaoService _avaliacaoService;
  final DenunciaService _denunciaService;
  final AcessoService _acessoService;

  List<StoreDto> _lojas;
  List<StoreDto> get lojas => _lojas;

  int? _lojaSelecionadaId;
  int? get lojaSelecionadaId => _lojaSelecionadaId;

  AnalyticsRange _range = AnalyticsRange.seteDias;
  AnalyticsRange get range => _range;

  DateTime? _inicioEscolhido;
  DateTime? _fimEscolhido;

  bool get periodoPersonalizado => _inicioEscolhido != null && _fimEscolhido != null;

  DateTime get inicioDoPeriodo =>
      _inicioEscolhido ?? _hoje().subtract(Duration(days: _range.dias - 1));

  DateTime get fimDoPeriodo => _fimEscolhido ?? _hoje();

  int get diasDoPeriodo => fimDoPeriodo.difference(inicioDoPeriodo).inDays + 1;

  String get rotuloDoPeriodo => periodoPersonalizado
      ? '${_rotuloCurto(inicioDoPeriodo)} a ${_rotuloCurto(fimDoPeriodo)}'
      : _range.label;

  AsyncState<AnalyticsSnapshot> _state = const AsyncState.loading();
  AsyncState<AnalyticsSnapshot> get state => _state;

  int _requisicaoAtual = 0;

  bool _descartado = false;

  List<StoreDto> get _lojasDoEscopo => _lojaSelecionadaId == null
      ? _lojas
      : _lojas.where((l) => l.id == _lojaSelecionadaId).toList();

  void atualizarLojas(List<StoreDto> lojas) {
    final idsAntes = _lojas.map((l) => l.id).toSet();
    _lojas = lojas;

    final escopoOrfao =
        _lojaSelecionadaId != null && !lojas.any((l) => l.id == _lojaSelecionadaId);
    if (escopoOrfao) _lojaSelecionadaId = null;

    if (escopoOrfao || !setEquals(idsAntes, lojas.map((l) => l.id).toSet())) {
      carregar();
      return;
    }
    notifyListeners();
  }

  void selecionarLoja(int? lojaId) {
    if (_lojaSelecionadaId == lojaId) return;
    _lojaSelecionadaId = lojaId;
    notifyListeners();
    carregar();
  }

  void definirPeriodo(AnalyticsRange range) {
    if (_range == range && !periodoPersonalizado) return;
    _range = range;
    _inicioEscolhido = null;
    _fimEscolhido = null;
    notifyListeners();
    carregar();
  }

  void definirIntervalo(DateTime inicio, DateTime fim) {
    final comeco = DateTime(inicio.year, inicio.month, inicio.day);
    final termino = DateTime(fim.year, fim.month, fim.day);
    if (_inicioEscolhido == comeco && _fimEscolhido == termino) return;
    _inicioEscolhido = comeco;
    _fimEscolhido = termino;
    notifyListeners();
    carregar();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  Future<void> carregar() async {
    final token = ++_requisicaoAtual;
    _emitir(AsyncState.loading(data: _state.data));

    final lojas = _lojasDoEscopo;
    if (lojas.isEmpty) {
      _emitir(const AsyncState(data: _snapshotVazio));
      return;
    }

    final hoje = fimDoPeriodo;
    final inicioSerie = inicioDoPeriodo;

    var falhasAvaliacoes = 0;
    final avaliacoes = await Future.wait(
      lojas.map((loja) async {
        try {
          return await _avaliacaoService.buscarAvaliacoesDaLoja(loja.id);
        } catch (_) {
          falhasAvaliacoes++;
          return const <AvaliacaoModel>[];
        }
      }),
    );

    var falhasAcessos = 0;
    final acessos = await Future.wait(
      lojas.map((loja) async {
        try {
          return await _acessoService.buscarMetricas(
            loja.id,
            inicio: inicioSerie,
            fim: hoje,
          );
        } catch (_) {
          falhasAcessos++;
          return AcessoMetricas.vazio;
        }
      }),
    );

    final id = comercianteId;
    List<DenunciaRecebidaModel>? denuncias;
    if (id != null) {
      try {
        denuncias = await _denunciaService.getRecebidas(id);
      } catch (_) {
      }
    }

    if (token != _requisicaoAtual) return;

    if (falhasAvaliacoes == lojas.length && denuncias == null) {
      _emitir(AsyncState(
        data: _state.data,
        errorMessage: const NetworkException().message,
      ));
      return;
    }

    _emitir(AsyncState(
      data: _montarSnapshot(
        lojas: lojas,
        avaliacoes: avaliacoes.expand((e) => e).toList(),
        denuncias: denuncias,
        acessos: falhasAcessos == lojas.length ? null : acessos,
        inicioSerie: inicioSerie,
        hoje: hoje,
      ),
    ));
  }

  void _emitir(AsyncState<AnalyticsSnapshot> novo) {
    if (_descartado) return;
    _state = novo;
    notifyListeners();
  }

  AnalyticsSnapshot _montarSnapshot({
    required List<StoreDto> lojas,
    required List<AvaliacaoModel> avaliacoes,
    required List<DenunciaRecebidaModel>? denuncias,
    required List<AcessoMetricas>? acessos,
    required DateTime inicioSerie,
    required DateTime hoje,
  }) {
    final notas = <int, int>{};
    for (final avaliacao in avaliacoes) {
      notas[avaliacao.nota] = (notas[avaliacao.nota] ?? 0) + 1;
    }
    final distribuicao = [
      for (var nota = 5; nota >= 1; nota--)
        if ((notas[nota] ?? 0) > 0) RatingBucket(nota: nota, quantidade: notas[nota]!),
    ];

    final mediaAvaliacao = avaliacoes.isEmpty
        ? null
        : avaliacoes.fold(0, (soma, a) => soma + a.nota) / avaliacoes.length;

    return AnalyticsSnapshot(
      distribuicaoNotas: distribuicao,
      mediaAvaliacao: mediaAvaliacao,
      totalAvaliacoes: avaliacoes.length,
      acessos: somarAcessos(acessos),
      porMes: avaliacoesPorMes(avaliacoes, hoje),
      denuncias: _resumirDenuncias(
        denuncias: denuncias,
        lojas: lojas,
        inicioSerie: inicioSerie,
        hoje: hoje,
      ),
    );
  }

  static AcessoResumo somarAcessos(List<AcessoMetricas>? metricas) {
    if (metricas == null) return AcessoResumo.naoCarregou;
    if (metricas.isEmpty) return AcessoResumo.vazio;

    final porDia = <DateTime, int>{};
    var total = 0;
    for (final metrica in metricas) {
      total += metrica.totalAcessos;
      for (final dia in metrica.porDia) {
        final chave = DateTime(dia.data.year, dia.data.month, dia.data.day);
        porDia[chave] = (porDia[chave] ?? 0) + dia.quantidade;
      }
    }

    final dias = porDia.keys.toList()..sort();
    return AcessoResumo(
      total: total,
      porDia: [
        for (final dia in dias) AcessoDiario(data: dia, quantidade: porDia[dia]!),
      ],
    );
  }

  DenunciaResumo _resumirDenuncias({
    required List<DenunciaRecebidaModel>? denuncias,
    required List<StoreDto> lojas,
    required DateTime inicioSerie,
    required DateTime hoje,
  }) {
    if (denuncias == null) return DenunciaResumo.naoCarregou;
    if (denuncias.isEmpty) return DenunciaResumo.vazio;

    final idsDoEscopo = lojas.map((l) => l.id).toSet();
    final inicioAnterior = inicioSerie.subtract(Duration(days: diasDoPeriodo));
    final fim = hoje.add(const Duration(days: 1));

    final noPeriodo = <DenunciaRecebidaModel>[];
    var anterior = 0;

    for (final denuncia in denuncias) {
      if (!idsDoEscopo.contains(denuncia.lojaId)) continue;
      final data = denuncia.dataDenuncia;
      if (data == null || (!data.isBefore(inicioSerie) && data.isBefore(fim))) {
        noPeriodo.add(denuncia);
      } else if (!data.isBefore(inicioAnterior) && data.isBefore(inicioSerie)) {
        anterior++;
      }
    }

    if (noPeriodo.isEmpty && anterior == 0) return DenunciaResumo.vazio;

    final porMotivo = <String, int>{};
    var emAberto = 0;
    for (final denuncia in noPeriodo) {
      porMotivo[denuncia.motivoLabel] = (porMotivo[denuncia.motivoLabel] ?? 0) + 1;
      if (denuncia.emAberto) emAberto++;
    }

    final motivos = porMotivo.entries
        .map((e) => MotivoDenuncia(label: e.key, quantidade: e.value))
        .toList()
      ..sort((a, b) => b.quantidade.compareTo(a.quantidade));

    return DenunciaResumo(
      total: noPeriodo.length,
      emAberto: emAberto,
      encerradas: noPeriodo.length - emAberto,
      deltaPercentual: anterior == 0
          ? null
          : (((noPeriodo.length - anterior) / anterior) * 100).round(),
      porMotivo: motivos,
    );
  }

  static DateTime _hoje() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  static const _snapshotVazio = AnalyticsSnapshot(
    distribuicaoNotas: [],
    mediaAvaliacao: null,
    totalAvaliacoes: 0,
    denuncias: DenunciaResumo.vazio,
  );
}
