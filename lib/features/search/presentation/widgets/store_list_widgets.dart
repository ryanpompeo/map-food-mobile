import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/search/presentation/utils/rating_format.dart';
import 'package:map_food/features/search/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/search/presentation/widgets/store_card_badges.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class VerticalDestaqueSliverWidget extends StatelessWidget {
  final List<StoreDto> items;
  final String userRole;

  const VerticalDestaqueSliverWidget({super.key, required this.items, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(child: Text("Nenhum comércio encontrado para esta categoria", style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText))),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StoreListItemWidget(store: items[index], userRole: userRole),
          );
        }, childCount: items.length),
      ),
    );
  }
}

class StoreListItemWidget extends StatelessWidget {
  final StoreDto store;
  final String userRole;

  const StoreListItemWidget({super.key, required this.store, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, appPageRoute(builder: (context) => MoreInfoStorePage(store: store))),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 76.0, height: 76.0,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: resolveImagemUrl(store.capaUrl) != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Image.network(
                        resolveImagemUrl(store.capaUrl)!, fit: BoxFit.cover,
                        // Decodifica no tamanho físico real do container (76dp)
                        // em vez da resolução cheia da foto — sem isso, cada
                        // item da lista decodifica a imagem inteira só pra
                        // exibir num quadrado de 76px, pesando no scroll.
                        cacheWidth: (76.0 * MediaQuery.devicePixelRatioOf(context)).round(),
                        cacheHeight: (76.0 * MediaQuery.devicePixelRatioOf(context)).round(),
                        errorBuilder: (context, error, stackTrace) => Icon(PhosphorIconsRegular.image, size: 24.0, color: Colors.grey.shade400),
                      ),
                    )
                  : Icon(PhosphorIconsRegular.image, size: 24.0, color: Colors.grey.shade400),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.nome, style: AppText.corpo(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800, color: ColorsPalette.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingBadgePill(rating: formatRating(store.avaliacao)),
                      const SizedBox(width: 6.0),
                      Flexible(child: InfoChip(label: store.categoria.isNotEmpty ? store.categoria : 'Geral')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FavoriteButtonWidget(store: store, userRole: userRole, iconSize: 18),
          ],
        ),
      ),
    );
  }
}
