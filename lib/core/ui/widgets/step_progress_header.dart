import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class StepProgressHeader extends StatelessWidget {
  final int etapaAtual;

  final int total;

  final String? rotulo;

  const StepProgressHeader({
    super.key,
    required this.etapaAtual,
    required this.total,
    this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 6.0),
              Expanded(
                child: AnimatedContainer(
                  duration: Motion.medium,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: i <= etapaAtual ? MfColor.brand : colors.border,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Text(
              'Etapa ${etapaAtual + 1} de $total',
              style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w700),
            ),
            if (rotulo != null) ...[
              Text('  ·  ', style: AppText.legenda(context)),
              Expanded(
                child: Text(
                  rotulo!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.legenda(context),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
