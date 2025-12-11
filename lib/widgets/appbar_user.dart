import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class AppbarUser extends StatelessWidget implements PreferredSizeWidget {
  const AppbarUser({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Icon(
            LucideIcons.mapPin,
            size: 28,
            color: ColorsPalette.roxoVivo.withOpacity(0.95),
          ),
          const SizedBox(width: 8),
          Text(
            "Limeira - SP",
            style: TextStyle(
              color: ColorsPalette.cinzaBg.withOpacity(0.75),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.settings, size: 22),
            color: Colors.black.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
