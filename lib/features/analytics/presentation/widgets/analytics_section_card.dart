import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AnalyticsSectionCard extends StatelessWidget {
  final String titulo;

  final String? apoio;

  final Widget child;

  const AnalyticsSectionCard({
    super.key,
    required this.titulo,
    this.apoio,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
            ),
            if (apoio != null) ...[
              const SizedBox(height: 2.0),
              Text(
                apoio!,
                style: AppText.legenda(context).copyWith(
                  fontSize: 11.0,
                  height: 1.35,
                  color: colors.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
