import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDark;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDark = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          // Botão secundário: fundo de superfície (se adapta ao tema); o
          // texto/ícone de marca abaixo NÃO se adapta — é escolhido por
          // quem chama via `isDark`, não pelo ThemeMode do app.
          backgroundColor: context.mapColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              overflow: TextOverflow.visible,
              style: AppText.botao(context).copyWith(
                color: isDark
                    ? ColorsPalette.blackComponents
                    : ColorsPalette.redComponents,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: isDark
                  ? ColorsPalette.blackComponents
                  : ColorsPalette.redComponents,
              size: AppIconSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
