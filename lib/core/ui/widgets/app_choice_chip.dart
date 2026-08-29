import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

/// Chip de escolha em pílula — filtro de categoria, período, distância.
///
/// ## Por que existe
///
/// O app tinha três cópias deste chip (home, filtros e perfil), e as três
/// sinalizavam seleção **apenas por cor de fundo**. Isso reprova no WCAG 1.4.1
/// (*Use of Color*): quem não distingue o par de cores não tem como saber qual
/// filtro está ativo. É o mesmo problema que o iOS ataca com *Differentiate
/// Without Color* e *Button Shapes*.
///
/// A correção é o **✓ que aparece ao selecionar**: um segundo canal, de forma,
/// que não depende de enxergar cor nenhuma. O fundo continua lá — ele não é o
/// problema, ser o *único* sinal é que era.
///
/// O peso da fonte, que algumas dessas cópias usavam como reforço, não conta:
/// a diferença entre 600 e 700 num texto de 13px não é percebida sem os dois
/// chips lado a lado para comparar.
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;

  /// `null` desabilita — o chip vira somente-leitura e deixa de ser anunciado
  /// como botão.
  final VoidCallback? onTap;

  /// Fundo do estado selecionado. Padrão: `selectedSurface` do tema, que já
  /// inverte entre claro e escuro. Passe outra cor apenas quando o chip
  /// carregar identidade própria (ex: a cor da categoria no modal de filtros).
  final Color? selectedSurface;

  /// Conteúdo sobre [selectedSurface]. Passe junto com ele — é o par que
  /// precisa de contraste, e só quem escolhe o fundo sabe o que fica legível.
  final Color? onSelectedSurface;

  /// Fundo do estado não selecionado. Padrão: `surface`. O modal de filtros
  /// usa `background` porque a folha dele já é `surface` — sem isso o chip
  /// inativo desaparece contra o próprio fundo.
  final Color? unselectedSurface;

  /// Ícone do estado **não selecionado** — o ✓ toma o lugar dele ao selecionar.
  /// Serve para chips cujo rótulo sozinho não diz do que se trata (o "5" de um
  /// filtro por nota, que só faz sentido ao lado de uma estrela).
  final IconData? icon;

  /// Cor de [icon]. Padrão: a mesma do rótulo. Passe outra quando o ícone
  /// carregar significado próprio (o amarelo da estrela de nota).
  final Color? iconColor;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedSurface,
    this.onSelectedSurface,
    this.unselectedSurface,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final fundoAtivo = selectedSurface ?? colors.selectedSurface;
    final conteudoAtivo = onSelectedSurface ?? colors.onSelectedSurface;
    final fundoInativo = unselectedSurface ?? colors.surface;

    final conteudo = selected ? conteudoAtivo : colors.textSecondary;

    return SemanticTapArea(
      label: label,
      // Faz o leitor de tela anunciar "selecionado" — o terceiro canal, além
      // da cor e do ✓.
      selected: selected,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: 9.0),
        decoration: BoxDecoration(
          color: selected ? fundoAtivo : fundoInativo,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: selected ? fundoAtivo : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              // Decorativo para o leitor de tela: ele já ouviu "selecionado"
              // pelo nó de semântica, e um "check" solto seria ruído.
              ExcludeSemantics(
                child: Icon(
                  AppIcons.check,
                  size: escalaIcone(context, 14.0),
                  color: conteudoAtivo,
                ),
              ),
              const SizedBox(width: 6.0),
            ] else if (icon != null) ...[
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: escalaIcone(context, 14.0),
                  color: iconColor ?? conteudo,
                ),
              ),
              const SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: AppText.caption(context).copyWith(
                fontWeight: FontWeight.w700,
                color: conteudo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
