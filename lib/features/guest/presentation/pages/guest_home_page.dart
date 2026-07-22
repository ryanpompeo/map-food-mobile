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
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      body: Stack(
        children: [
          // RepaintBoundary em cada aba: isola o layer de pintura de cada uma
          // — a troca de aba passa a ser só trocar qual layer já pronto
          // mostrar, sem repintar o mapa das abas que não mudaram.
          IndexedStack(
            index: _selectedIndex,
            children: [
              RepaintBoundary(
                child: HomeMapExplorer(onSearchTap: () => _onItemTapped(1)),
              ),
              const RepaintBoundary(child: SearchPage()),
              const RepaintBoundary(child: GuestProfilePage()),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingBottomBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
