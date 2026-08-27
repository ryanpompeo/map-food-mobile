import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';

/// Seleção de categorias da loja — os quatro estados de uma vez.
///
/// Nasceu de uma duplicação real: cadastro de loja e edição de loja tinham
/// cada um a sua cópia dos chips, com raio, peso de fonte e tratamento de
/// erro diferentes; a correção de "categorias não aparecem" precisou ser
/// escrita duas vezes, em dois arquivos, com dois textos distintos.
///
/// A falha aqui nunca pode ser silenciosa: escolher categoria é obrigatório
/// para concluir o cadastro, então uma seção vazia deixa a pessoa presa
/// olhando um botão que não funciona, sem nada para tocar.
class CategoryPicker extends StatelessWidget {
  final List<CategoriaModel> categorias;

  /// IDs escolhidos. Em modo leitura, é o que se mostra — e só isso.
  final List<int> selecionadas;

  final bool carregando;

  /// Mensagem de falha da busca. `null` quando a chamada deu certo (inclusive
  /// quando devolveu lista vazia, que é outro estado).
  final String? erro;

  final VoidCallback onRetry;

  /// `null` deixa o seletor em somente-leitura: mostra as categorias já
  /// escolhidas como selos, sem oferecer toque.
  final ValueChanged<CategoriaModel>? onToggle;

  /// Disparado ao tocar numa categoria não escolhida com o limite já cheio.
  final VoidCallback? onLimiteExcedido;

  final int maxSelecao;

  const CategoryPicker({
    super.key,
    required this.categorias,
    required this.selecionadas,
    required this.carregando,
    required this.erro,
    required this.onRetry,
    required this.onToggle,
    this.onLimiteExcedido,
    this.maxSelecao = 3,
  });

  bool get _editavel => onToggle != null;

  @override
  Widget build(BuildContext context) {
    if (carregando) return const _ChipsSkeleton();

    if (erro != null) {
      return _AvisoCategorias(
        icone: AppIcons.wifiSlash,
        mensagem: erro!,
        onRetry: onRetry,
      );
    }

    if (categorias.isEmpty) {
      // 200 com lista vazia é diferente de falha: não adianta oferecer
      // "tentar novamente" para algo que respondeu.
      return const _AvisoCategorias(
        icone: AppIcons.info,
        mensagem: 'Nenhuma categoria cadastrada no momento. '
            'Fale com o suporte para liberar seu cadastro.',
        onRetry: null,
      );
    }

    final visiveis = _editavel
        ? categorias
        : categorias.where((c) => selecionadas.contains(c.id)).toList();

    if (visiveis.isEmpty) {
      return Text(
        'Nenhuma categoria selecionada.',
        style: AppText.secondary(context),
      );
    }

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm + 2,
      children: [
        for (final cat in visiveis)
          _CategoriaChip(
            categoria: cat,
            selecionada: selecionadas.contains(cat.id),
            onTap: _editavel
                ? () {
                    final jaEscolhida = selecionadas.contains(cat.id);
                    if (!jaEscolhida && selecionadas.length >= maxSelecao) {
                      onLimiteExcedido?.call();
                      return;
                    }
                    onToggle!(cat);
                  }
                : null,
          ),
      ],
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final CategoriaModel categoria;
  final bool selecionada;
  final VoidCallback? onTap;

  const _CategoriaChip({
    required this.categoria,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final cor = corParaCategoria(categoria.nome);

    return SemanticTapArea(
      label: categoria.nome,
      selected: selecionada,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          // 10 de padding vertical dá ~40px de alvo com a fonte de caption —
          // abaixo disso o chip fica difícil de acertar com o polegar.
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: selecionada ? cor : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: Text(
          categoria.nome,
          style: AppText.caption(context).copyWith(
            fontSize: 13,
            // Branco sobre a cor de identidade da categoria vale nos dois
            // temas: a cor do chip selecionado não muda com o brightness.
            color: selecionada ? Colors.white : colors.textSecondary,
            fontWeight: selecionada ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Placeholders com a forma dos chips durante o carregamento — um spinner
/// solto no meio da seção não diz o que está vindo, e a seção "pula" de
/// altura quando os chips chegam.
class _ChipsSkeleton extends StatelessWidget {
  const _ChipsSkeleton();

  static const _larguras = [92.0, 76.0, 110.0, 84.0];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm + 2,
      children: [
        for (final largura in _larguras)
          Container(
            width: largura,
            // Esqueleto dos chips que vão ocupar este espaço: acompanha a
            // mesma escala deles, senão a lista salta ao terminar de carregar.
            height: escalaComTeto(context, 38),
            decoration: BoxDecoration(
              color: context.mapColors.surfaceAlt,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
          ),
      ],
    );
  }
}

class _AvisoCategorias extends StatelessWidget {
  final IconData icone;
  final String mensagem;
  final VoidCallback? onRetry;

  const _AvisoCategorias({
    required this.icone,
    required this.mensagem,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icone, size: AppIconSize.md, color: colors.textSecondary),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  mensagem,
                  style: AppText.secondary(context).copyWith(height: 1.4),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: Spacing.md),
            AppButton(
              label: 'Tentar novamente',
              icon: AppIcons.arrowClockwise,
              onPressed: onRetry,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.sm,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
