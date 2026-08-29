import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

/// Cabeçalho das seções da tela de detalhe da loja.
///
/// Existe porque a tela tinha quatro cabeçalhos montados à mão, cada um com um
/// nível tipográfico diferente (h1 para "Avaliações", h2 para "Sobre o local",
/// h1 de novo dentro de um card) — e **nenhum** com o título em `Expanded`. Era
/// dessa falta que vinha o estouro da linha: o título ocupava a largura que
/// quisesse e empurrava o resto da linha para fora da tela.
///
/// Aqui o título é sempre `Expanded` e sempre `h2`. Um cabeçalho de seção não
/// pode competir com o nome da loja no topo da tela, que é o h1.
class SectionHeader extends StatelessWidget {
  final String title;

  /// Linha de apoio ("12 avaliações", "Carregando..."). Fica sob o título.
  final String? subtitle;

  /// Conteúdo à direita — um contador, um selo de nota. Recebe o espaço que
  /// sobra do título, nunca o contrário.
  final Widget? trailing;

  /// `null` deixa o cabeçalho estático. Preenchido, desenha o caret que gira
  /// e o cabeçalho inteiro vira o alvo de toque.
  final bool? expanded;

  final VoidCallback? onToggle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.expanded,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final conteudo = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.h2(context)),
              if (subtitle != null) ...[
                const SizedBox(height: 2.0),
                Text(subtitle!, style: AppText.secondary(context)),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: Spacing.md),
          trailing!,
        ],
        if (expanded != null) ...[
          const SizedBox(width: Spacing.sm),
          AnimatedRotation(
            duration: Motion.medium,
            turns: expanded! ? 0.5 : 0.0,
            child: Icon(
              AppIcons.caretDown,
              size: escalaIcone(context, AppIconSize.md),
              color: colors.textTertiary,
            ),
          ),
        ],
      ],
    );

    if (onToggle == null) return conteudo;

    return SemanticTapArea(
      label: title,
      hint: expanded == true ? 'Recolhe a seção' : 'Expande a seção',
      selected: expanded,
      onTap: onToggle,
      child: conteudo,
    );
  }
}
