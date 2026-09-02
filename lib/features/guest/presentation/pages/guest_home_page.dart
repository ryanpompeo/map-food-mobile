import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/guest/presentation/pages/guest_profile_page.dart';
import 'package:map_food/features/guest/presentation/widgets/floating_bottom_bar.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/store/presentation/widgets/home_map_explorer.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  final ValueNotifier<int> _abaAtual = ValueNotifier(0);

  @override
  void dispose() {
    _abaAtual.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_abaAtual.value == index) return;
    _abaAtual.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final abas = [
      RepaintBoundary(
        child: HomeMapExplorer(onSearchTap: () => _onItemTapped(1)),
      ),
      const RepaintBoundary(child: SearchPage()),
      const RepaintBoundary(child: GuestProfilePage()),
    ];

    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      body: Stack(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _abaAtual,
            builder: (context, index, _) => IndexedStack(index: index, children: abas),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _abaAtual,
              builder: (context, index, _) => FloatingBottomBar(
                selectedIndex: index,
                onItemTapped: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
