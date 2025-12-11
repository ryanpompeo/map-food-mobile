import 'package:flutter/material.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class FoodCategoryCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> categorias = [
    {"nome": "Promoções", "icon": Icons.local_offer, "cor": Colors.redAccent},
    {"nome": "Lanches", "icon": Icons.fastfood, "cor": Colors.orange},
    {"nome": "Japonesa", "icon": Icons.rice_bowl, "cor": Colors.pinkAccent},
    {
      "nome": "Pizza",
      "icon": Icons.local_pizza,
      "cor": Colors.deepOrangeAccent,
    },
    {"nome": "Mercado", "icon": Icons.storefront, "cor": Colors.greenAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final item = categorias[index];
        final Color cor = item["cor"];

        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: ColorsPalette.brancoOff.withOpacity(0.85),
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(item["icon"], size: 30, color: cor.withOpacity(0.9)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item["nome"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cor.withOpacity(0.95),
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
