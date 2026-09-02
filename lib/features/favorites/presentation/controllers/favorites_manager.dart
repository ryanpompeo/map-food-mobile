import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/favorites/data/services/favorito_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class FavoritesManager extends ChangeNotifier with WidgetsBindingObserver {
  static final FavoritesManager instance = FavoritesManager._();

  FavoritesManager._() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!SessionStore.instance.isConsumidor) return;
    unawaited(load());
  }

  FavoritoService _service = FavoritoService();

  @visibleForTesting
  set service(FavoritoService service) => _service = service;

  final List<StoreDto> _favorites = [];

  final Set<int> _favoriteIds = {};

  bool _loading = false;

  String? _errorMessage;

  final Set<int> _pending = {};

  List<StoreDto> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(int lojaId) => _favoriteIds.contains(lojaId);

  void _add(StoreDto store) {
    if (_favoriteIds.add(store.id)) _favorites.add(store);
  }

  void _remove(int lojaId) {
    if (_favoriteIds.remove(lojaId)) {
      _favorites.removeWhere((item) => item.id == lojaId);
    }
  }

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _service.getFavoritos();
      _favorites.clear();
      _favoriteIds.clear();
      result.forEach(_add);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Não foi possível carregar seus favoritos.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(StoreDto store) async {
    if (_pending.contains(store.id)) return;
    _pending.add(store.id);

    final wasFavorite = isFavorite(store.id);

    if (wasFavorite) {
      _remove(store.id);
    } else {
      _add(store);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await _service.removeFavorito(store.id);
      } else {
        await _service.addFavorito(store.id);
      }
    } catch (e) {
      if (wasFavorite) {
        _add(store);
      } else {
        _remove(store.id);
      }
      notifyListeners();
      rethrow;
    } finally {
      _pending.remove(store.id);
    }
  }

  void clear() {
    _favorites.clear();
    _favoriteIds.clear();
    _pending.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
