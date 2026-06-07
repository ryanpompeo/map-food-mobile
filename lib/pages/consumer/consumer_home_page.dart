import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/models/consumer/consumer_register_request.dart';
import 'package:map_food/pages/consumer/consumer_favorites_page.dart';
import 'package:map_food/pages/consumer/consumer_profile_page.dart';
import 'package:map_food/pages/consumer/consumer_search.dart';
import 'package:map_food/pages/consumer/widgets/consumer_bottom_bar.dart';
import 'package:map_food/pages/merchant/widgets/merchant_bottom_bar.dart';

class ConsumerHomePage extends StatefulWidget {
  final ConsumerRegisterRequest requestData;

  const ConsumerHomePage({super.key, required this.requestData});

  @override
  State<ConsumerHomePage> createState() => _ConsumerHomePage();
}

class _ConsumerHomePage extends State<ConsumerHomePage> {
  int _selectedIndex = 0;
  String _filtroAtivo = 'Todos';

  final List<String> _filtrosMapa = [
    'Todos',
    'Lanches e Hot Dogs',
    'Espetinhos',
    'Pastel e Salgados',
    'Doces e Sobremesas',
    'Bebidas',
    'Gelados e Açaí',
    'Milho e Pamonha',
    'Pipoca',
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
              ConsumerSearch(),
              ConsumerFavoritesPage(),
              ConsumerProfilePage(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ConsumerBottomBar(
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
        // Header
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
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      color: ColorsPalette.redComponents,
                      size: 28.0,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'MapFood',
                      style: AppText.titulo(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Tags Clicáveis
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
                        onTap: () => setState(() => _filtroAtivo = filtro),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorsPalette.black
                                : ColorsPalette.white,
                            borderRadius: BorderRadius.circular(20.0),
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
