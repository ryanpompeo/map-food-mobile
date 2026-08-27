import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/utils/category_icons.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

// Cartão ilustrado (ícone + rótulo embaixo) nas pills de filtro da Search
// Page. Fundo do quadrado e ícone usam a cor de identidade da categoria
// (core/ui/theme/category_colors.dart) — mesma paleta usada nos chips de
// filtro da home. Ícones vêm de core/ui/utils/category_icons.dart
// (compartilhado com os badges de categoria dos cards de loja).

/// Filtros de categoria em cartão (ícone colorido + rótulo embaixo),
/// inspirado num grid de categorias de food app — mesma distribuição
/// horizontal de antes, só o formato do item mudou de pill pra cartão.
class CategoryFiltersWidget extends StatelessWidget {
  final List<String> filtros;
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;

  const CategoryFiltersWidget({
    super.key, required this.filtros, required this.selectedIndex, required this.onFilterChanged,
  });

  /// Teto de escala dos cartões. Tira horizontal de altura fixa com rótulo de
  /// até duas linhas — o formato menos elástico do app. Acima de 1,5× o
  /// cartão passaria a ocupar mais que a lista de lojas que ele filtra.
  static const double _tetoEscala = 1.5;

  @override
  Widget build(BuildContext context) {
    return MaxTextScale(
      max: _tetoEscala,
      child: SizedBox(
        // Só a metade de texto cresce. O quadrado do ícone fica em 60 de
        // propósito: ele é uma superfície colorida de tamanho fixo (a
        // identidade da categoria), não um bloco de texto — crescer com a
        // fonte só o faria disputar espaço com o rótulo logo abaixo.
        height: 60.0 + escalaComTeto(context, 36.0, teto: _tetoEscala),
        child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filtros.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14.0),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final nome = filtros[index];
          final icone = iconeParaCategoria(nome);
          final corCategoria = corParaCategoria(nome);
          return RepaintBoundary(
            // Este filtro já não dependia só de cor: a borda de 2,5px no
            // estado ativo é marcação estrutural, então aqui faltava apenas a
            // semântica (o nó de botão e o "selecionado").
            child: SemanticTapArea(
              label: nome,
              selected: isSelected,
              onTap: () => onFilterChanged(index),
              child: SizedBox(
                width: 68.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60.0,
                      height: 60.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: corCategoria.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: isSelected
                            ? Border.all(color: corCategoria, width: 2.5)
                            : null,
                      ),
                      child: Icon(icone, size: 26.0, color: corCategoria),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      nome,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.legenda(context).copyWith(
                        fontSize: 11.0,
                        height: 1.15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? corCategoria : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          },
        ),
      ),
    );
  }
}
