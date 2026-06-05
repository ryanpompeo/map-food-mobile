import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class FloatingBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const FloatingBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24.0, left: 48.0, right: 48.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: ColorsPalette.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: LucideIcons.home,
              label: "Início",
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _NavItem(
              icon: LucideIcons.search,
              label: "Busca",
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            _NavItem(
              icon: LucideIcons.user,
              label: "Conta",
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? ColorsPalette.redComponents
        : ColorsPalette.greyDetails;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: AppIconSize.md),
            const SizedBox(height: 2.0),
            Text(
              label,

              style: AppText.legenda(context).copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 10.0,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
