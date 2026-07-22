import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/presentation/widgets/store_list_widgets.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Cabeçalho ("Em Alta"). Fica separado da lista pra que ela abaixo continue
/// sendo um sliver de verdade.
class EmAltaSectionHeaderWidget extends StatelessWidget {
  const EmAltaSectionHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text("Em Alta", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText)),
    );
  }
}

/// Lista vertical (mesmo formato de card usado na busca filtrada por
/// categoria, via `StoreListItemWidget`) com as lojas de avaliação acima de
/// 4.5 — substitui o grid de 2 colunas usado antes para essa seção.
class EmAltaListSliverWidget extends StatelessWidget {
  final List<StoreDto> lojas;
  final String userRole;

  const EmAltaListSliverWidget({super.key, required this.lojas, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (lojas.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(child: Text("Nenhuma loja em alta no momento", style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText))),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StoreListItemWidget(store: lojas[index], userRole: userRole),
          );
        }, childCount: lojas.length),
      ),
    );
  }
}
