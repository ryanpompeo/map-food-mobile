import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';

/// Chips horizontais para alternar entre as lojas do comerciante, com um chip
/// final para cadastrar outra. Aparece sobre "Minha operação" e "Perfil da
/// Loja".
///
/// Continua visível mesmo com uma loja só: o chip "Nova loja" é o caminho
/// mais curto para cadastrar a segunda, e escondê-lo por "limpeza visual"
/// tiraria a única entrada desse fluxo fora do perfil.
///
/// A faixa perdeu o fundo e a sombra próprios — ela vive dentro do fundo da
/// página, e uma barra sombreada logo abaixo do AppBar criava uma segunda
/// linha de cabeçalho que competia com o título da tela.
class StoreSwitcherBar extends StatelessWidget {
  final List<StoreDto> stores;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const StoreSwitcherBar({
    super.key,
    required this.stores,
    required this.selectedIndex,
    required this.onSelect,
  });

  /// Teto de escala da barra. Tira horizontal fixa no topo da área do
  /// comerciante: ela some da tela se crescer demais, e o conteúdo que ela
  /// seleciona é que precisa do espaço.
  static const double _tetoEscala = 1.5;

  @override
  Widget build(BuildContext context) {
    return MaxTextScale(
      max: _tetoEscala,
      child: SizedBox(
        height: escalaComTeto(context, 44.0, teto: _tetoEscala),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          itemCount: stores.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
          itemBuilder: (context, index) {
            if (index == stores.length) return const _NovaLojaChip();
            return _LojaChip(
              store: stores[index],
              selecionada: index == selectedIndex,
              onTap: () => onSelect(index),
            );
          },
        ),
      ),
    );
  }
}

class _LojaChip extends StatelessWidget {
  final StoreDto store;
  final bool selecionada;
  final VoidCallback onTap;

  const _LojaChip({
    required this.store,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final aberta = store.statusLoja == 'ATIVA';

    // Selecionado usa o par que inverte com o tema (o mesmo dos segmentos e
    // do card de status). O `Colors.black` fixo de antes desaparecia no
    // fundo escuro, e o chip ativo virava o menos visível da fileira.
    final fundo = selecionada ? colors.selectedSurface : colors.surfaceAlt;
    final conteudo = selecionada ? colors.onSelectedSurface : colors.textSecondary;

    return Semantics(
      button: true,
      selected: selecionada,
      label: '${store.nome}, ${aberta ? 'aberta' : 'fechada'}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.pill),
          child: AnimatedContainer(
            duration: Motion.fast,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fundo,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Verde é estado operacional (aberta), não cor de marca —
                    // vale igual nos dois temas, por isso vem de MfColor e
                    // não da escala de superfícies.
                    color: aberta ? MfColor.success : colors.textTertiary,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    store.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(context).copyWith(
                      color: conteudo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NovaLojaChip extends StatelessWidget {
  const _NovaLojaChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          appPageRoute(builder: (_) => const StoreRegisterPage()),
        ),
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.plus, size: AppIconSize.sm, color: MfColor.brand),
              const SizedBox(width: Spacing.xs + 2),
              Text(
                'Nova loja',
                style: AppText.caption(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: MfColor.brand,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
