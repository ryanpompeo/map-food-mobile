import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

class WizardFooter extends StatelessWidget {
  final String labelPrimario;

  final VoidCallback? onPrimario;

  final bool carregando;

  final VoidCallback? onVoltar;

  final String labelSecundario;

  final IconData? iconePrimario;

  const WizardFooter({
    super.key,
    required this.labelPrimario,
    required this.onPrimario,
    this.carregando = false,
    this.onVoltar,
    this.labelSecundario = 'Voltar',
    this.iconePrimario,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.md,
            Spacing.lg,
            Spacing.md,
          ),
          child: Row(
            children: [
              if (onVoltar != null) ...[
                Expanded(
                  child: AppButton(
                    label: labelSecundario,
                    onPressed: carregando ? null : onVoltar,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: Spacing.md),
              ],
              Expanded(
                flex: 2,
                child: AppButton(
                  label: labelPrimario,
                  icon: iconePrimario,
                  onPressed: onPrimario,
                  loading: carregando,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
