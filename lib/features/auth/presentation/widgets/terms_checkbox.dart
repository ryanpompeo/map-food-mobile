import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';

class TermsCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  final Color? activeColor;

  final String leadingText;

  final String primaryLinkLabel;

  final String? secondaryLinkLabel;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.leadingText = 'Eu li e concordo com os ',
    this.primaryLinkLabel = 'Termos de Uso',
    this.secondaryLinkLabel = 'Política de Privacidade',
  });

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  late final TapGestureRecognizer _termosRecognizer;
  late final TapGestureRecognizer _privacidadeRecognizer;

  @override
  void initState() {
    super.initState();
    _termosRecognizer = TapGestureRecognizer()..onTap = _abrirTermos;
    _privacidadeRecognizer = TapGestureRecognizer()..onTap = _abrirTermos;
  }

  @override
  void dispose() {
    _termosRecognizer.dispose();
    _privacidadeRecognizer.dispose();
    super.dispose();
  }

  void _abrirTermos() {
    Navigator.push(context, appPageRoute(builder: (_) => const TermosPage()));
  }

  TextStyle _linkStyle(BuildContext context, Color color) {
    return AppText.secondary(context).copyWith(
      fontWeight: FontWeight.w600,
      color: color,
      decoration: TextDecoration.underline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return FormField<bool>(
      initialValue: widget.value,
      validator: (aceito) =>
          (aceito ?? false) ? null : 'É preciso aceitar os termos para continuar.',
      builder: (state) {
        void alternar() {
          final novo = !widget.value;
          widget.onChanged(novo);
          state.didChange(novo);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppIconSize.lg,
                  width: AppIconSize.lg,
                  child: Checkbox(
                    value: widget.value,
                    activeColor: widget.activeColor ?? colors.selectedSurface,
                    checkColor: widget.activeColor == null
                        ? colors.onSelectedSurface
                        : ColorsPalette.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.sm - 2),
                    ),
                    side: BorderSide(
                      color: state.hasError ? MfColor.danger : colors.border,
                      width: 1.5,
                    ),
                    onChanged: (_) => alternar(),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: GestureDetector(
                    onTap: alternar,
                    child: Text.rich(
                      TextSpan(
                        text: widget.leadingText,
                        style: AppText.secondary(context).copyWith(height: 1.5),
                        children: [
                          TextSpan(
                            text: widget.primaryLinkLabel,
                            recognizer: _termosRecognizer,
                            style: _linkStyle(context, colors.textPrimary),
                          ),
                          if (widget.secondaryLinkLabel != null) ...[
                            const TextSpan(text: ' e a '),
                            TextSpan(
                              text: widget.secondaryLinkLabel,
                              recognizer: _privacidadeRecognizer,
                              style: _linkStyle(context, colors.textPrimary),
                            ),
                          ],
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasError) ...[
              const SizedBox(height: Spacing.sm),
              Padding(
                padding: const EdgeInsets.only(left: 36.0),
                child: Text(
                  state.errorText!,
                  style: AppText.caption(context).copyWith(color: MfColor.danger),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
