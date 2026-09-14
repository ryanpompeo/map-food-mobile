import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class ActiveStoresManager extends ChangeNotifier with WidgetsBindingObserver {
  static final ActiveStoresManager instance = ActiveStoresManager._();

  ActiveStoresManager._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration limiteSemSinal = Duration(minutes: 15);
  static const Duration _pollInterval = Duration(seconds: 20);
  static const Duration _intervaloDeReavaliacao = Duration(seconds: 30);
  static const Duration _toleranciaDoVistoEm = Duration(seconds: 20);

  StoreService _service = StoreService();
  DateTime Function() _agora = DateTime.now;

  @visibleForTesting
  set service(StoreService service) => _service = service;

  @visibleForTesting
  set relogio(DateTime Function() agora) => _agora = agora;

  List<StoreDto> _recebidas = const [];
  Map<int, DateTime> _vistoEm = const {};
  List<StoreDto> _visiveis = const [];
  List<String> _assinaturasVisiveis = const [];
  final Map<int, ValueNotifier<StoreDto?>> _observadas = {};
  final Map<int, String?> _assinaturasObservadas = {};
  bool _loading = false;
  Future<void>? _emAndamento;
  Timer? _pollTimer;
  Timer? _reavaliacao;
  bool _emPrimeiroPlano = true;

  List<StoreDto> get stores => _visiveis;
  bool get isLoading => _loading;

  Duration? semSinalHa(int lojaId) {
    final visto = _vistoEm[lojaId];
    return visto == null ? null : _agora().difference(visto);
  }

  ValueListenable<StoreDto?> observar(int lojaId) => _observadas.putIfAbsent(lojaId, () {
        final atual = _visivelPorId(lojaId);
        _assinaturasObservadas[lojaId] = _assinaturaOuNula(atual);
        return ValueNotifier(atual);
      });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _emPrimeiroPlano = state == AppLifecycleState.resumed;
    if (_emPrimeiroPlano) {
      if (hasListeners) _startPolling();
    } else {
      _stopPolling();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    final eraVazio = !hasListeners;
    super.addListener(listener);
    if (eraVazio && _emPrimeiroPlano) _startPolling();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _stopPolling();
  }

  Future<void> load() => _emAndamento ??= _carregar().whenComplete(() => _emAndamento = null);

  @visibleForTesting
  void reavaliarDefasagem() => _publicar();

  @visibleForTesting
  void limparParaTeste() {
    _stopPolling();
    _recebidas = const [];
    _vistoEm = const {};
    _visiveis = const [];
    _assinaturasVisiveis = const [];
    _observadas.clear();
    _assinaturasObservadas.clear();
    _loading = false;
    _agora = DateTime.now;
  }

  void _startPolling() {
    unawaited(load());
    _pollTimer ??= Timer.periodic(_pollInterval, (_) => unawaited(load()));
    _reavaliacao ??= Timer.periodic(_intervaloDeReavaliacao, (_) => _publicar());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _reavaliacao?.cancel();
    _reavaliacao = null;
  }

  Future<void> _carregar() async {
    final primeiraCarga = _recebidas.isEmpty && !_loading;
    if (primeiraCarga) {
      _loading = true;
      notifyListeners();
    }
    try {
      _aplicar(await _service.getActive(), _agora());
    } catch (_) {
    } finally {
      _encerrarCarregamento();
    }
  }

  void _encerrarCarregamento() {
    if (!_loading) return;
    _loading = false;
    notifyListeners();
  }

  void _aplicar(List<StoreDto> lojas, DateTime recebidoEm) {
    _vistoEm = {
      for (final loja in lojas)
        if (loja.segundosSemSinal != null) loja.id: _vistoEstavel(loja, recebidoEm),
    };
    _recebidas = lojas;
    _publicar();
  }

  DateTime _vistoEstavel(StoreDto loja, DateTime recebidoEm) {
    final novo = recebidoEm.subtract(Duration(seconds: loja.segundosSemSinal!));
    final anterior = _vistoEm[loja.id];
    if (anterior == null) return novo;
    return novo.difference(anterior).abs() <= _toleranciaDoVistoEm ? anterior : novo;
  }

  void _publicar() {
    final visiveis = _recebidas.where(_comSinalRecente).toList(growable: false);
    final assinaturas = visiveis.map(_assinatura).toList(growable: false);
    if (listEquals(assinaturas, _assinaturasVisiveis)) return;
    _visiveis = visiveis;
    _assinaturasVisiveis = assinaturas;
    _atualizarObservadas();
    notifyListeners();
  }

  bool _comSinalRecente(StoreDto loja) {
    final visto = _vistoEm[loja.id];
    return visto == null || _agora().difference(visto) < limiteSemSinal;
  }

  void _atualizarObservadas() {
    for (final entrada in _observadas.entries) {
      final atual = _visivelPorId(entrada.key);
      final assinatura = _assinaturaOuNula(atual);
      if (_assinaturasObservadas[entrada.key] == assinatura) continue;
      _assinaturasObservadas[entrada.key] = assinatura;
      entrada.value.value = atual;
    }
  }

  StoreDto? _visivelPorId(int lojaId) {
    for (final loja in _visiveis) {
      if (loja.id == lojaId) return loja;
    }
    return null;
  }

  String? _assinaturaOuNula(StoreDto? loja) => loja == null ? null : _assinatura(loja);

  String _assinatura(StoreDto loja) => [
        loja.id,
        loja.nome,
        loja.descricao,
        loja.statusLoja,
        loja.latitude,
        loja.longitude,
        loja.avaliacao,
        loja.totalAvaliacoes,
        loja.capaUrl,
        loja.enderecoCompleto,
        loja.categoriaIds.join(','),
        _vistoEm[loja.id]?.millisecondsSinceEpoch,
      ].join('|');
}
