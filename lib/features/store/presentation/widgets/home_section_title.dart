import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';

class HomeSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const HomeSectionTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              size: escalaIcone(context, AppIconSize.md),
              color: ColorsPalette.redComponents,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              title,
              style: AppText.subtitulo(context).copyWith(
                fontWeight: FontWeight.w800,
                color: context.mapColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
