import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/widgets/chat_input.dart';
import 'package:map_food/widgets/food_category_carousel.dart';


class UserHome extends StatelessWidget {
  UserHome({super.key});
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.branco,

      appBar: AppBar(
      
      ),

      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            ChatInput(controller: controller, onSend: () {}),

            const SizedBox(height: 28),

            Text(
              'Em Destaque',
              style: TextStyle(
                color: ColorsPalette.cinzaBg.withOpacity(0.85),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(height: 80, child: FoodCategoryCarousel()),

            const SizedBox(height: 40),

            // Exemplo extra pra preencher a tela
            Text(
              'Recomendações para você',
              style: TextStyle(
                color: ColorsPalette.cinzaBg.withOpacity(0.85),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            buildFakeCard(),
            buildFakeCard(),
            buildFakeCard(),

            const SizedBox(height: 80),
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
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
