import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';

class SeloDestaque extends StatelessWidget {
  final bool sobreFoto;

  const SeloDestaque({super.key, this.sobreFoto = false});

  @override
  Widget build(BuildContext context) {
    final cor = sobreFoto ? ColorsPalette.white : MfColor.ratingText;

    return Semantics(
      label: 'Loja em destaque',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: sobreFoto
              ? Colors.black.withValues(alpha: 0.35)
              : MfColor.rating.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: sobreFoto
                ? ColorsPalette.white.withValues(alpha: 0.35)
                : MfColor.rating.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.crownFill, size: escalaIcone(context, 11.0), color: cor),
            const SizedBox(width: 4.0),
            Text(
              'Destaque',
              style: AppText.legenda(context).copyWith(
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
