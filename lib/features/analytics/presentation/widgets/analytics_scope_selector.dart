import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class AnalyticsScopeSelector extends StatelessWidget {
  final List<StoreDto> lojas;

  final int? lojaSelecionadaId;

  final ValueChanged<int?> onSelecionar;

  const AnalyticsScopeSelector({
    super.key,
    required this.lojas,
    required this.lojaSelecionadaId,
    required this.onSelecionar,
  });

  static const _rotuloGeral = 'Dados gerais';

  static const _idGeral = -1;

  String get _rotuloAtual {
    if (lojaSelecionadaId == null) return _rotuloGeral;
    for (final loja in lojas) {
      if (loja.id == lojaSelecionadaId) return loja.nome;
    }
    return _rotuloGeral;
  }

  @override
  Widget build(BuildContext context) {
    if (lojas.length < 2) return const SizedBox.shrink();

    final colors = context.mapColors;

    return PopupMenuButton<int>(
      initialValue: lojaSelecionadaId ?? _idGeral,
      onSelected: (valor) => onSelecionar(valor == _idGeral ? null : valor),
      tooltip: 'Escolher o que os dados cobrem',
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      itemBuilder: (context) => [
        _item(context, valor: _idGeral, rotulo: _rotuloGeral, icone: AppIcons.chartLineUp),
        const PopupMenuDivider(),
        for (final loja in lojas)
          _item(context, valor: loja.id, rotulo: loja.nome, icone: AppIcons.storefront),
      ],
      child: SemanticTapArea(
        label: 'Escopo dos dados: $_rotuloAtual',
        hint: 'Alterna entre dados gerais e uma loja',
        onTap: null,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 190.0),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _rotuloAtual,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(AppIcons.caretDown, size: 14.0, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<int> _item(
    BuildContext context, {
    required int valor,
    required String rotulo,
    required IconData icone,
  }) {
    final colors = context.mapColors;
    final selecionado = valor == (lojaSelecionadaId ?? _idGeral);

    return PopupMenuItem<int>(
      value: valor,
      child: Row(
        children: [
          Icon(
            icone,
            size: AppIconSize.sm,
            color: selecionado ? colors.brandContent : colors.textSecondary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(context).copyWith(
                fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
                color: selecionado ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
          if (selecionado) ...[
            const SizedBox(width: Spacing.sm),
            Icon(AppIcons.check, size: AppIconSize.sm, color: colors.brandContent),
          ],
        ],
      ),
    );
  }
}
