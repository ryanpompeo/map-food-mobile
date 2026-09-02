import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';

class AccountTypeCard extends StatelessWidget {
  final IconData icon;

  final String eyebrow;

  final String title;
  final String description;
  final List<String> benefits;
  final String ctaLabel;
  final VoidCallback onTap;

  final bool highlighted;

  const AccountTypeCard({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.benefits,
    required this.ctaLabel,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final destaqueSolido = highlighted && !isDark;

    final Color titleColor = destaqueSolido ? ColorsPalette.white : colors.textPrimary;
    final Color bodyColor = destaqueSolido
        ? ColorsPalette.white.withValues(alpha: 0.72)
        : colors.textSecondary;
    final Color accent = destaqueSolido ? ColorsPalette.white : MfColor.brand;

    return AppCard(
      onTap: onTap,
      color: destaqueSolido ? MfColor.ink : null,
      elevation: highlighted && isDark ? AppCardElevation.flat : AppCardElevation.raised,
      bordered: !destaqueSolido,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: escalaComTeto(context, 44),
                width: escalaComTeto(context, 44),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: destaqueSolido
                      ? ColorsPalette.white.withValues(alpha: 0.12)
                      : MfColor.brand.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Icon(icon, size: escalaIcone(context, AppIconSize.lg), color: accent),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  style: AppText.overline(context).copyWith(color: bodyColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          Text(title, style: AppText.h2(context).copyWith(color: titleColor)),
          const SizedBox(height: Spacing.xs),
          Text(
            description,
            style: AppText.secondary(context).copyWith(color: bodyColor, height: 1.45),
          ),
          const SizedBox(height: Spacing.lg),

          for (final benefit in benefits) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.checkCircle, size: AppIconSize.sm, color: accent),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      benefit,
                      style: AppText.secondary(context).copyWith(color: bodyColor, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Spacing.md),

          AppButton(
            label: ctaLabel,
            onPressed: onTap,
            size: AppButtonSize.sm,
            variant: switch ((highlighted, isDark)) {
              (true, false) => AppButtonVariant.onBrand,
              (true, true) => AppButtonVariant.inverse,
              _ => AppButtonVariant.primary,
            },
          ),
        ],
      ),
    );
  }
}
