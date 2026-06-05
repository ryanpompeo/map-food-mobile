import 'package:flutter/material.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/guest/profile/guest_profile_page.dart';
import 'package:map_food/pages/guest/widgets/floating_bottom_bar.dart';
import 'package:map_food/pages/search/search_page.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  int _selectedIndex = 0;
  final String _filtroAtivo = 'Todos';

  final List<String> _filtrosMapa = [
    'Todos',
    'Lanches',
    'Doces',
    'Bebidas',
    'Saudável',
    'Espetinhos',
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
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
              _buildAbaInicio(),
              const SearchPage(),
              const GuestProfilePage(),
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

  Widget _buildAbaInicio() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12.0,
            bottom: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: ColorsPalette.whiteBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/images/app_icon_copy.png',
                        width: 36.0,
                        height: 36.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'MapFood',
                      style: AppText.titulo(context).copyWith(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: ColorsPalette.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 40.0,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _filtrosMapa.length,
                  itemBuilder: (context, index) {
                    final filtro = _filtrosMapa[index];
                    final bool isSelected = _filtroAtivo == filtro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => (filtro),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 0.0,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorsPalette.redComponents
                                : ColorsPalette.whiteBackground,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: isSelected
                                  ? ColorsPalette.redComponents
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            filtro,
                            style: AppText.legenda(context).copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
