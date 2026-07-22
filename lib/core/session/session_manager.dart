import 'package:flutter/material.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';

/// Reage a um 401 vindo da API limpando a sessão e voltando pro login —
/// sem isso, um token expirado deixava o app "logado" falhando em silêncio,
/// já que cada tela só fazia catch(_) do erro.
class SessionManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Várias requisições podem falhar com 401 ao mesmo tempo (ex: home
  // disparando lojas + categorias + favoritos em paralelo com token
  // expirado) — só o primeiro 401 executa a limpeza/navegação.
  static bool _handling = false;

  /// Ponto único de limpeza de estado por-usuário (singletons `ChangeNotifier`
  /// que sobrevivem entre sessões). Chame isso sempre que uma sessão termina
  /// — logout manual, exclusão de conta ou 401 — antes de navegar pra fora da
  /// área autenticada. Síncrono e em lote de propósito: cada `clear()` só
  /// reseta campos e chama `notifyListeners()`, sem I/O, então não há motivo
  /// pra `await` nem risco de a navegação seguinte disparar no meio de uma
  /// operação pendente.
  ///
  /// Registre aqui o `clear()` de qualquer singleton novo com estado que não
  /// deva vazar de uma conta pra outra no mesmo aparelho. Nunca chame
  /// `dispose()` nesses singletons — eles são reutilizados pelo resto da vida
  /// do processo; `dispose()` os deixaria permanentemente inutilizáveis e
  /// qualquer `notifyListeners()` seguinte lançaria
  /// "A ChangeNotifier was used after being disposed".
  static void clearUserScopedState() {
    FavoritesManager.instance.clear();
    // ActiveStoresManager NÃO entra aqui de propósito: guarda a lista
    // pública de lojas ativas (mesmo dado pra qualquer usuário), não estado
    // por-conta — limpar geraria só um flicker/refetch à toa.
  }

  /// Só age se havia sessão salva: um 401 de senha errada na tela de login
  /// não tem token salvo ainda, então não deve disparar esse fluxo.
  static Future<void> handleUnauthorized([String? message]) async {
    if (_handling) return;
    _handling = true;
    try {
      final hadSession = await AuthStorage.getToken() != null;
      if (!hadSession) return;

      await AuthStorage.clear();
      clearUserScopedState();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );

      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Sessão expirada. Faça login novamente.')),
        );
      }
    } finally {
      _handling = false;
    }
  }
}
