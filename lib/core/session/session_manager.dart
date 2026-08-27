import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';

/// Reage a um 401 vindo da API limpando a sessão e voltando pro login —
/// sem isso, um token expirado deixava o app "logado" falhando em silêncio,
/// já que cada tela só fazia catch(_) do erro.
class SessionManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static bool _handling = false;

  static void clearUserScopedState() {
    FavoritesManager.instance.clear();
  }

  static Future<void> handleUnauthorized([String? message]) async {
    if (_handling) return;
    _handling = true;
    try {
      final hadSession = await AuthStorage.getToken() != null;
      if (!hadSession) return;

      // signOut limpa disco E memória — sem isso o SessionStore continuaria
      // publicando um usuário logado que a API já rejeitou.
      await SessionStore.instance.signOut();
      clearUserScopedState();
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        // Sem await de propósito: este Future só completa quando a tela de
        // login for descartada, e o `finally` abaixo precisa liberar o guard
        // de 401 agora — aguardar aqui travaria `_handling` em true para sempre.
        unawaited(
          navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
        );
      }

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
