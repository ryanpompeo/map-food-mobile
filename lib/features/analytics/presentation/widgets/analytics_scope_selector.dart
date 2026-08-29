import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Alterna o painel entre **dados gerais** (todas as lojas somadas) e **uma
/// loja específica**.
///
/// Fica no AppBar, e não no corpo, porque não é um filtro entre outros: ele
/// governa o que *todos* os números abaixo significam. Um controle solto no
/// meio da lista de cards se perderia na rolagem, e daí o total de acessos
/// passaria a ser lido como "de tudo" quando é de uma loja só.
///
/// Com uma loja só cadastrada, o seletor não aparece — não há o que alternar,
/// e um menu de uma opção só é ruído.
class AnalyticsScopeSelector extends StatelessWidget {
  final List<StoreDto> lojas;

  /// `null` = dados gerais.
  final int? lojaSelecionadaId;

  final ValueChanged<int?> onSelecionar;

  const AnalyticsScopeSelector({
    super.key,
    required this.lojas,
    required this.lojaSelecionadaId,
    required this.onSelecionar,
  });

  static const _rotuloGeral = 'Dados gerais';

  /// "Dados gerais" viaja pelo menu como este id falso, e não como `null`.
  ///
  /// `PopupMenuButton` trata `null` como **cancelamento**: o `showMenu` resolve
  /// com o valor escolhido, e ali um `null` é indistinguível de "fechou o menu
  /// sem escolher" — o framework chama `onCanceled` e nunca `onSelected`
  /// (`material/popup_menu.dart`, no `.then` do `showMenu`). Com `int?` como
  /// tipo do menu, voltar para os dados gerais simplesmente não acontecia:
  /// o painel continuava preso na última loja.
  ///
  /// Id de loja é sempre positivo (chave do banco), então `-1` nunca colide.
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
      // `initialValue` deixa o item ativo marcado ao abrir o menu — sem isso
      // a única pista do escopo atual seria o rótulo do botão, que fica
      // escondido atrás do próprio menu enquanto ele está aberto.
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
        // Sem `onTap`: quem abre o menu é o PopupMenuButton em volta. Este nó
        // existe para o leitor de tela anunciar o estado atual junto do botão.
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
          // Marcação por forma, não só por peso da fonte: a diferença entre
          // w500 e w700 não se percebe sem os dois itens lado a lado.
          if (selecionado) ...[
            const SizedBox(width: Spacing.sm),
            Icon(AppIcons.check, size: AppIconSize.sm, color: colors.brandContent),
          ],
        ],
      ),
    );
  }
}
