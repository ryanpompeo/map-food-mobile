import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/glass_container.dart';

class BottomBarItem {
  final IconData icon;

  const BottomBarItem(this.icon);
}

/// Bottom bar flutuante em glass, compartilhada entre guest/consumer/merchant
/// — só a lista de ícones muda entre os três papéis.
class AppBottomBar extends StatelessWidget {
  final List<BottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final double itemSpacing;

  const AppBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.itemSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
        child: GlassContainer(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(width: itemSpacing),
                _NavItem(
                  icon: items[i].icon,
                  isSelected: i == selectedIndex,
                  onTap: () => onItemTapped(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 56,
          height: 56,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Icon(
              icon,
              size: 24.0,
              color: isSelected ? ColorsPalette.redComponents : ColorsPalette.black.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
