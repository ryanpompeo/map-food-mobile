import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

class RatingStars extends StatelessWidget {
  final num nota;

  final double size;
  final int max;

  final String? semanticsLabel;

  const RatingStars({
    super.key,
    required this.nota,
    this.size = AppIconSize.sm,
    this.max = 5,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? 'Nota ${nota.toStringAsFixed(0)} de $max',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < max; i++)
            Icon(
              i < nota ? AppIcons.starFill : AppIcons.star,
              size: size,
              color: i < nota
                  ? MfColor.rating
                  : MfColor.rating.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }
}

class RatingScorePill extends StatelessWidget {
  final double? nota;

  final bool dense;

  const RatingScorePill({super.key, required this.nota, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final semNota = nota == null;
    final texto = semNota ? 'Novo' : nota!.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? Spacing.sm : Spacing.md,
        vertical: dense ? Spacing.xs : 6.0,
      ),
      decoration: BoxDecoration(
        color: MfColor.rating.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            semNota ? AppIcons.star : AppIcons.starFill,
            size: dense ? 13.0 : AppIconSize.md,
            color: MfColor.rating,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            texto,
            style: AppText.numeric(context, size: dense ? 12.0 : 15.0)
                .copyWith(color: MfColor.ratingText, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
