import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';

/// Cabeçalho das seções de navegação da busca ("Perto de você", "Em Alta").
///
/// Existe porque os dois títulos eram um `Text` solto em arquivos diferentes,
/// com o mesmo `copyWith(fontWeight: w800, color: primaryText)` copiado nos
/// dois — e o ícone teria virado uma terceira cópia da mesma linha.
///
/// O ícone é **decorativo**: `ExcludeSemantics` o tira da árvore de
/// acessibilidade, porque o título ao lado já diz o que a seção é. Sem isso o
/// leitor de tela anunciaria um nó de imagem sem rótulo antes de cada seção.
class HomeSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const HomeSectionTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              // Acompanha a fonte: um ícone de tamanho fixo ao lado de um
              // título que cresce descola do texto e passa a ler como sujeira.
              size: escalaIcone(context, AppIconSize.md),
              color: ColorsPalette.redComponents,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              title,
              style: AppText.subtitulo(context).copyWith(
                fontWeight: FontWeight.w800,
                color: context.mapColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
