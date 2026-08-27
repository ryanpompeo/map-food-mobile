import 'package:flutter/foundation.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/features/favorites/data/services/favorito_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager instance = FavoritesManager._();

  FavoritesManager._();

  FavoritoService _service = FavoritoService();

  /// Troca o service num teste. Necessário porque este controller é um
  /// singleton de processo: ele resolve o `ApiClient` na construção, ou seja,
  /// antes de qualquer `ApiClient.overrideInstance` que um teste faça.
  @visibleForTesting
  set service(FavoritoService service) => _service = service;

  final List<StoreDto> _favorites = [];

  /// Índice de consulta O(1), mantido em paralelo à lista.
  ///
  /// `isFavorite` era um `any` linear, e cada card de loja na tela mantém um
  /// listener neste singleton. Com as abas vivas num IndexedStack são dezenas
  /// de corações montados ao mesmo tempo: uma única notificação disparava
  /// O(cards × favoritos) comparações no thread de UI, durante a animação do
  /// toque.
  ///
  /// **Invariante**: `_favorites` só pode ser tocada por [_add], [_remove] e
  /// [clear] — é o que impede a lista e o índice de divergirem.
  final Set<int> _favoriteIds = {};

  bool _loading = false;

  /// Falha da última carga — null quando deu certo. Existe porque `load()` era
  /// um `try/finally` sem `catch`: um erro de rede virava exceção assíncrona
  /// órfã (o chamador não dá await) e a aba ficava em lista vazia silenciosa,
  /// indistinguível de "você não tem favoritos".
  String? _errorMessage;

  // Evita duas chamadas concorrentes de toggle() pro mesmo storeId (ex:
  // double-tap no coração antes da primeira resposta da API chegar), que
  // podiam disparar add/remove em paralelo e deixar o ícone dessincronizado
  // do que ficou persistido no backend.
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

  /// Busca os favoritos do consumidor autenticado na API. Seguro de chamar
  /// mais de uma vez (ex: a cada abertura da home/aba de favoritos).
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
      // Falha vira estado observável, não exceção que ninguém pega: quem chama
      // `load()` normalmente o faz sem await (login, abertura de aba).
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Não foi possível carregar seus favoritos.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Atualização otimista: alterna localmente e notifica antes de confirmar
  /// com a API. Reverte e relança o erro se a chamada falhar.
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
      // Reverte a atualização otimista — lista e índice juntos.
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

  /// Zera o estado local sem chamar a API — usado no logout, pra não vazar
  /// favoritos de uma conta para a sessão seguinte no mesmo aparelho.
  void clear() {
    _favorites.clear();
    _favoriteIds.clear();
    _pending.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
