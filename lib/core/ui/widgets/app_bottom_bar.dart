import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/glass_container.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

class BottomBarItem {
  final IconData icon;

  final String label;

  const BottomBarItem(this.icon, this.label);
}

class AppBottomBar extends StatelessWidget {
  final List<BottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final double itemSpacing;

  static const double _itemSize = 56.0;
  static const double _indicatorSize = 48.0;

  static const double _paddingVertical = 8.0;
  static const double _margemInferior = 32.0;

  static const double reservedSpace =
      _itemSize + (_paddingVertical * 2) + _margemInferior + 4.0;

  static double spaceFor(BuildContext context) =>
      reservedSpace + MediaQuery.paddingOf(context).bottom;

  const AppBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.itemSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _margemInferior, left: 24.0, right: 24.0),
        child: isDark
            ? _buildSolidDark(context)
            : GlassContainer(child: _buildContent(indicatorColor: context.mapColors.cardSurface)),
      ),
    );
  }

  Widget _buildSolidDark(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: _paddingVertical),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _buildContent(indicatorColor: ColorsPalette.white),
    );
  }

  Widget _buildContent({required Color indicatorColor}) {
    return SizedBox(
      height: _itemSize,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: selectedIndex * (_itemSize + itemSpacing),
            top: 0,
            child: SizedBox(
              width: _itemSize,
              height: _itemSize,
              child: Center(
                child: SizedBox(
                  width: _indicatorSize,
                  height: _indicatorSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: indicatorColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(width: itemSpacing),
                _NavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  isSelected: i == selectedIndex,
                  onTap: () => onItemTapped(i),
                ),
              ],
            ],
          ),
        ],
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
    return RepaintBoundary(
      child: SemanticTapArea(
        label: label,
        selected: isSelected,
        onTap: onTap,
        pressFeedback: false,
        child: SizedBox(
          width: AppBottomBar._itemSize,
          height: AppBottomBar._itemSize,
          child: Center(
            child: Icon(
              icon,
              size: 24.0,
              color: !isSelected
                  ? context.mapColors.iconMuted
                  : (Theme.of(context).brightness == Brightness.dark
                        ? ColorsPalette.greyComponents
                        : ColorsPalette.redComponents),
            ),
          ),
        ),
      ),
    );
  }
}
