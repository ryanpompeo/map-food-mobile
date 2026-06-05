import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class MerchantBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const MerchantBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: AppSpacing.lg,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: ColorsPalette.whiteBackground,
          borderRadius: BorderRadius.circular(50.0),
          // Flat Design: Borda limpa em vez de sombra
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: LucideIcons.layoutDashboard,
              label: "Painel",
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _NavItem(
              icon: LucideIcons.star,
              label: "Avaliações",
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            _NavItem(
              icon: LucideIcons.user,
              label: "Perfil",
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
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: AppIconSize.md),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 10.0,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
