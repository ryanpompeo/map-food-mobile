import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/location/perfil_localizacao.dart';
import 'package:map_food/core/notificacoes/avisos_da_loja.dart';
import 'package:map_food/features/merchant/presentation/controllers/configuracao_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/estado_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/filtro_de_leituras.dart';
import 'package:map_food/features/merchant/presentation/controllers/modo_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/ronda_uplink.dart';
import 'package:map_food/features/store/data/loja_fora_de_ronda_exception.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class RondaManager with WidgetsBindingObserver {
  RondaManager({
    StoreService? storeService,
    this.configuracao = const ConfiguracaoRonda(),
    DateTime Function()? agora,
    Aviso? avisar,
  })  : _storeService = storeService ?? StoreService(),
        _agora = agora ?? DateTime.now,
        _avisar = avisar ?? AvisosDaLoja.saiuDoMapa,
        _filtro = FiltroDeLeituras(configuracao);

  static final RondaManager instance = RondaManager();

  final ConfiguracaoRonda configuracao;
  final StoreService _storeService;
  final DateTime Function() _agora;
  final Aviso _avisar;
  final FiltroDeLeituras _filtro;

  final Map<int, RondaUplink> _uplinks = {};
  final Map<int, ValueNotifier<EstadoRonda>> _estados = {};
  final Set<int> _dispensadas = {};

  StreamSubscription<Position>? _leituras;
  StreamSubscription<bool>? _servico;
  Timer? _verificacao;
  int _geracaoLeitura = 0;
  int _geracaoSincronia = 0;
  bool _observando = false;
  bool _jaAvisou = false;
  ModoRonda _modo = ModoRonda.emMovimento;
  FaseRonda _faseGps = FaseRonda.parada;
  DateTime? _inicioDaLeituraEm;
  DateTime? _ultimaLeituraEm;
  DateTime? _ultimoEnvioEm;

  ValueListenable<EstadoRonda> estadoDe(int lojaId) => _notificadorDe(lojaId);

  bool acompanha(int lojaId) => _uplinks.containsKey(lojaId);

  Future<void> sincronizar(List<StoreDto> lojasDoComerciante) async {
    final geracao = ++_geracaoSincronia;
    _dispensadas.clear();
    final ativas = {
      for (final loja in lojasDoComerciante)
        if (loja.status == StatusLoja.ativa) loja.id: loja,
    };
    for (final id in _uplinks.keys.toList()) {
      if (!ativas.containsKey(id)) _encerrarLoja(id, EstadoRonda.parada);
    }
    for (final loja in ativas.values) {
      await _retomarSeEstiverEmRonda(loja, geracao);
    }
  }

  ModoRonda get modo => _modo;

  void definirModo(ModoRonda modo) {
    if (_modo == modo) return;
    _modo = modo;
    if (_uplinks.isEmpty || _leituras == null) return;
    unawaited(_reassinarLeitura());
  }

  Future<void> _reassinarLeitura() async {
    final leituras = _leituras;
    _leituras = null;
    _inicioDaLeituraEm = null;
    _ultimaLeituraEm = null;
    await leituras?.cancel();
    await _garantirLeitura();
  }

  void acompanhar(StoreDto loja, {Position? posicaoInicial, ModoRonda? modo}) {
    _dispensadas.remove(loja.id);
    _jaAvisou = false;
    if (modo != null) definirModo(modo);
    if (acompanha(loja.id)) return;
    _uplinks[loja.id] = _criarUplink(loja);
    _notificadorDe(loja.id).value = EstadoRonda(fase: _faseInicial());
    _observarCicloDeVida();
    _enviarPosicaoConhecida(loja.id, posicaoInicial);
    unawaited(_garantirLeitura());
  }

  void soltar(int lojaId) {
    _dispensadas.add(lojaId);
    if (acompanha(lojaId)) _encerrarLoja(lojaId, EstadoRonda.parada);
  }

  void encerrar() {
    _geracaoSincronia++;
    for (final id in _uplinks.keys.toList()) {
      _encerrarLoja(id, EstadoRonda.parada);
    }
    _pararLeitura();
    _estados.clear();
  }

  @visibleForTesting
  void verificarSaude() {
    final agora = _agora();
    _vigiarLeituras(agora);
    _mandarSinalDeVida(agora);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _uplinks.isEmpty) return;
    _retomarLeitura();
  }

  Future<void> _retomarSeEstiverEmRonda(StoreDto loja, int geracao) async {
    if (acompanha(loja.id)) return;
    try {
      final resumo = await _storeService.getResumo(loja.id);
      if (geracao != _geracaoSincronia || _dispensadas.contains(loja.id)) return;
      if (resumo.status == StatusLoja.ativa && resumo.emRonda) acompanhar(resumo);
    } catch (_) {
      return;
    }
  }

  RondaUplink _criarUplink(StoreDto loja) => RondaUplink(
        transmitir: (posicao) =>
            _storeService.atualizarPosicao(loja, posicao.latitude, posicao.longitude),
        esperas: configuracao.esperasDeReenvio,
        intervaloMinimo: configuracao.intervaloMinimoEntreEnvios,
        agora: _agora,
        aoEnviar: (posicao) => _aoEnviar(loja.id, posicao),
        aoFalhar: (falhas) => _alterar(loja.id, (estado) => estado.comFalhas(falhas)),
        aoSerRecusado: (recusa) => _aoSerRecusado(loja.id, recusa),
      );

  FaseRonda _faseInicial() => _faseGps == FaseRonda.parada ? FaseRonda.iniciando : _faseGps;

  void _enviarPosicaoConhecida(int lojaId, Position? posicaoInicial) {
    if (posicaoInicial != null) _filtro.semear(posicaoInicial);
    final conhecida = _filtro.ultimaAceita;
    if (conhecida != null) _uplinks[lojaId]?.enviar(conhecida);
  }

  void _aoEnviar(int lojaId, Position posicao) {
    final agora = _agora();
    _ultimoEnvioEm = agora;
    _jaAvisou = false;
    _alterar(lojaId, (estado) {
      final fase = estado.fase == FaseRonda.iniciando ? FaseRonda.ativa : estado.fase;
      return estado
          .comEnvio(
            em: agora,
            latitude: posicao.latitude,
            longitude: posicao.longitude,
            precisaoMetros: posicao.accuracy,
            precisaoBaixa: _filtro.precisaoBaixa,
          )
          .naFase(fase);
    });
  }

  void _aoSerRecusado(int lojaId, LojaForaDeRondaException recusa) {
    _encerrarLoja(lojaId, EstadoRonda(fase: FaseRonda.recusada, recusa: recusa));
    _avisarQueSaiu(recusa.message);
  }

  void avisarQueASessaoCaiu() {
    if (_uplinks.isEmpty) return;
    _avisarQueSaiu(_sessaoExpirada);
  }

  void _avisarQueSaiu(String motivo) {
    if (_jaAvisou || !_emSegundoPlano) return;
    _jaAvisou = true;
    unawaited(_avisar(motivo));
  }

  void _encerrarLoja(int lojaId, EstadoRonda estadoFinal) {
    _uplinks.remove(lojaId)?.encerrar();
    _estados[lojaId]?.value = estadoFinal;
    if (_uplinks.isEmpty) _pararLeitura();
  }

  Future<void> _garantirLeitura() async {
    if (_leituras != null) return;
    final geracao = ++_geracaoLeitura;
    final acesso = await LocationService.verificarAcesso();
    if (geracao != _geracaoLeitura || _uplinks.isEmpty) return;
    _aplicarAcesso(acesso);
  }

  void _aplicarAcesso(AcessoLocalizacao acesso) {
    switch (acesso) {
      case AcessoLocalizacao.liberado:
        _assinarLeituras();
      case AcessoLocalizacao.servicoDesligado:
        _definirFaseGps(FaseRonda.gpsDesligado);
        _escutarServico();
      case AcessoLocalizacao.negado:
        _definirFaseGps(FaseRonda.semPermissao);
    }
  }

  PerfilLocalizacao get _perfil =>
      _modo == ModoRonda.parado ? PerfilLocalizacao.rondaParada : PerfilLocalizacao.ronda;

  void _assinarLeituras() {
    _inicioDaLeituraEm = _agora();
    _leituras = LocationService.streamDe(_perfil).listen(
          _aoLer,
          onError: _aoErroDeGps,
        );
    _verificacao ??= Timer.periodic(configuracao.intervaloDeVerificacao, (_) => verificarSaude());
    _definirFaseGps(FaseRonda.ativa);
  }

  void _aoLer(Position leitura) {
    final agora = _agora();
    _ultimaLeituraEm = agora;
    if (_faseGps != FaseRonda.ativa) _definirFaseGps(FaseRonda.ativa);
    if (_modo == ModoRonda.parado) {
      _mandarSinalDeVida(agora);
      return;
    }
    final aceita = _filtro.avaliar(leitura, agora);
    if (aceita != null) _distribuir(aceita);
  }

  void _aoErroDeGps(Object erro) {
    if (erro is LocationServiceDisabledException) {
      _definirFaseGps(FaseRonda.gpsDesligado);
      _escutarServico();
      return;
    }
    if (erro is PermissionDeniedException) {
      _cancelarLeituras();
      _definirFaseGps(FaseRonda.semPermissao);
    }
  }

  void _escutarServico() {
    _servico ??= LocationService.servicoAtivo.listen(_aoMudarServico, onError: (Object _) {});
  }

  void _aoMudarServico(bool ativo) {
    if (!ativo) return;
    _servico?.cancel();
    _servico = null;
    _retomarLeitura();
  }

  void _retomarLeitura() {
    if (_leituras == null) {
      unawaited(_garantirLeitura());
      return;
    }
    LocationService.reiniciar(_perfil);
  }

  void _vigiarLeituras(DateTime agora) {
    final referencia = _ultimaLeituraEm ?? _inicioDaLeituraEm;
    if (_leituras == null || referencia == null || _emSegundoPlano) return;
    if (agora.difference(referencia) < configuracao.watchdog) return;
    _ultimaLeituraEm = agora;
    LocationService.reiniciar(_perfil);
  }

  static bool get _emSegundoPlano => switch (WidgetsBinding.instance.lifecycleState) {
        AppLifecycleState.paused || AppLifecycleState.hidden || AppLifecycleState.detached => true,
        _ => false,
      };

  void _mandarSinalDeVida(DateTime agora) {
    final ultima = _filtro.ultimaAceita;
    final referencia = _ultimoEnvioEm;
    if (ultima == null || referencia == null) return;
    if (agora.difference(referencia) >= configuracao.heartbeat) _distribuir(ultima);
  }

  void _distribuir(Position posicao) {
    for (final uplink in _uplinks.values) {
      uplink.enviar(posicao);
    }
  }

  static const String _sessaoExpirada =
      'Sua sessão expirou. Entre de novo para sua loja voltar ao mapa';
  static const String _semPermissaoNoBolso =
      'A permissão de localização foi retirada. Sua posição parou de ser enviada e a loja sai do mapa em poucos minutos';
  static const String _gpsDesligadoNoBolso =
      'O GPS foi desligado. Sua posição parou de ser enviada e a loja sai do mapa em poucos minutos';

  void _definirFaseGps(FaseRonda fase) {
    _faseGps = fase;
    if (_uplinks.isNotEmpty) {
      switch (fase) {
        case FaseRonda.semPermissao:
          _avisarQueSaiu(_semPermissaoNoBolso);
        case FaseRonda.gpsDesligado:
          _avisarQueSaiu(_gpsDesligadoNoBolso);
        default:
          break;
      }
    }
    for (final id in _uplinks.keys) {
      _alterar(id, (estado) => estado.naFase(fase));
    }
  }

  void _alterar(int lojaId, EstadoRonda Function(EstadoRonda atual) mudanca) {
    final notificador = _estados[lojaId];
    if (notificador == null || !acompanha(lojaId)) return;
    notificador.value = mudanca(notificador.value);
  }

  ValueNotifier<EstadoRonda> _notificadorDe(int lojaId) =>
      _estados.putIfAbsent(lojaId, () => ValueNotifier(EstadoRonda.parada));

  void _pararLeitura() {
    _geracaoLeitura++;
    _cancelarLeituras();
    _verificacao?.cancel();
    _verificacao = null;
    _servico?.cancel();
    _servico = null;
    _filtro.reiniciar();
    _ultimoEnvioEm = null;
    _modo = ModoRonda.emMovimento;
    _faseGps = FaseRonda.parada;
    _pararDeObservar();
  }

  void _cancelarLeituras() {
    _leituras?.cancel();
    _leituras = null;
    _inicioDaLeituraEm = null;
    _ultimaLeituraEm = null;
  }

  void _observarCicloDeVida() {
    if (_observando) return;
    WidgetsBinding.instance.addObserver(this);
    _observando = true;
  }

  void _pararDeObservar() {
    if (!_observando) return;
    WidgetsBinding.instance.removeObserver(this);
    _observando = false;
  }
}
