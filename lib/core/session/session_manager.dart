import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';

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

      await SessionStore.instance.signOut();
      clearUserScopedState();
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
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
