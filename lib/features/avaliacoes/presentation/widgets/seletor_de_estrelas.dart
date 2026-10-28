import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

class SeletorDeEstrelas extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double tamanho;

  const SeletorDeEstrelas({
    super.key,
    required this.rating,
    required this.onChanged,
    this.tamanho = 36.0,
  });

  static const _rotulos = ['Péssimo', 'Ruim', 'Regular', 'Bom', 'Excelente'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              SemanticTapArea(
                label: '$i ${i == 1 ? 'estrela' : 'estrelas'}',
                selected: rating == i,
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                    vertical: Spacing.sm,
                  ),
                  child: Icon(
                    i <= rating ? AppIcons.starFill : AppIcons.star,
                    size: escalaIcone(context, tamanho),
                    color: i <= rating ? MfColor.rating : context.mapColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: escalaComTeto(context, 18.0),
          child: rating == 0
              ? null
              : Text(
                  _rotulos[rating - 1],
                  style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
