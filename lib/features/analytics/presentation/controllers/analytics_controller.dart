import 'package:flutter/foundation.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/utils/async_load_mixin.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

enum AnalyticsRange {
  seteDias('7 dias', 7),
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
class AnalyticsSnapshot {
  final List<RatingBucket> distribuicaoNotas;

  final double? mediaAvaliacao;
  final int totalAvaliacoes;

  final DenunciaResumo denuncias;

  const AnalyticsSnapshot({
    required this.distribuicaoNotas,
    required this.mediaAvaliacao,
    required this.totalAvaliacoes,
    required this.denuncias,
  });

  bool get semAvaliacoes => totalAvaliacoes == 0;
}

class AnalyticsController extends ChangeNotifier {
  AnalyticsController({
    required List<StoreDto> lojas,
    required this.comercianteId,
    AvaliacaoService? avaliacaoService,
    DenunciaService? denunciaService,
  })  : _lojas = lojas,
        _avaliacaoService = avaliacaoService ?? AvaliacaoService(),
        _denunciaService = denunciaService ?? DenunciaService();

  final int? comercianteId;

  final AvaliacaoService _avaliacaoService;
  final DenunciaService _denunciaService;

  List<StoreDto> _lojas;
  List<StoreDto> get lojas => _lojas;

  int? _lojaSelecionadaId;
  int? get lojaSelecionadaId => _lojaSelecionadaId;

  AnalyticsRange _range = AnalyticsRange.seteDias;
  AnalyticsRange get range => _range;

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
    if (_range == range) return;
    _range = range;
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

    final hoje = _hoje();
    final inicioSerie = hoje.subtract(Duration(days: _range.dias - 1));

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
      denuncias: _resumirDenuncias(
        denuncias: denuncias,
        lojas: lojas,
        inicioSerie: inicioSerie,
        hoje: hoje,
      ),
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
    final inicioAnterior = inicioSerie.subtract(Duration(days: _range.dias));
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
