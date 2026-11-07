import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';

String rotuloEstrelas(int estrelas) => estrelas == 1 ? '1 estrela' : '$estrelas estrelas';

class FiltroDeEstrelas extends StatelessWidget {
  final int? selecionado;

  final ValueChanged<int?> onSelecionar;

  const FiltroDeEstrelas({
    super.key,
    required this.selecionado,
    required this.onSelecionar,
  });

  static const double _tetoEscala = 1.5;

  @override
  Widget build(BuildContext context) {
    return MaxTextScale(
      max: _tetoEscala,
      child: SizedBox(
        height: escalaComTeto(context, 38.0, teto: _tetoEscala),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            AppChoiceChip(
              label: 'Todas',
              selected: selecionado == null,
              onTap: () => onSelecionar(null),
            ),
            for (var estrelas = 5; estrelas >= 1; estrelas--) ...[
              const SizedBox(width: Spacing.sm),
              AppChoiceChip(
                label: '$estrelas',
                icon: AppIcons.starFill,
                iconColor: MfColor.rating,
                selected: selecionado == estrelas,
                onTap: () => onSelecionar(estrelas),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
