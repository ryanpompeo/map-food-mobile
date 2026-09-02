import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AccountTypeSwitch extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const AccountTypeSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.mapColors.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.md + 4),
      ),
      child: Row(
        children: [
          _segmento(
            context,
            tipo: 'CONSUMIDOR',
            label: 'Consumidor',
            ativo: context.mapColors.selectedSurface,
            aoAtivo: context.mapColors.onSelectedSurface,
          ),
          const SizedBox(width: 4),
          _segmento(
            context,
            tipo: 'COMERCIANTE',
            label: 'Comerciante',
            ativo: MfColor.brand,
            aoAtivo: ColorsPalette.white,
          ),
        ],
      ),
    );
  }

  Widget _segmento(
    BuildContext context, {
    required String tipo,
    required String label,
    required Color ativo,
    required Color aoAtivo,
  }) {
    final selecionado = value == tipo;

    return Expanded(
      child: SemanticTapArea(
        label: label,
        selected: selecionado,
        onTap: () => onChanged(tipo),
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selecionado ? ativo : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Text(
            label,
            style: AppText.button(context).copyWith(
              fontSize: 14,
              color: selecionado ? aoAtivo : context.mapColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
