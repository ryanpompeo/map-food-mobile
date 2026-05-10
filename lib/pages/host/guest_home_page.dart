import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/profile/guest_profile_page.dart';
import 'package:map_food/core/widgets/app_search_bar.dart';
import 'package:map_food/pages/host/widgets/floating_bottom_bar.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              buildAbaInicio(),
              buildAbaBusca(),
              const GuestProfilePage(),
            ],
          ),
          FloatingBottomBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ],
      ),
    );
  }

  Widget buildAbaInicio() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12.0,
            left: 24.0,
            right: 24.0,
            bottom: 20.0,
          ),
          decoration: BoxDecoration(
            color: ColorsPalette.whiteBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      print("Abrir endereço");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            color: ColorsPalette.redComponents,
                            size: 14.0,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            "Limeira, SP",
                            style: AppText.legenda(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Icon(
                            LucideIcons.chevronDown,
                            size: 14.0,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text(
                "O que você está buscando?",
                style: AppText.subtitulo(context).copyWith(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16.0),
              AppSearchBar(
                controller: _searchController,
                onFilterTap: () => print("Abrir filtros"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAbaBusca() {
    return Center(
      child: Text(
        "Página de Busca",
        textAlign: TextAlign.center,
        style: AppText.corpo(context).copyWith(color: Colors.grey),
      ),
    );
  }
}
