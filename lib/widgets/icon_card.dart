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
    // Pega a largura da tela para criar layout responsivo
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: ColorsPalette.branco,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        // Cor do efeito de splash (quando toca)
        splashColor: ColorsPalette.vermelhoVivido.withOpacity(0.3),
        child: SizedBox(
          width: screenWidth * 0.22,
          child: AspectRatio(
            // Define proporção do card
            // 0.5 significa que a altura será maior que a largura
            aspectRatio: 0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    // Tamanho proporcional à tela
                    size: screenWidth * 0.05,
                    color: ColorsPalette.vermelhoVivido,
                  ),
                  Text(
                    label,
                    maxLines: 2,
                    // Caso passe disso, corta "
                    overflow: TextOverflow.ellipsis,
                    // Controla escala do texto para acessibilidade
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
