import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  final String? subtitle;

  final Widget? trailing;

  final bool? expanded;

  final VoidCallback? onToggle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.expanded,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final conteudo = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.h2(context)),
              if (subtitle != null) ...[
                const SizedBox(height: 2.0),
                Text(subtitle!, style: AppText.secondary(context)),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: Spacing.md),
          trailing!,
        ],
        if (expanded != null) ...[
          const SizedBox(width: Spacing.sm),
          AnimatedRotation(
            duration: Motion.medium,
            turns: expanded! ? 0.5 : 0.0,
            child: Icon(
              AppIcons.caretDown,
              size: escalaIcone(context, AppIconSize.md),
              color: colors.textTertiary,
            ),
          ),
        ],
      ],
    );

    if (onToggle == null) return conteudo;

    return SemanticTapArea(
      label: title,
      hint: expanded == true ? 'Recolhe a seção' : 'Expande a seção',
      selected: expanded,
      onTap: onToggle,
      child: conteudo,
    );
  }
}
