import 'package:flutter/foundation.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/utils/async_load_mixin.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Janela de tempo do painel: recorta as denúncias e a divisão de visitantes
/// entre as lojas.
enum AnalyticsRange {
  seteDias('7 dias', 7),
  trintaDias('30 dias', 30),
  noventaDias('90 dias', 90);

  final String label;
  final int dias;

  const AnalyticsRange(this.label, this.dias);
}

/// Quantas avaliações a loja recebeu com determinada nota.
@immutable
class RatingBucket {
  final int nota;
  final int quantidade;

  const RatingBucket({required this.nota, required this.quantidade});
}

/// Quantas denúncias chegaram por um mesmo motivo.
@immutable
class MotivoDenuncia {
  final String label;
  final int quantidade;

  const MotivoDenuncia({required this.label, required this.quantidade});
}

/// Denúncias do período, prontas para leitura.
///
/// Separa **em aberto** de **encerradas** porque as duas dizem coisas opostas
/// ao comerciante: uma denúncia arquivada pela moderação não é um problema
/// dele, e somar tudo num número só transformaria um caso resolvido em dívida
/// permanente na tela.
@immutable
class DenunciaResumo {
  final int total;
  final int emAberto;
  final int encerradas;

  /// Contra o período anterior de mesma duração. `null` sem base de comparação.
  final int? deltaPercentual;

  final List<MotivoDenuncia> porMotivo;

  /// `true` quando a busca falhou. Diferente de [limpo]: uma coisa é não ter
  /// denúncia, outra é não ter conseguido perguntar — anunciar "nada por aqui"
  /// sem saber seria dar ao comerciante uma tranquilidade que não se apurou.
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

/// Tudo que a tela desenha, já calculado. Sem `Color` e sem widget: as cores
/// entram na montagem das fatias, onde existe tema (ver [DonutSlice]).
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

/// Estado da tela de Estatísticas: escopo, período e a busca que os alimenta.
///
/// Existe como `ChangeNotifier` (e não como `setState` na página) porque a
/// mesma busca é disparada por três gatilhos diferentes — troca de loja, troca
/// de período e recarga manual — e todos precisam passar pelo mesmo controle
/// de corrida.
class AnalyticsController extends ChangeNotifier {
  AnalyticsController({
    required List<StoreDto> lojas,
    required this.comercianteId,
    AvaliacaoService? avaliacaoService,
    DenunciaService? denunciaService,
  })  : _lojas = lojas,
        _avaliacaoService = avaliacaoService ?? AvaliacaoService(),
        _denunciaService = denunciaService ?? DenunciaService();

  /// Dono das lojas. `null` (sessão perdida) desliga o bloco de denúncias — a
  /// rota é por comerciante, não por loja.
  final int? comercianteId;

  final AvaliacaoService _avaliacaoService;
  final DenunciaService _denunciaService;

  List<StoreDto> _lojas;
  List<StoreDto> get lojas => _lojas;

  /// `null` = "Dados gerais" (todas as lojas do comerciante).
  int? _lojaSelecionadaId;
  int? get lojaSelecionadaId => _lojaSelecionadaId;

  AnalyticsRange _range = AnalyticsRange.seteDias;
  AnalyticsRange get range => _range;

  AsyncState<AnalyticsSnapshot> _state = const AsyncState.loading();
  AsyncState<AnalyticsSnapshot> get state => _state;

  /// Descarta respostas de buscas superadas. Trocar de período duas vezes
  /// seguidas deixa duas requisições em voo, e a primeira pode chegar por
  /// último — sem este token, a tela terminaria mostrando o período errado.
  int _requisicaoAtual = 0;

  bool _descartado = false;

  /// Lojas do escopo atual: uma só, ou todas quando nenhuma está selecionada.
  List<StoreDto> get _lojasDoEscopo => _lojaSelecionadaId == null
      ? _lojas
      : _lojas.where((l) => l.id == _lojaSelecionadaId).toList();

  /// Chamado pelo pai quando a lista de lojas muda (loja criada, excluída ou
  /// renomeada). Se a loja em foco sumiu, o escopo volta para "gerais" — um
  /// filtro apontando para loja inexistente deixaria a tela vazia sem explicar.
  ///
  /// Só rebusca quando o **conjunto de lojas** mudou: renomear uma loja altera
  /// o rótulo do seletor, mas não os números, e uma rodada de requisições para
  /// redesenhar o mesmo gráfico é rede gasta à toa.
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
    // Início do período exibido. O período anterior de mesma duração (a base
    // do delta) é calculado a partir daqui, dentro do resumo de denúncias.
    final inicioSerie = hoje.subtract(Duration(days: _range.dias - 1));

    // Falha de uma loja não pode zerar a rosca das outras: cada busca devolve
    // lista vazia no lugar de propagar a exceção. Só quando **todas** falham é
    // que a tela vira erro — senão o painel mostraria "nenhuma avaliação" com
    // ar de dado real enquanto a rede está fora.
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

    // Uma chamada só, independente do escopo: a rota de denúncias é por
    // comerciante, e o recorte por loja é feito aqui embaixo.
    final id = comercianteId;
    List<DenunciaRecebidaModel>? denuncias;
    if (id != null) {
      try {
        denuncias = await _denunciaService.getRecebidas(id);
      } catch (_) {
        // `null` (e não lista vazia) para o card poder dizer "não deu para
        // carregar" em vez de "nada por aqui" — anunciar ausência de denúncia
        // sem ter conseguido perguntar seria mentir para o comerciante.
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

    // Média calculada da mesma lista que alimenta a rosca. A agregação do
    // backend (`GET /lojas/{id}/completa`) seria outra fonte, e duas fontes
    // discordando na mesma tela — a média dizendo 4,8 e as fatias mostrando
    // outra coisa — é pior que recalcular aqui.
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

  /// Recorta as denúncias pelo escopo e pelo período, e conta motivos.
  ///
  /// [denuncias] nulo significa que a busca falhou — vira [DenunciaResumo
  /// .naoCarregou], não um resumo vazio.
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
    // Fim do dia de hoje: `dataDenuncia` é LocalDateTime, e comparar contra a
    // meia-noite descartaria tudo que foi denunciado hoje.
    final fim = hoje.add(const Duration(days: 1));

    final noPeriodo = <DenunciaRecebidaModel>[];
    var anterior = 0;

    for (final denuncia in denuncias) {
      if (!idsDoEscopo.contains(denuncia.lojaId)) continue;
      final data = denuncia.dataDenuncia;
      // Sem data não dá para situar no tempo: entra no período atual, que é o
      // que a tela está mostrando — esconder seria pior que aproximar.
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

  /// Meia-noite de hoje: as datas da API são dias, sem hora, e comparar com
  /// `DateTime.now()` deixaria o dia corrente sempre "no futuro".
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
