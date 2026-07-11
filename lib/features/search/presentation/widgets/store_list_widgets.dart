import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/search/presentation/utils/rating_format.dart';
import 'package:map_food/features/search/presentation/widgets/favorite_button_widget.dart';
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreInfoStorePage(store: store))),
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 72.0, height: 72.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: resolveImagemUrl(store.capaUrl) != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        resolveImagemUrl(store.capaUrl)!, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.image, size: 24.0, color: Colors.grey.shade400),
                      ),
                    )
                  : Icon(LucideIcons.image, size: 24.0, color: Colors.grey.shade400),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.nome, style: AppText.corpo(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800, color: ColorsPalette.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(LucideIcons.star, color: Colors.amber.shade500, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "${formatRating(store.avaliacao)} • ${store.categoria.isNotEmpty ? store.categoria : 'Geral'}",
                        style: AppText.legenda(context).copyWith(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                ],
              ),
            ),
            FavoriteButtonWidget(store: store, userRole: userRole, iconSize: 24),
          ],
        ),
      ),
    );
  }
}
