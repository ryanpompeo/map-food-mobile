import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';

enum AppButtonVariant {
  primary,

  secondary,

  outline,

  ghost,

  danger,

  inverse,

  onBrand,
}

enum AppButtonSize {
  sm,

  md,
}

class AppButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final AppButtonSize size;

  final IconData? icon;

  final bool loading;

  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final alturaMinima = size == AppButtonSize.md ? 52.0 : 44.0;
    final radius = size == AppButtonSize.md ? Radii.lg : Radii.md;
    final iconSize = escalaIcone(context, size == AppButtonSize.md ? 20.0 : 18.0);

    final (Color background, Color foreground, Color? borderColor) = switch (variant) {
      AppButtonVariant.primary => (MfColor.brand, ColorsPalette.white, null),
      AppButtonVariant.secondary => (colors.surfaceAlt, colors.textPrimary, null),
      AppButtonVariant.outline => (Colors.transparent, colors.textPrimary, colors.borderStrong),
      AppButtonVariant.ghost => (Colors.transparent, colors.brandContent, null),
      AppButtonVariant.danger => (
          isDark ? MfColor.dangerSurfaceDark : MfColor.dangerSurface,
          colors.brandContent,
          null,
        ),
      AppButtonVariant.inverse => (
          colors.selectedSurface,
          colors.onSelectedSurface,
          null,
        ),
      AppButtonVariant.onBrand => (ColorsPalette.white, MfColor.ink, null),
    };

    final overlay = switch (variant) {
      AppButtonVariant.primary ||
      AppButtonVariant.inverse =>
        ColorsPalette.white.withValues(alpha: 0.14),
      _ => colors.textPrimary.withValues(alpha: 0.06),
    };

    final enabled = onPressed != null && !loading;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: alturaMinima,
        minWidth: expand ? double.infinity : 0,
      ),
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? colors.surfaceAlt : background,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? colors.textTertiary : foreground,
          ),
          overlayColor: WidgetStatePropertyAll(overlay),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: size == AppButtonSize.md ? Spacing.xl : Spacing.base),
          ),
          minimumSize: WidgetStatePropertyAll(Size(0, alturaMinima)),
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor),
            ),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: loading
            ? SizedBox(
                height: escalaIcone(context, 18),
                width: escalaIcone(context, 18),
                child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize),
                    const SizedBox(width: Spacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: linhasParaRotulo(context),
                      overflow: TextOverflow.ellipsis,
                      style: AppText.button(context).copyWith(
                        fontSize: size == AppButtonSize.md ? 15 : 14,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
