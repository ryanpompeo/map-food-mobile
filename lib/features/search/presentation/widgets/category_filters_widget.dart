import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/search/presentation/utils/category_icons.dart';

/// Filtros de categoria em avatares circulares (ícone/foto + legenda),
/// em vez de chips de texto — rolagem horizontal, como em apps de delivery.
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
      height: 92.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filtros.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16.0),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final isTodos = index == 0;
          final visual = isTodos ? null : categoryVisualFor(filtros[index]);
          final tintColor = isSelected ? ColorsPalette.redComponents : ColorsPalette.greyText;

          return GestureDetector(
            onTap: () => onFilterChanged(index),
            child: SizedBox(
              width: 64.0,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 60.0,
                    height: 60.0,
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? ColorsPalette.redComponents : Colors.grey.shade200,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? ColorsPalette.redComponents.withValues(alpha: 0.08) : ColorsPalette.white,
                      ),
                      child: Center(
                        child: isTodos
                            ? Icon(LucideIcons.layoutGrid, size: 24.0, color: tintColor)
                            : visual!.assetPath != null
                                ? ClipOval(
                                    child: Image.asset(
                                      visual.assetPath!,
                                      width: 56.0,
                                      height: 56.0,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(visual.fallbackIcon, size: 24.0, color: tintColor),
                                    ),
                                  )
                                : Icon(visual.fallbackIcon, size: 24.0, color: tintColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    filtros[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.legenda(context).copyWith(
                      fontSize: 11.0,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? ColorsPalette.redComponents : ColorsPalette.greyText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
