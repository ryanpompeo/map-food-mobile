import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

enum _AppToastType { success, error, info }

/// Alerta de sucesso/erro em pop-up no canto superior direito que some
/// sozinho depois de alguns segundos — infra única de notificação do app,
/// substituindo os SnackBars/AlertDialogs que antes ficavam espalhados
/// (e cada um decidia sua própria posição/duração/estilo).
class AppToast {
  static OverlayEntry? _current;
  static VoidCallback? _removeCurrent;

  static void success(BuildContext context, String message) {
    _show(context, message, _AppToastType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, _AppToastType.error);
  }

  /// Aviso neutro: nada deu errado, só não há o que fazer ainda (recurso em
  /// desenvolvimento, ação indisponível no momento). Usar [error] para isso
  /// pintaria de vermelho uma situação que não é falha.
  static void info(BuildContext context, String message) {
    _show(context, message, _AppToastType.info);
  }

  static void _show(BuildContext context, String message, _AppToastType type) {
    // Só um toast por vez — um novo alerta substitui o anterior em vez de
    // empilhar, evitando poluir a tela em telas com várias ações seguidas.
    _removeCurrent?.call();
    _current = null;
    _removeCurrent = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    // Evita chamar entry.remove() duas vezes (uma pelo toast seguinte
    // substituindo este, outra pelo próprio onDismissed ao terminar a
    // animação de saída) — remover um OverlayEntry já removido derruba o app.
    var removed = false;
    void safeRemove() {
      if (removed) return;
      removed = true;
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (overlayContext) => _AppToastWidget(
        message: message,
        type: type,
        onDismissed: () {
          if (identical(_current, entry)) {
            _current = null;
            _removeCurrent = null;
          }
          safeRemove();
        },
      ),
    );
    _current = entry;
    _removeCurrent = safeRemove;
    overlay.insert(entry);
  }
}

class _AppToastWidget extends StatefulWidget {
  final String message;
  final _AppToastType type;
  final VoidCallback onDismissed;

  const _AppToastWidget({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<_AppToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(begin: const Offset(0.15, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    if (mounted) await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (accentColor, icon) = switch (widget.type) {
      _AppToastType.success => (const Color(0xFF16A34A), AppIcons.checkCircle),
      _AppToastType.error => (ColorsPalette.redComponents, AppIcons.warningCircle),
      _AppToastType.info => (context.mapColors.brandContent, AppIcons.info),
    };

    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.sm,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topRight,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Material(
                color: Colors.transparent,
                child: SemanticTapArea(
                  // O texto do aviso é lido pelo nó do próprio Text abaixo;
                  // aqui o rótulo descreve só o que o toque faz.
                  label: 'Dispensar aviso',
                  onTap: _dismiss,
                  // O toast já entra e sai animado — encolher no toque
                  // brigaria com a animação de saída que o toque dispara.
                  pressFeedback: false,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14.0),
                      decoration: BoxDecoration(
                        color: context.mapColors.cardSurface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: ColorsPalette.black.withValues(alpha: 0.14),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: accentColor, size: AppIconSize.md),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: AppText.corpo(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.mapColors.primaryText,
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
          ),
        ),
      ),
    );
  }
}
