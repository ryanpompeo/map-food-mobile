import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

/// Lista de lojas ativas ("perto de mim"), compartilhada entre as home pages
/// de guest/consumidor/comerciante — antes cada uma buscava uma vez só no
/// `initState` e ficava com o dado congelado enquanto a aba seguia viva no
/// `IndexedStack` (ex: uma loja ficar online não aparecia até reiniciar o
/// app). Como a API não expõe nenhum mecanismo de push (WebSocket/SSE), a
/// "reatividade" aqui é via polling: assim que a primeira tela começa a
/// ouvir, refaz a busca periodicamente e notifica os ouvintes.
class ActiveStoresManager extends ChangeNotifier with WidgetsBindingObserver {
  static final ActiveStoresManager instance = ActiveStoresManager._();

  ActiveStoresManager._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const _pollInterval = Duration(seconds: 20);

  StoreService _service = StoreService();

  /// Troca o service num teste — mesmo motivo do [FavoritesManager]: o
  /// singleton resolve o `ApiClient` antes de o teste poder substituí-lo.
  @visibleForTesting
  set service(StoreService service) => _service = service;

  List<StoreDto> _stores = const [];
  bool _loading = false;
  Timer? _pollTimer;
  bool _emPrimeiroPlano = true;

  /// Sem `List.unmodifiable`: `_stores` é **substituída** em [load], nunca
  /// mutada, então devolvê-la direto é seguro. A cópia defensiva custava uma
  /// alocação por leitura — e o build da home lia este getter duas vezes por
  /// frame para montar o filtro de categoria.
  List<StoreDto> get stores => _stores;
  bool get isLoading => _loading;

  /// Polling só faz sentido com o app à vista. Sem isto, o app continuava
  /// batendo em `GET /lojas/ativas/completa` a cada 20s com a tela desligada
  /// — 180 requisições por hora de lista completa, em rede móvel.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _emPrimeiroPlano = state == AppLifecycleState.resumed;
    if (_emPrimeiroPlano) {
      // Ao voltar, refaz a busca imediatamente: o que estava na tela pode
      // estar minutos desatualizado.
      if (hasListeners) _startPolling();
    } else {
      _stopPolling();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    // `hasListeners` do próprio ChangeNotifier, em vez de um contador manual
    // que dessincroniza se `removeListener` for chamado com um listener que
    // nunca foi registrado.
    final eraVazio = !hasListeners;
    super.addListener(listener);
    if (eraVazio && _emPrimeiroPlano) _startPolling();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _stopPolling();
  }

  void _startPolling() {
    unawaited(load());
    _pollTimer ??= Timer.periodic(_pollInterval, (_) => unawaited(load()));
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
