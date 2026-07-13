import 'package:flutter/foundation.dart';
import 'package:map_food/features/favorites/data/services/favorito_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager instance = FavoritesManager._();

  FavoritesManager._();

  final FavoritoService _service = FavoritoService();

  final List<StoreDto> _favorites = [];
  bool _loading = false;

  List<StoreDto> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _loading;

  bool isFavorite(int storeId) {
    return _favorites.any((store) => store.id == storeId);
  }

  /// Busca os favoritos do consumidor autenticado na API. Seguro de chamar
  /// mais de uma vez (ex: a cada abertura da home/aba de favoritos).
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _service.getFavoritos();
      _favorites
        ..clear()
        ..addAll(result);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Atualização otimista: alterna localmente e notifica antes de confirmar
  /// com a API. Reverte e relança o erro se a chamada falhar.
  Future<void> toggle(StoreDto store) async {
    final wasFavorite = isFavorite(store.id);

    if (wasFavorite) {
      _favorites.removeWhere((item) => item.id == store.id);
    } else {
      _favorites.add(store);
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
        _favorites.add(store);
      } else {
        _favorites.removeWhere((item) => item.id == store.id);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Zera o estado local sem chamar a API — usado no logout, pra não vazar
  /// favoritos de uma conta para a sessão seguinte no mesmo aparelho.
  void clear() {
    _favorites.clear();
    notifyListeners();
  }
}
