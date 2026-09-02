import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class StoreRondaController extends ChangeNotifier {
  StoreRondaController({
    required StoreDto store,
    this.onStoreUpdated,
    StoreService? storeService,
  })  : _store = store,
        _aberta = store.statusLoja == 'ATIVA',
        _storeService = storeService ?? StoreService() {
    if (_aberta) unawaited(iniciarRastreamento());
  }

  final StoreService _storeService;

  final ValueChanged<StoreDto>? onStoreUpdated;

  StoreDto _store;
  StoreDto get store => _store;

  bool _aberta;
  bool get aberta => _aberta;

  bool _alternando = false;
  bool get alternando => _alternando;

  bool _rastreioAtivo = false;
  bool get rastreioAtivo => _rastreioAtivo;

  DateTime? _ultimaPosicaoEm;
  DateTime? get ultimaPosicaoEm => _ultimaPosicaoEm;

  double? _precisaoMetros;
  double? get precisaoMetros => _precisaoMetros;

  String? _avisoPosicao;
  String? get avisoPosicao => _avisoPosicao;

  StreamSubscription<Position>? _positionSub;

  int _posicaoSeq = 0;

  Timer? _tickRelogio;

  bool _descartado = false;

  void atualizarStore(StoreDto store) {
    if (store.id != _store.id) {
      trocarLoja(store);
      return;
    }
    _store = store;
    final aberta = store.statusLoja == 'ATIVA';
    if (aberta != _aberta) {
      _aberta = aberta;
      if (!aberta) pararRastreamento();
    }
    _notificar();
  }

  void trocarLoja(StoreDto store) {
    if (store.id == _store.id) return;

    pararRastreamento();
    _posicaoSeq++;
    _store = store;
    _aberta = store.statusLoja == 'ATIVA';
    _notificar();

    if (_aberta) unawaited(iniciarRastreamento());
  }

  void _iniciarRelogio() {
    _tickRelogio?.cancel();
    _tickRelogio = Timer.periodic(const Duration(minutes: 1), (_) => _notificar());
  }

  Future<void> iniciarRastreamento() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      if (_descartado) return;
      _rastreioAtivo = true;
      _notificar();
      _iniciarRelogio();

      _positionSub = LocationService.positionStream.listen(_enviarNovaPosicao);
    } catch (_) {
    }
  }

  void pararRastreamento() {
    _positionSub?.cancel();
    _positionSub = null;
    _tickRelogio?.cancel();
    _tickRelogio = null;
    _rastreioAtivo = false;
    _ultimaPosicaoEm = null;
    _precisaoMetros = null;
    _avisoPosicao = null;
    _notificar();
  }

  Future<void> _enviarNovaPosicao(Position posicao) async {
    final seq = ++_posicaoSeq;
    try {
      final atualizada = await _storeService.atualizarPosicao(
        _store,
        posicao.latitude,
        posicao.longitude,
      );
      if (seq != _posicaoSeq || _descartado) return;
      _store = atualizada;
      _ultimaPosicaoEm = DateTime.now();
      _precisaoMetros = posicao.accuracy;
      _avisoPosicao = null;
      _notificar();
      onStoreUpdated?.call(atualizada);
    } catch (_) {
      if (seq != _posicaoSeq || _descartado) return;
      _avisoPosicao = 'Sua posição não está subindo. Verifique a conexão — no mapa dos '
          'clientes você continua no último ponto enviado.';
      _notificar();
    }
  }

  Future<String?> alternarStatus() async {
    if (_alternando) return null;
    final abrir = !_aberta;
    final alvoId = _store.id;

    _alternando = true;
    _notificar();

    try {
      if (SessionStore.instance.isGuest) return null;

      StoreDto atualizada;
      Position? posicaoAberta;
      if (abrir) {
        final posicao = await _obterPosicaoAtual();
        if (posicao == null) {
          return 'Não foi possível obter sua localização. Ative o GPS e permita '
              'o acesso pra abrir a loja.';
        }
        atualizada = await _storeService.update(
          _store.id,
          StoreCreateRequest.fromStore(
            _store,
            statusLoja: 'ATIVA',
            latitude: posicao.latitude,
            longitude: posicao.longitude,
          ),
        );
        posicaoAberta = posicao;
      } else {
        atualizada = await _storeService.atualizarStatus(_store, 'INATIVA');
      }

      if (_descartado) return null;

      if (alvoId != _store.id) {
        onStoreUpdated?.call(atualizada);
        return null;
      }

      if (posicaoAberta != null) {
        _ultimaPosicaoEm = DateTime.now();
        _precisaoMetros = posicaoAberta.accuracy;
        _avisoPosicao = null;
      }

      _aberta = abrir;
      _store = atualizada;
      _notificar();
      onStoreUpdated?.call(atualizada);

      if (abrir) {
        unawaited(iniciarRastreamento());
      } else {
        pararRastreamento();
      }
      return null;
    } catch (_) {
      return 'Erro ao alterar status da loja.';
    } finally {
      _alternando = false;
      _notificar();
    }
  }

  Future<Position?> _obterPosicaoAtual() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 10));
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 10));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 10));
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      return null;
    }
  }

  void _notificar() {
    if (_descartado) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    _positionSub?.cancel();
    _tickRelogio?.cancel();
    super.dispose();
  }
}
