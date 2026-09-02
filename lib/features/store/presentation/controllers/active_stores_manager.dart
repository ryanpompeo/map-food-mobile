import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class ActiveStoresManager extends ChangeNotifier with WidgetsBindingObserver {
  static final ActiveStoresManager instance = ActiveStoresManager._();

  ActiveStoresManager._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const _pollInterval = Duration(seconds: 20);

  StoreService _service = StoreService();

  @visibleForTesting
  set service(StoreService service) => _service = service;

  List<StoreDto> _stores = const [];
  bool _loading = false;
  Timer? _pollTimer;
  bool _emPrimeiroPlano = true;

  List<StoreDto> get stores => _stores;
  bool get isLoading => _loading;

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

  void _startPolling() {
    unawaited(load());
    _pollTimer ??= Timer.periodic(_pollInterval, (_) => unawaited(load()));
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> load() async {
    final primeiraCarga = _stores.isEmpty && !_loading;
    if (primeiraCarga) {
      _loading = true;
      notifyListeners();
    }
    try {
      _stores = await _service.getActive();
    } catch (_) {
    } finally {
      if (_loading) _loading = false;
      notifyListeners();
    }
  }
}
