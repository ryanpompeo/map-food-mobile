import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
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

  // Área de toque de cada item (56x56, padrão ergonômico Material/Apple) e
  // diâmetro do indicador de seleção que desliza por trás dos ícones.
  static const double _itemSize = 56.0;
  static const double _indicatorSize = 48.0;

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
          child: SizedBox(
            height: _itemSize,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Indicador único que desliza de um ícone pro outro — em vez
                // de cada item ligar/desligar seu próprio fundo, só um deles
                // se move, o que lê como transição contínua ao trocar de aba.
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
                            color: context.mapColors.cardSurface,
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
                        isSelected: i == selectedIndex,
                        onTap: () => onItemTapped(i),
                      ),
                    ],
                  ],
                ),
              ],
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
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: AppBottomBar._itemSize,
          height: AppBottomBar._itemSize,
          child: Center(
            // Só a cor do ícone é animada aqui — o fundo circular já é o
            // indicador deslizante do AppBottomBar, compartilhado entre itens.
            child: TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              tween: ColorTween(
                end: isSelected
                    ? ColorsPalette.redComponents
                    : context.mapColors.iconMuted,
              ),
              builder: (context, color, child) => Icon(icon, size: 24.0, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
