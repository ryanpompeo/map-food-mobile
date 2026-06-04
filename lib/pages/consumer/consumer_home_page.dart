import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/consumer/widgets/consumer_bottom_bar.dart';

import 'package:map_food/pages/search/search_page.dart';

// TODO: Importar as páginas reais assim que forem criadas
// import 'package:map_food/pages/orders/orders_page.dart';
// import 'package:map_food/pages/profile/consumer_profile_page.dart';

class ConsumerHomePage extends StatefulWidget {
  const ConsumerHomePage({super.key});

  @override
  State<ConsumerHomePage> createState() => _ConsumerHomePageState();
}

class _ConsumerHomePageState extends State<ConsumerHomePage> {
  int _selectedIndex = 0;
  String _filtroAtivo = 'Todos';

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

              const Center(child: Text("Tela de Visitas em Andamento")),

              const Center(child: Text("Perfil do Consumidor Logado")),
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
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12.0,
            bottom: 16.0,
          ),
          decoration: BoxDecoration(
            color: ColorsPalette.whiteBackground,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          debugPrint("Abrir seletor de endereço (Logado)"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              color: ColorsPalette.redComponents,
                              size: 16.0,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              "Rua Principal, 123",
                              style: AppText.legenda(context).copyWith(
                                fontWeight: FontWeight.w800,
                                color: ColorsPalette.black,
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 16.0,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _onItemTapped(1),
                      icon: const Icon(
                        LucideIcons.search,
                        color: ColorsPalette.blackDetails,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 40.0,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: _filtrosMapa.length,
                  itemBuilder: (context, index) {
                    final filtro = _filtrosMapa[index];
                    final bool isSelected = _filtroAtivo == filtro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _filtroAtivo = filtro;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorsPalette.blackComponents
                                : ColorsPalette.whiteBackground,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: isSelected
                                  ? ColorsPalette.blackComponents
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            filtro,
                            style: AppText.legenda(context).copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : ColorsPalette.black,
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
