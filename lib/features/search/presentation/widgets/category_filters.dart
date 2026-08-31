import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/utils/category_icons.dart';
import 'package:map_food/core/ui/utils/category_images.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

// Cartão ilustrado (arte ou ícone + rótulo embaixo) nas pills de filtro da
// Search Page. Fundo do círculo e ícone usam a cor de identidade da categoria
// (core/ui/theme/category_colors.dart) — mesma paleta usada nos chips de
// filtro da home. As categorias com arte 3D mostram a imagem de
// core/ui/utils/category_images.dart; as demais seguem com o ícone de
// core/ui/utils/category_icons.dart (compartilhado com os badges de categoria
// dos cards de loja).

/// Filtros de categoria em cartão (arte colorida + rótulo embaixo),
/// inspirado num grid de categorias de food app — mesma distribuição
/// horizontal de antes, só o formato do item mudou de pill pra cartão.
///
/// Só existem as categorias reais: "ver tudo" é o estado em que nenhuma está
/// marcada, alcançado tocando de novo na que está — não um item da tira. Um
/// cartão "Todos" competiria por espaço e por atenção com as categorias sendo,
/// na prática, a ausência de escolha; e a lista já mostra tudo quando nada
/// está marcado, então o estado sem recorte nunca precisa ser pedido, só
/// desfeito.
class CategoryFiltersWidget extends StatelessWidget {
  /// Nomes das categorias, na ordem em que aparecem.
  final List<String> filtros;

  /// Categoria marcada, ou `null` quando a listagem está sem recorte.
  final String? selecionada;

  /// Recebe o nome da categoria tocada, ou `null` quando o toque desmarcou a
  /// que estava ativa (volta à listagem completa).
  final ValueChanged<String?> onFilterChanged;

  const CategoryFiltersWidget({
    super.key,
    required this.filtros,
    required this.selecionada,
    required this.onFilterChanged,
  });

  /// Teto de escala dos cartões. Tira horizontal de altura fixa com rótulo de
  /// até duas linhas — o formato menos elástico do app. Acima de 1,5× o
  /// cartão passaria a ocupar mais que a lista de lojas que ele filtra.
  static const double _tetoEscala = 1.5;

  /// Lado do círculo da categoria. Fixo de propósito: é uma superfície
  /// colorida de identidade, não um bloco de texto.
  static const double _ladoCirculo = 72.0;

  /// Largura do item (círculo + rótulo de até duas linhas). Precisa de folga
  /// além do círculo para o nome não quebrar cedo demais.
  static const double _larguraItem = 78.0;

  @override
  Widget build(BuildContext context) {
    return MaxTextScale(
      max: _tetoEscala,
      child: SizedBox(
        // Só a metade de texto cresce — crescer o círculo junto com a fonte
        // só o faria disputar espaço com o rótulo logo abaixo.
        height: _ladoCirculo + escalaComTeto(context, 36.0, teto: _tetoEscala),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: filtros.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14.0),
          itemBuilder: (context, index) {
            final nome = filtros[index];
            final isSelected = nome == selecionada;

            return RepaintBoundary(
              child: _CartaoCategoria(
                nome: nome,
                isSelected: isSelected,
                lado: _ladoCirculo,
                largura: _larguraItem,
                // Tocar na categoria já marcada desfaz o recorte.
                onTap: () => onFilterChanged(isSelected ? null : nome),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Cartão de uma categoria: arte (ou ícone, quando ela ainda não tem arte)
/// sobre o círculo na cor de identidade, com o nome embaixo. Marcado, ganha
/// borda e rótulo na cor da categoria — que é também a deixa de que ele pode
/// ser desmarcado.
class _CartaoCategoria extends StatelessWidget {
  final String nome;
  final bool isSelected;
  final double lado;
  final double largura;
  final VoidCallback onTap;

  const _CartaoCategoria({
    required this.nome,
    required this.isSelected,
    required this.lado,
    required this.largura,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = corParaCategoria(nome);
    final arte = imagemParaCategoria(nome);

    return SemanticTapArea(
      // Este filtro já não dependia só de cor: a borda de 1,5px no estado
      // ativo é marcação estrutural, então aqui faltava apenas a semântica
      // (o nó de botão e o "selecionado").
      label: nome,
      selected: isSelected,
      onTap: onTap,
      child: SizedBox(
        width: largura,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: lado,
              height: lado,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: isSelected ? Border.all(color: cor, width: 1.5) : null,
              ),
              child: _Miolo(nome: nome, arte: arte, cor: cor),
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
                color: isSelected ? cor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Miolo extends StatelessWidget {
  final String nome;

  /// Caminho da arte, ou `null` na categoria que ainda não tem uma.
  final String? arte;

  final Color cor;

  const _Miolo({required this.nome, required this.arte, required this.cor});

  /// Lado do desenho dentro do círculo. Bem maior que o ícone que substitui
  /// porque a arte já traz margem no próprio canvas — em 31 o objeto sairia
  /// minúsculo.
  static const double _ladoArte = 62.0;

  /// Fallback compartilhado: categoria sem arte, e também arte que sumiu do
  /// bundle — nos dois casos o filtro continua legível com o ícone, nunca com
  /// o quadrado do "X" de imagem quebrada.
  Widget _icone() => Icon(iconeParaCategoria(nome), size: 31.0, color: cor);

  @override
  Widget build(BuildContext context) {
    final arte = this.arte;
    if (arte == null) return _icone();

    return Image.asset(
      arte,
      width: _ladoArte,
      height: _ladoArte,
      // Dobro do lado desenhado cobre telas de até 2× sem decodificar o PNG
      // de 1024px inteiro pra caber num círculo de 72.
      cacheWidth: (_ladoArte * 2).round(),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _icone(),
    );
  }
}
