import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/location/perfil_localizacao.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/merchant/presentation/controllers/estado_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/ronda_manager.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class StoreRondaController extends ChangeNotifier {
  StoreRondaController({
    required StoreDto store,
    this.onStoreUpdated,
    StoreService? storeService,
    RondaManager? ronda,
  })  : _store = store,
        _storeService = storeService ?? StoreService(),
        _ronda = ronda ?? RondaManager.instance {
    _vincular(store.id);
    _relogio = Timer.periodic(const Duration(minutes: 1), (_) => _notificar());
  }

  static const String _semGpsParaAbrir =
      'Sem localização — ative o GPS e permita o acesso pra abrir a loja';
  static const String _lojaSuspensa =
      'Sua loja está suspensa pela moderação — fale com o suporte';

  final StoreService _storeService;
  final RondaManager _ronda;
  final ValueChanged<StoreDto>? onStoreUpdated;

  StoreDto _store;
  ValueListenable<EstadoRonda>? _estadoVinculado;
  Timer? _relogio;
  bool _alternando = false;
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

  bool get alternando => _alternando;

  bool get rastreioAtivo => aberta && _estado.transmitindo;

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

  Future<String?> alternarStatus() async {
    if (_alternando || SessionStore.instance.isGuest) return null;
    _alternando = true;
    _notificar();
    try {
      return aberta ? await _fechar() : await _abrir();
    } catch (_) {
      return 'Erro ao alterar status da loja';
    } finally {
      _alternando = false;
      _notificar();
    }
  }

  Future<String?> _abrir() async {
    if (suspensa) return _lojaSuspensa;
    final posicao = await _posicaoParaAbrir();
    if (posicao == null) return _semGpsParaAbrir;
    final alvo = _store;
    final atualizada = await _storeService.abrirLoja(alvo, posicao.latitude, posicao.longitude);
    _ronda.acompanhar(atualizada, posicaoInicial: posicao);
    _aplicar(alvo.id, atualizada);
    return null;
  }

  Future<String?> _fechar() async {
    final alvo = _store;
    final atualizada = await _storeService.atualizarStatus(alvo, StatusLoja.inativa);
    _ronda.soltar(alvo.id);
    _aplicar(alvo.id, atualizada);
    return null;
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
  }

  void _desvincular() {
    _estadoVinculado?.removeListener(_aoMudarEstado);
    _estadoVinculado = null;
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

  static String? _avisoDaFase(FaseRonda fase) => switch (fase) {
        FaseRonda.semPermissao =>
          'Sem permissão de localização — libere o acesso nas configurações do aparelho',
        _ => null,
      };

  String? _avisoDeTransmissao(EstadoRonda estado) {
    if (estado.falhasSeguidas >= _ronda.configuracao.falhasAteAvisar) {
      return 'Sua posição não está subindo — verifique a conexão, no mapa '
          'dos clientes você segue no último ponto enviado';
    }
    if (estado.precisaoBaixa) return 'Sinal de GPS fraco — sua posição no mapa pode estar imprecisa';
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
    _desvincular();
    super.dispose();
  }
}
