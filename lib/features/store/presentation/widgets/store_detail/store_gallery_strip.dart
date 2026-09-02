import 'package:flutter/material.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/section_header.dart';
import 'package:map_food/features/store/presentation/widgets/store_gallery_viewer.dart';

class StoreGalleryStrip extends StatelessWidget {
  final StoreDto store;

  static const double _lado = 140.0;

  const StoreGalleryStrip({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.galeria.isEmpty) return const SizedBox.shrink();

    final resolvidas = store.galeria.map(resolveImagemUrl).whereType<String>().toList();
    final total = store.galeria.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Galeria de fotos',
          trailing: Text(
            '$total ${total == 1 ? 'foto' : 'fotos'}',
            style: AppText.caption(context),
          ),
        ),
        const SizedBox(height: Spacing.base),
        SizedBox(
          height: _lado,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: total,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.md),
            itemBuilder: (context, index) {
              final url = resolveImagemUrl(store.galeria[index]);
              final indiceResolvido = url == null ? -1 : resolvidas.indexOf(url);

              return SemanticTapArea(
                label: 'Foto ${index + 1} de $total da galeria',
                hint: 'Abre a foto em tela cheia',
                onTap: url == null || resolvidas.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          appPageRoute(
                            builder: (_) => StoreGalleryViewer(
                              imagens: resolvidas,
                              initialIndex: indiceResolvido < 0 ? 0 : indiceResolvido,
                            ),
                          ),
                        ),
                child: _Tile(url: url, lado: _lado),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String? url;
  final double lado;

  const _Tile({required this.url, required this.lado});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final vazio = Center(
      child: Icon(AppIcons.image, color: colors.textTertiary, size: AppIconSize.xl),
    );

    return Container(
      width: lado,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: AppNetworkImage(
          path: url,
          width: lado,
          height: lado,
          displayWidth: lado,
          fallback: vazio,
        ),
      ),
    );
  }
}
