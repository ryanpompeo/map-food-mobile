import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class IconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const IconCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: ColorsPalette.branco,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        splashColor: ColorsPalette.roxoVivo.withOpacity(0.45),

        child: SizedBox(
          width: screenWidth * 0.22, // tamanho do quadrado
          child: AspectRatio(
            aspectRatio: 0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: screenWidth * 0.05,
                    color: ColorsPalette.cinzaBg,
                  ),

                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: MediaQuery.textScaleFactorOf(
                      context,
                    ).clamp(1.0, 1.25),
                    style: TextStyle(
                      fontSize: screenWidth * 0.028,
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.cinzaBg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
