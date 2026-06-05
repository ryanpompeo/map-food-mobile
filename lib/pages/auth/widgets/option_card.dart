import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/auth/widgets/app_button.dart';

Widget optionCard({
  required String title,
  required String description,
  required List<String> benefits,
  required String buttonText,
  required bool isDark,
  required VoidCallback onTap,
  required bool isCustomer,
  required BuildContext context,
}) {
  final Color cardColor = isCustomer
      ? ColorsPalette.blackComponents
      : ColorsPalette.redComponents;

  return Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      boxShadow: [
        BoxShadow(
          color: cardColor.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCustomer ? "PERFIL COMUM" : "PERFIL COMERCIAL",
              style: AppText.legenda(context).copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: const BoxDecoration(
                color: ColorsPalette.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCustomer ? LucideIcons.user2 : LucideIcons.store,
                color: ColorsPalette.white,
                size: AppIconSize.md,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        /// TÍTULO PRINCIPAL
        Text(
          title,
          style: AppText.titulo(context).copyWith(color: ColorsPalette.white),
        ),
        const SizedBox(height: AppSpacing.xs),

        /// DESCRIÇÃO
        Text(
          description,
          style: AppText.secundario(context).copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32.0),

        /// BENEFITS
        ...benefits.map((b) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.checkCircle2,
                  color: ColorsPalette.white.withValues(alpha: 0.6),
                  size: AppIconSize.sm,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    b,
                    textAlign: TextAlign.left,
                    style: AppText.legenda(context).copyWith(
                      color: ColorsPalette.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: AppSpacing.xl),

        /// BUTTON
        SizedBox(
          width: double.infinity,
          child: AppButton(text: buttonText, onPressed: onTap, isDark: isDark),
        ),
      ],
    ),
  );
}
