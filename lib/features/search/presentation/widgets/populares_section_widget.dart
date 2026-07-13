import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/search/presentation/pages/view_most_popular.dart';
import 'package:map_food/features/search/presentation/utils/rating_format.dart';
import 'package:map_food/features/search/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

/// Cabeçalho ("Populares" + subtítulo + "ver todas"). Fica separado do grid
/// para que o grid abaixo possa ser um sliver de verdade, rolando junto com
/// o resto da página em vez de um carrossel horizontal isolado.
class PopularesSectionHeaderWidget extends StatelessWidget {
  final List<StoreDto> populares;
  final String userRole;

  const PopularesSectionHeaderWidget({super.key, required this.populares, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Populares", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black)),
                const SizedBox(height: 2.0),
                Text("Mais avaliadas pela comunidade", style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMostPopular(titulo: "Populares", items: populares, userRole: userRole))),
            child: Text("ver todas", style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Grid vertical de 2 colunas que rola junto com a página (sliver de verdade,
/// não um carrossel horizontal), para diferenciar visualmente de "Em Alta".
class PopularesGridSliverWidget extends StatelessWidget {
  final List<StoreDto> populares;
  final String userRole;

  const PopularesGridSliverWidget({super.key, required this.populares, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (populares.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(child: Text("Nenhuma loja popular no momento", style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText))),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          mainAxisExtent: 210.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => PopularStoreTileWidget(store: populares[index], userRole: userRole),
          childCount: populares.length,
        ),
      ),
    );
  }
}

class PopularStoreTileWidget extends StatelessWidget {
  final StoreDto store;
  final String userRole;

  const PopularStoreTileWidget({super.key, required this.store, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreInfoStorePage(store: store))),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120.0, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: resolveImagemUrl(store.capaUrl) != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.network(
                            resolveImagemUrl(store.capaUrl)!, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.image, size: 32.0, color: Colors.grey.shade300),
                          ),
                        )
                      : Icon(LucideIcons.image, size: 32.0, color: Colors.grey.shade300),
                ),
                Positioned(
                  top: 6.0, right: 6.0,
                  child: FavoriteButtonWidget(store: store, userRole: userRole, iconSize: 14.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                store.nome,
                style: AppText.corpo(context).copyWith(fontSize: 13.0, fontWeight: FontWeight.w800, color: ColorsPalette.black),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                children: [
                  Icon(LucideIcons.star, color: Colors.amber.shade500, size: 11),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      "${formatRating(store.avaliacao)} • ${store.categoria.isNotEmpty ? store.categoria : 'Geral'}",
                      style: AppText.legenda(context).copyWith(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
