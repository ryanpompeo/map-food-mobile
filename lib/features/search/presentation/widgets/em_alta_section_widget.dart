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

class EmAltaSectionWidget extends StatelessWidget {
  final List<StoreDto> items;
  final String userRole;

  const EmAltaSectionWidget({super.key, required this.items, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Em Alta", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black)),
                    const SizedBox(height: 2.0),
                    Text("As lojas mais bem avaliadas", style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMostPopular())),
                child: Text("ver todas", style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 280.0,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16.0),
            itemBuilder: (context, index) => SizedBox(width: 280.0, child: DestaqueCardWidget(destaque: items[index], userRole: userRole)),
          ),
        ),
      ],
    );
  }
}

class DestaqueCardWidget extends StatelessWidget {
  final StoreDto destaque;
  final String userRole;

  const DestaqueCardWidget({super.key, required this.destaque, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreInfoStorePage(store: destaque))),
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 160.0, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16.0)),
                  child: resolveImagemUrl(destaque.capaUrl) != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            resolveImagemUrl(destaque.capaUrl)!, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.image, size: 48.0, color: Colors.grey.shade300),
                          ),
                        )
                      : Icon(LucideIcons.image, size: 48.0, color: Colors.grey.shade300),
                ),
                Positioned(
                  top: 12.0, right: 12.0,
                  child: FavoriteButtonWidget(store: destaque, userRole: userRole),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                destaque.nome,
                style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black, fontSize: 18.0),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Icon(LucideIcons.star, color: Colors.amber.shade500, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "${formatRating(destaque.avaliacao)} • ${destaque.categoria.isNotEmpty ? destaque.categoria : 'Geral'}",
                    style: AppText.legenda(context).copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
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
