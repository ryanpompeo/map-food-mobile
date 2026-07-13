import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

/// Lista de lojas ativas ("perto de mim"), compartilhada entre as home pages
/// de guest/consumidor/comerciante — antes cada uma buscava uma vez só no
/// `initState` e ficava com o dado congelado enquanto a aba seguia viva no
/// `IndexedStack` (ex: uma loja ficar online não aparecia até reiniciar o
/// app). Como a API não expõe nenhum mecanismo de push (WebSocket/SSE), a
/// "reatividade" aqui é via polling: assim que a primeira tela começa a
/// ouvir, refaz a busca periodicamente e notifica os ouvintes.
class ActiveStoresManager extends ChangeNotifier {
  static final ActiveStoresManager instance = ActiveStoresManager._();

  ActiveStoresManager._();

  static const _pollInterval = Duration(seconds: 20);

  final StoreService _service = StoreService();

  List<StoreDto> _stores = [];
  bool _loading = false;
  Timer? _pollTimer;
  int _listenerCount = 0;

  List<StoreDto> get stores => List.unmodifiable(_stores);
  bool get isLoading => _loading;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listenerCount++;
    if (_listenerCount == 1) _startPolling();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _listenerCount--;
    if (_listenerCount <= 0) _stopPolling();
  }

  void _startPolling() {
    load();
    _pollTimer ??= Timer.periodic(_pollInterval, (_) => load());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Busca as lojas ativas na API. Seguro de chamar mais de uma vez — só
  /// mostra o loading (`isLoading`) na primeira vez; refreshes em segundo
  /// plano trocam a lista sem piscar um spinner pra quem já está vendo o mapa.
  Future<void> load() async {
    final primeiraCarga = _stores.isEmpty && !_loading;
    if (primeiraCarga) {
      _loading = true;
      notifyListeners();
    }
    try {
      _stores = await _service.getActive();
    } catch (_) {
      // Mantém a última lista boa se a API estiver indisponível.
    } finally {
      if (_loading) _loading = false;
      notifyListeners();
    }
  }
}
