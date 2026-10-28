import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/notificacoes/permissao_notificacoes.dart';
import 'package:map_food/core/location/perfil_localizacao.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/merchant/presentation/controllers/agenda_de_fechamento.dart';
import 'package:map_food/features/merchant/presentation/controllers/estado_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/modo_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/ronda_manager.dart';
import 'package:map_food/features/merchant/presentation/controllers/situacao_loja.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

enum _Acao { alternar, acompanhar }

class StoreRondaController extends ChangeNotifier {
  StoreRondaController({
    required StoreDto store,
    this.onStoreUpdated,
    StoreService? storeService,
    RondaManager? ronda,
    AgendaDeFechamento? agenda,
    DateTime Function()? agora,
    Future<bool> Function()? pedirNotificacoes,
  })  : _store = store,
        _storeService = storeService ?? StoreService(),
        _ronda = ronda ?? RondaManager.instance,
        _agenda = agenda ?? AgendaDeFechamento.instance,
        _agora = agora ?? DateTime.now,
        _pedirNotificacoes = pedirNotificacoes ?? PermissaoNotificacoes.pedir {
    _vincular(store.id);
    _agenda.lojaFechadaPeloPrazo.addListener(_aoFecharPeloPrazo);
    _relogio = Timer.periodic(const Duration(minutes: 1), (_) => _notificar());
  }

  static const Duration avisoDeFimProximo = Duration(minutes: 15);
  static const Duration prorrogacao = Duration(hours: 2);

  static const String _semGpsParaAbrir =
      'Sem localização · ative o GPS e permita o acesso pra abrir a loja';
  static const String _semGpsParaAcompanhar =
      'Sem localização · ative o GPS e permita o acesso pra acompanhar sua posição';
  static const String _lojaSuspensa =
      'Sua loja está suspensa pela moderação · fale com o suporte';

  final StoreService _storeService;
  final RondaManager _ronda;
  final AgendaDeFechamento _agenda;
  final DateTime Function() _agora;
  final Future<bool> Function() _pedirNotificacoes;
  final ValueChanged<StoreDto>? onStoreUpdated;

  StoreDto _store;
  ValueListenable<EstadoRonda>? _estadoVinculado;
  Timer? _relogio;
  _Acao? _emCurso;
  bool _descartado = false;

  EstadoRonda get _estado => _estadoVinculado?.value ?? EstadoRonda.parada;

  StoreDto get store {
    final latitude = _estado.latitude;
    final longitude = _estado.longitude;
    if (latitude == null || longitude == null) return _store;
    return _store.comPosicao(latitude, longitude);
  }

  bool get aberta => _store.status == StatusLoja.ativa;

  bool get suspensa => _store.status == StatusLoja.suspensa;

  bool get alternando => _emCurso == _Acao.alternar;

  bool get ligandoAcompanhamento => _emCurso == _Acao.acompanhar;

  SituacaoLoja get situacao {
    if (suspensa) return SituacaoLoja.suspensa;
    if (!aberta) return SituacaoLoja.fechada;
    return _situacaoDaRonda(_estado);
  }

  Duration? get semSinalHa {
    final ultimoEnvio = _estado.ultimoEnvioEm;
    if (situacao != SituacaoLoja.semSinal || ultimoEnvio == null) return null;
    return _agora().difference(ultimoEnvio);
  }

  Duration? get fechaEm {
    final semSinal = semSinalHa;
    if (semSinal == null) return null;
    final restante = _ronda.configuracao.limiteSemSinal - semSinal;
    return restante.isNegative ? Duration.zero : restante;
  }

  DateTime? get ultimaPosicaoEm => _estado.ultimoEnvioEm;

  double? get precisaoMetros => _estado.precisaoMetros;

  String? get avisoPosicao =>
      _estado.recusa?.message ?? _avisoDaFase(_estado.fase) ?? _avisoDeTransmissao(_estado);

  void atualizarStore(StoreDto store) {
    if (store.id != _store.id) {
      _trocar(store);
      return;
    }
    _store = store;
    if (!aberta) _ronda.soltar(store.id);
    _notificar();
  }

  DateTime? get prazo => _agenda.prazoDe(_store.id).value;

  ModoRonda get modo => _ronda.modo;

  Duration? get faltaParaFechar {
    final fim = prazo;
    if (fim == null) return null;
    final falta = fim.difference(_agora());
    return falta.isNegative ? Duration.zero : falta;
  }

  bool get fimProximo {
    final falta = faltaParaFechar;
    return falta != null && falta <= avisoDeFimProximo;
  }

  Future<String?> alternarStatus() =>
      _executar(_Acao.alternar, aberta ? _fechar : _abrir, 'Erro ao alterar status da loja');

  Future<String?> abrirComo(ModoRonda modo, {DateTime? encerraEm}) => _executar(
        _Acao.alternar,
        () => _abrir(modo: modo, encerraEm: encerraEm),
        'Erro ao alterar status da loja',
      );

  void trocarModo(ModoRonda modo) {
    if (!aberta || _ronda.modo == modo) return;
    _ronda.definirModo(modo);
    _notificar();
  }

  Future<void> prorrogar() async {
    if (prazo == null) return;
    await _agenda.prorrogar(_store.id, prorrogacao);
    _notificar();
  }

  Future<String?> acompanharPosicao() =>
      _executar(_Acao.acompanhar, _comecarRonda, 'Erro ao ligar o acompanhamento da posição');

  Future<String?> _executar(_Acao acao, Future<String?> Function() tarefa, String falha) async {
    if (_emCurso != null || SessionStore.instance.isGuest) return null;
    _emCurso = acao;
    _notificar();
    try {
      return await tarefa();
    } catch (_) {
      return falha;
    } finally {
      _emCurso = null;
      _notificar();
    }
  }

  Future<String?> _comecarRonda() async {
    final posicao = await _posicaoParaAbrir();
    if (posicao == null) return _semGpsParaAcompanhar;
    await _pedirNotificacoes();
    if (situacao == SituacaoLoja.fixa) _ronda.acompanhar(_store, posicaoInicial: posicao);
    return null;
  }

  Future<String?> _abrir({ModoRonda modo = ModoRonda.emMovimento, DateTime? encerraEm}) async {
    if (suspensa) return _lojaSuspensa;
    final posicao = await _posicaoParaAbrir();
    if (posicao == null) return _semGpsParaAbrir;
    await _pedirNotificacoes();
    final alvo = _store;
    final atualizada = await _storeService.abrirLoja(alvo, posicao.latitude, posicao.longitude);
    _ronda.acompanhar(atualizada, posicaoInicial: posicao, modo: modo);
    if (modo == ModoRonda.parado && encerraEm != null) {
      await _agenda.agendar(alvo.id, encerraEm);
    }
    _aplicar(alvo.id, atualizada);
    return null;
  }

  Future<String?> _fechar() async {
    final alvo = _store;
    final atualizada = await _storeService.atualizarStatus(alvo, StatusLoja.inativa);
    _ronda.soltar(alvo.id);
    await _agenda.cancelar(alvo.id);
    _aplicar(alvo.id, atualizada);
    return null;
  }

  void _aoFecharPeloPrazo() {
    if (_descartado || _agenda.lojaFechadaPeloPrazo.value != _store.id) return;
    _store = _store.comStatus(StatusLoja.inativa);
    onStoreUpdated?.call(_store);
    _notificar();
  }

  Future<Position?> _posicaoParaAbrir() async {
    if (await LocationService.verificarAcesso() != AcessoLocalizacao.liberado) return null;
    try {
      return await LocationService.posicaoAtual(PerfilLocalizacao.ronda);
    } catch (_) {
      return null;
    }
  }

  void _aplicar(int alvoId, StoreDto atualizada) {
    if (_descartado) return;
    if (alvoId == _store.id) _store = atualizada;
    onStoreUpdated?.call(atualizada);
  }

  void _trocar(StoreDto store) {
    _desvincular();
    _store = store;
    _vincular(store.id);
    _notificar();
  }

  void _vincular(int lojaId) {
    _estadoVinculado = _ronda.estadoDe(lojaId)..addListener(_aoMudarEstado);
    _agenda.prazoDe(lojaId).addListener(_notificar);
  }

  void _desvincular() {
    _estadoVinculado?.removeListener(_aoMudarEstado);
    _estadoVinculado = null;
    _agenda.prazoDe(_store.id).removeListener(_notificar);
  }

  void _aoMudarEstado() {
    final recusa = _estado.recusa;
    if (recusa != null && _statusConhecidoEDiferente(recusa.status)) {
      _store = _store.comStatus(recusa.status);
      onStoreUpdated?.call(_store);
    }
    _notificar();
  }

  bool _statusConhecidoEDiferente(StatusLoja status) =>
      status != StatusLoja.desconhecido && status != _store.status;

  SituacaoLoja _situacaoDaRonda(EstadoRonda estado) => switch (estado.fase) {
        FaseRonda.parada || FaseRonda.recusada => SituacaoLoja.fixa,
        FaseRonda.iniciando => SituacaoLoja.iniciando,
        FaseRonda.ativa when estado.falhasSeguidas < _ronda.configuracao.falhasAteAvisar =>
          SituacaoLoja.transmitindo,
        _ => SituacaoLoja.semSinal,
      };

  static String? _avisoDaFase(FaseRonda fase) => switch (fase) {
        FaseRonda.semPermissao =>
          'Sem permissão de localização · libere o acesso nas configurações do aparelho',
        FaseRonda.gpsDesligado => 'GPS desligado · ative a localização pra voltar a enviar sua posição',
        _ => null,
      };

  String? _avisoDeTransmissao(EstadoRonda estado) {
    if (estado.falhasSeguidas >= _ronda.configuracao.falhasAteAvisar) {
      return 'Sua posição não está subindo · verifique a conexão, no mapa '
          'dos clientes você segue no último ponto enviado';
    }
    if (estado.precisaoBaixa) return 'Sinal de GPS fraco · sua posição no mapa pode estar imprecisa';
    return null;
  }

  void _notificar() {
    if (_descartado) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    _relogio?.cancel();
    _agenda.lojaFechadaPeloPrazo.removeListener(_aoFecharPeloPrazo);
    _desvincular();
    super.dispose();
  }
}
