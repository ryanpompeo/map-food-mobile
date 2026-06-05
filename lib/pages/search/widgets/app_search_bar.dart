import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFilterTap;

  const AppSearchBar({super.key, required this.controller, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            child: Icon(
              LucideIcons.search,
              color: Colors.grey.shade400,
              size: AppIconSize.md, 
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppText.corpo(
                context,
              ).copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Lanches, doces, bebidas...",
                hintStyle: AppText.corpo(
                  context,
                ).copyWith(color: Colors.grey.shade400),
                border: InputBorder.none,
                isDense: true,
            
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),
          Container(
            height: 32.0,
            width: 1.0,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: onFilterTap,
              icon: Icon(
                LucideIcons.slidersHorizontal,
                color: ColorsPalette.blackDetails,
                size: AppIconSize.md,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
