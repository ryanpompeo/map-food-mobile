import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;

  final VoidCallback? onTap;

  final Color? selectedSurface;

  final Color? onSelectedSurface;

  final Color? unselectedSurface;

  final IconData? icon;

  final Color? iconColor;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedSurface,
    this.onSelectedSurface,
    this.unselectedSurface,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final fundoAtivo = selectedSurface ?? colors.selectedSurface;
    final conteudoAtivo = onSelectedSurface ?? colors.onSelectedSurface;
    final fundoInativo = unselectedSurface ?? colors.surface;

    final conteudo = selected ? conteudoAtivo : colors.textSecondary;

    return SemanticTapArea(
      label: label,
      selected: selected,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: 9.0),
        decoration: BoxDecoration(
          color: selected ? fundoAtivo : fundoInativo,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: selected ? fundoAtivo : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              ExcludeSemantics(
                child: Icon(
                  AppIcons.check,
                  size: escalaIcone(context, 14.0),
                  color: conteudoAtivo,
                ),
              ),
              const SizedBox(width: 6.0),
            ] else if (icon != null) ...[
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: escalaIcone(context, 14.0),
                  color: iconColor ?? conteudo,
                ),
              ),
              const SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: AppText.caption(context).copyWith(
                fontWeight: FontWeight.w700,
                color: conteudo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
