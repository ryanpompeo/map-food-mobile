import 'package:flutter/material.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class FoodCategoryCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> categorias = [
    {"nome": "Promoções", "emoji": "🔥", "cor": Colors.redAccent},
    {"nome": "Lanches", "emoji": "🍔", "cor": Colors.orange},
    {"nome": "Japonesa", "emoji": "🍣", "cor": Colors.pinkAccent},
    {"nome": "Pizza", "emoji": "🍕", "cor": Colors.deepOrangeAccent},
    {"nome": "Mercado", "emoji": "🛒", "cor": Colors.greenAccent},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.1,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final item = categorias[index];
          final cor = item["cor"];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: screenWidth * 0.36,
              decoration: BoxDecoration(
                color: ColorsPalette.branco,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Text(
                    item["emoji"],
                    style: TextStyle(fontSize: screenWidth * 0.07),
                  ),

                  SizedBox(width: screenWidth * 0.03),

                  Flexible(
                    child: Text(
                      item["nome"],
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: cor.withOpacity(0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
