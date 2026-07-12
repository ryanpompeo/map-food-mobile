import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';

enum NotificationType { success, error, warning }

/// Serviço global de notificações in-app (toasts no canto superior
/// esquerdo), desacoplado da árvore de widgets — chamável de qualquer
/// service/controller/tela sem precisar receber um `BuildContext` local.
///
/// Requer que `NotificationService.instance.navigatorKey` seja passado para
/// `MaterialApp(navigatorKey: ...)` em `main.dart`. Substitui o uso de
/// `ScaffoldMessenger`/`SnackBar` para feedback de sucesso/erro/alerta.
///
/// Uso:
/// ```dart
/// NotificationService.instance.success('Perfil atualizado!');
/// NotificationService.instance.error('Não foi possível salvar.');
/// NotificationService.instance.warning('Sessão prestes a expirar.');
/// ```
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  OverlayEntry? _entry;
  Timer? _timer;
  ValueNotifier<bool>? _visible;

  void success(String message, {Duration duration = const Duration(seconds: 3)}) =>
      _show(message, NotificationType.success, duration);

  void error(String message, {Duration duration = const Duration(seconds: 4)}) =>
      _show(message, NotificationType.error, duration);

  void warning(
    String message, {
    Duration duration = const Duration(seconds: 3, milliseconds: 500),
  }) =>
      _show(message, NotificationType.warning, duration);

  void _show(String message, NotificationType type, Duration duration) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _dismiss(immediate: true);

    final visible = ValueNotifier<bool>(false);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _NotificationBanner(
        message: message,
        type: type,
        visible: visible,
        onTap: () => _dismiss(),
      ),
    );

    _entry = entry;
    _visible = visible;
    overlay.insert(entry);

    WidgetsBinding.instance.addPostFrameCallback((_) => visible.value = true);
    _timer = Timer(duration, () => _dismiss());
  }

  void _dismiss({bool immediate = false}) {
    _timer?.cancel();
    _timer = null;

    final entry = _entry;
    final visible = _visible;
    if (entry == null) return;
    _entry = null;
    _visible = null;

    if (immediate || visible == null) {
      entry.remove();
      return;
    }

    visible.value = false;
    Future.delayed(const Duration(milliseconds: 200), entry.remove);
  }
}

class _NotificationBanner extends StatelessWidget {
  final String message;
  final NotificationType type;
  final ValueListenable<bool> visible;
  final VoidCallback onTap;

  const _NotificationBanner({
    required this.message,
    required this.type,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, tint) = switch (type) {
      NotificationType.success => (LucideIcons.checkCircle2, colors.success),
      NotificationType.error => (LucideIcons.xCircle, colors.error),
      NotificationType.warning => (LucideIcons.alertTriangle, colors.warning),
    };

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      child: ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (context, isVisible, child) {
          return AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            offset: isVisible ? Offset.zero : const Offset(0, -0.3),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isVisible ? 1 : 0,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: tint.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: tint, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
