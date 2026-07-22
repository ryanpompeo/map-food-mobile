import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Pill branca flutuante com estrela + nota, para sobrepor no canto da foto
/// do card (mesmo padrão do badge de rating dos cards de listagem do anexo
/// de referência visual).
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
          Icon(PhosphorIconsRegular.star, color: Colors.amber.shade500, size: 12),
          const SizedBox(width: 4),
          Text(rating, style: AppText.legenda(context).copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: context.mapColors.primaryText)),
        ],
      ),
    );
  }
}

/// Chip cápsula cinza-claro para atributos secundários (categoria, etc.),
/// mesmo tratamento visual dos chips de atributo ("3 quartos", "2 vagas")
/// do anexo de referência.
class InfoChip extends StatelessWidget {
  final String label;

  const InfoChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        // Um tom abaixo do cardSurface do card que envolve este chip (ver
        // mesmo raciocínio em image_picker_sheet.dart, Lote 2).
        color: context.mapColors.mainBackground,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        // Sem override de cor: legenda() já resolve pra secondaryText.
        style: AppText.legenda(context).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
        maxLines: 1, overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Chip cápsula com contorno fino e texto preto em negrito — mesmo
/// tratamento dos chips de atributo ("3 quartos", "2 vagas", "145 m²") do
/// card de listagem do anexo de referência.
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
