import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/presentation/widgets/home_section_title.dart';
import 'package:map_food/features/store/presentation/widgets/store_list_widgets.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Cabeçalho ("Em Alta"). Fica separado da lista pra que ela abaixo continue
/// sendo um sliver de verdade.
class EmAltaSectionHeaderWidget extends StatelessWidget {
  const EmAltaSectionHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Chama para o que a seção é (as lojas mais bem avaliadas), não para o que
    // ela faz — daí a fogueira, e não um gráfico de linha.
    return const HomeSectionTitle(icon: AppIcons.fire, title: 'Em Alta');
  }
}

/// Lista vertical (mesmo formato de card usado na busca filtrada por
/// categoria, via `StoreListItemWidget`) com as lojas de avaliação acima de
/// 4.5.
class EmAltaListSliverWidget extends StatelessWidget {
  final List<StoreDto> lojas;

  const EmAltaListSliverWidget({super.key, required this.lojas});

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
          final isLast = index == lojas.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
            child: Column(
              children: [
                StoreListItemWidget(store: lojas[index]),
                if (!isLast) ...[
                  const SizedBox(height: AppSpacing.md),
                  Divider(height: 1, thickness: 1, color: context.mapColors.border),
                ],
              ],
            ),
          );
        }, childCount: lojas.length),
      ),
    );
  }
}
