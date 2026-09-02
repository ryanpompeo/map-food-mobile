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

class CategoryPicker extends StatelessWidget {
  final List<CategoriaModel> categorias;

  final List<int> selecionadas;

  final bool carregando;

  final String? erro;

  final VoidCallback onRetry;

  final ValueChanged<CategoriaModel>? onToggle;

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
            color: selecionada ? Colors.white : colors.textSecondary,
            fontWeight: selecionada ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

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
