import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// Fileira horizontal de pills de filtro de categoria usada no header das
/// três home pages (guest, consumidor e comerciante) — antes copiada 3×.
class CategoryFilterChips extends StatelessWidget {
  final List<String> filtros;
  final String ativo;
  final ValueChanged<String> onSelect;

  const CategoryFilterChips({
    super.key,
    required this.filtros,
    required this.ativo,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final bool isSelected = ativo == filtro;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => onSelect(filtro),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? ColorsPalette.black : ColorsPalette.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  filtro,
                  style: AppText.legenda(context).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
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
