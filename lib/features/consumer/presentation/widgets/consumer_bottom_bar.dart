import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';

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
    return AppBottomBar(
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
      itemSpacing: 4.0,
      items: const [
        BottomBarItem(PhosphorIconsRegular.house),
        BottomBarItem(PhosphorIconsRegular.magnifyingGlass),
        BottomBarItem(PhosphorIconsRegular.user),
      ],
    );
  }
}
