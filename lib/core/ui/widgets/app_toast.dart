import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

enum _AppToastType { success, error, warning, info }

/// Alerta de sucesso/erro em pop-up no canto superior direito que some
/// sozinho depois de alguns segundos — infra única de notificação do app,
/// substituindo os SnackBars/AlertDialogs que antes ficavam espalhados
/// (e cada um decidia sua própria posição/duração/estilo).
///
/// O corpo do toast é **preenchido** com a cor semântica: verde, vermelho,
/// amarelo ou azul de ponta a ponta. A versão anterior usava a superfície de
/// card com a cor só na borda a 25% de opacidade e no ícone — o que fazia os
/// quatro estados parecerem o mesmo aviso de longe, que é justamente quando o
/// toast é lido (ele some em 3s, no canto da tela, enquanto a pessoa olha para
/// outra coisa).
class AppToast {
  static OverlayEntry? _current;
  static VoidCallback? _removeCurrent;

  static void success(BuildContext context, String message) {
    _show(context, message, _AppToastType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, _AppToastType.error);
  }

  /// Atenção: a ação foi adiante, mas com ressalva — ou está prestes a ir e
  /// convém saber de algo antes (limite atingido, dado faltando, permissão
  /// negada que degrada a tela sem quebrá-la). Fica entre [info] e [error].
  static void warning(BuildContext context, String message) {
    _show(context, message, _AppToastType.warning);
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
    // Fundo na cor semântica + o conteúdo que passa em contraste sobre ele.
    // O par vem junto de propósito: separar "cor do fundo" de "cor do texto"
    // em dois switches é como se perde a garantia de contraste na primeira
    // vez que alguém acrescenta um tipo novo.
    final (fundo, conteudo, icon) = switch (widget.type) {
      _AppToastType.success => (MfColor.successFill, ColorsPalette.white, AppIcons.checkCircle),
      _AppToastType.error => (MfColor.dangerFill, ColorsPalette.white, AppIcons.warningCircle),
      // O único com texto escuro — ver `MfColor.warningFill`.
      _AppToastType.warning => (MfColor.warningFill, MfColor.ink, AppIcons.warning),
      _AppToastType.info => (MfColor.infoFill, ColorsPalette.white, AppIcons.info),
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
                        color: fundo,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        // Sem borda: com o corpo inteiro preenchido, ela só
                        // acrescentaria um contorno de outra cor sobre a cor.
                        boxShadow: [
                          BoxShadow(
                            color: ColorsPalette.black.withValues(alpha: 0.20),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: conteudo, size: AppIconSize.md),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: AppText.corpo(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: conteudo,
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
