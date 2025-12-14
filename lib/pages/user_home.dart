import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/colors_palette.dart';

import 'package:map_food/widgets/chat_input.dart';
import 'package:map_food/widgets/food_category_carousel.dart';
import 'package:map_food/widgets/icon_card.dart';

class UserHome extends StatelessWidget {
  UserHome({super.key});
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHigh = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> items = [
      {"icon": LucideIcons.user, "label": "Perfil"},
      {"icon": LucideIcons.heart, "label": "Favoritos"},

      {"icon": LucideIcons.map, "label": "Mapa"},

      {"icon": LucideIcons.heartHandshake, "label": "Doações"},
      {"icon": LucideIcons.settings, "label": "Ajustes"},
    ];

    return Scaffold(
      backgroundColor: ColorsPalette.brancoOff,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // INPUT + NOTIFICAÇÃO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: ChatInput(controller: controller, onSend: () {}),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          color: ColorsPalette.cinzaBg,
                          size: screenWidth * 0.07,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // "ACESSO RÁPIDO"
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Acesso rápido',
                  style: TextStyle(
                    color: ColorsPalette.cinzaBg.withOpacity(0.85),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // SCROLL HORIZONTAL DOS CARDS
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenWidth * 0.20, // mesma base da largura
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return IconCard(
                      icon: item["icon"],
                      label: item["label"],
                      onTap: () {},
                    );
                  },
                ),
              ),
            ),

            // CARD FAKE + TEXTO
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [buildFakeCard()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [Text("data")],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 40,
                bottom: 16,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Em Destaque',
                  style: TextStyle(
                    color: ColorsPalette.cinzaBg.withOpacity(0.85),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // CARROSSEL DE CATEGORIAS
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHigh * 0.08,
                child: FoodCategoryCarousel(),
              ),
            ),

            // TÍTULO "Recomendações"
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Recomendações para você',
                  style: TextStyle(
                    color: ColorsPalette.cinzaBg.withOpacity(0.85),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // LISTA DE RECOMENDAÇÕES
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => buildFakeCard(),
                  childCount: 3,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget buildFakeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
