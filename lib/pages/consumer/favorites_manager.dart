import 'package:flutter/foundation.dart';
import 'package:map_food/models/store/store_dto.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager instance = FavoritesManager._();

  FavoritesManager._();

  final List<StoreDto> _favorites = [];

  List<StoreDto> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(int storeId) {
    return _favorites.any((store) => store.id == storeId);
  }

  void toggle(StoreDto store) {
    final exists = isFavorite(store.id!);

    if (exists) {
      _favorites.removeWhere((item) => item.id == store.id);
    } else {
      _favorites.add(store);
    }

    notifyListeners();
  }
}
