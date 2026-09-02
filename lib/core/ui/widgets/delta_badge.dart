import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

enum DeltaTone {
  marca,

  semantico,

  semanticoInvertido,
}

class DeltaBadge extends StatelessWidget {
  final int percentual;
  final DeltaTone tone;

  const DeltaBadge({
    super.key,
    required this.percentual,
    this.tone = DeltaTone.marca,
  });

  static (Color, Color) _bom(MapFoodColors colors) =>
      (colors.successContent, MfColor.success.withValues(alpha: 0.12));

  static (Color, Color) _ruim(MapFoodColors colors) =>
      (colors.brandContent, MfColor.danger.withValues(alpha: 0.12));

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final positivo = percentual >= 0;

    final (Color conteudo, Color fundo) = switch (tone) {
      DeltaTone.marca => positivo
          ? (MfColor.brand, MfColor.brand.withValues(alpha: 0.12))
          : (colors.textSecondary, colors.border),
      DeltaTone.semantico => positivo ? _bom(colors) : _ruim(colors),
      DeltaTone.semanticoInvertido => positivo ? _ruim(colors) : _bom(colors),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Text(
        '${positivo ? '+' : ''}$percentual%',
        style: AppText.legenda(context).copyWith(
          fontSize: 11.0,
          fontWeight: FontWeight.w800,
          color: conteudo,
        ),
      ),
    );
  }
}
