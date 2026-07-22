import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Filtros de categoria em pill de texto — mesmo visual das "Tags Clicáveis"
/// da home (fundo preto quando selecionado, branco quando não).
class CategoryFiltersWidget extends StatelessWidget {
  final List<String> filtros;
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;

  const CategoryFiltersWidget({
    super.key, required this.filtros, required this.selectedIndex, required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filtros.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12.0),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return RepaintBoundary(
            child: GestureDetector(
              onTap: () => onFilterChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? ColorsPalette.black : context.mapColors.cardSurface,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  filtros[index],
                  style: AppText.legenda(context).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    // Não-selecionado sem override: legenda() já resolve pra secondaryText.
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
