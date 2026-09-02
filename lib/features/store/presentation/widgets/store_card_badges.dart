import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class RatingBadgePill extends StatelessWidget {
  final String rating;

  const RatingBadgePill({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.star, color: ColorsPalette.ratingStar, size: 12),
          const SizedBox(width: 4),
          Text(rating, style: AppText.legenda(context).copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: context.mapColors.primaryText)),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label;

  const InfoChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: context.mapColors.mainBackground,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppText.legenda(context).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
        maxLines: 1, overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class AttributeChip extends StatelessWidget {
  final String label;

  const AttributeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.mapColors.border),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppText.legenda(context).copyWith(fontSize: 14.0, fontWeight: FontWeight.w700, color: context.mapColors.primaryText),
        maxLines: 1, overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
