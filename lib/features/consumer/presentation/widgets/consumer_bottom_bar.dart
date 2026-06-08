import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

class ConsumerBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const ConsumerBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100.0),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavItem(
                      icon: LucideIcons.house,
                      isSelected: selectedIndex == 0,
                      onTap: () => onItemTapped(0),
                    ),
                    const SizedBox(width: 4),
                    _NavItem(
                      icon: LucideIcons.search,
                      isSelected: selectedIndex == 1,
                      onTap: () => onItemTapped(1),
                    ),
                    const SizedBox(width: 4.0),
                    _NavItem(
                      icon: LucideIcons.heart,
                      isSelected: selectedIndex == 2,
                      onTap: () => onItemTapped(2),
                    ),
                    const SizedBox(width: 4.0),
                    _NavItem(
                      icon: LucideIcons.user,
                      isSelected: selectedIndex == 3,
                      onTap: () => onItemTapped(3),
                    ),
                  ],
                ),
              ),
            ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: isSelected ? ColorsPalette.transparent : Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24.0,
            color: isSelected
                ? ColorsPalette.redComponents
                : ColorsPalette.black.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
