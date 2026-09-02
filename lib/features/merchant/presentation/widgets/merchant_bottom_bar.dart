import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';

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
    return AppBottomBar(
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
      items: const [
        BottomBarItem(AppIcons.house, 'Início'),
        BottomBarItem(AppIcons.chartLineUp, 'Estatísticas'),
        BottomBarItem(AppIcons.storefront, 'Minha loja'),
        BottomBarItem(AppIcons.user, 'Perfil'),
      ],
    );
  }
}
