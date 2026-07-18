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

  /// Só age se havia sessão salva: um 401 de senha errada na tela de login
  /// não tem token salvo ainda, então não deve disparar esse fluxo.
  static Future<void> handleUnauthorized([String? message]) async {
    if (_handling) return;
    _handling = true;
    try {
      final hadSession = await AuthStorage.getToken() != null;
      if (!hadSession) return;

      await AuthStorage.clear();
      FavoritesManager.instance.clear();
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
