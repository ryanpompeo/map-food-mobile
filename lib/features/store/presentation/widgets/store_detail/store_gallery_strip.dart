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

/// Tira horizontal com as fotos da loja.
///
/// A página desenhava isto inline mesmo quando não havia foto nenhuma: o
/// cabeçalho anunciava "0 fotos" e, abaixo, 140px de nada. Aqui, galeria vazia
/// simplesmente não é uma seção.
class StoreGalleryStrip extends StatelessWidget {
  final StoreDto store;

  /// Lado do tile. Quadrado de 140 é o tamanho em que três fotos se anunciam
  /// na largura de um celular, com a terceira cortada — o corte é o que
  /// convida a arrastar.
  static const double _lado = 140.0;

  const StoreGalleryStrip({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.galeria.isEmpty) return const SizedBox.shrink();

    // Resolvida uma vez: é a lista que o visualizador em tela cheia recebe, e
    // o índice do tile tocado precisa apontar para a posição certa dentro dela
    // (URLs inválidas mudam a numeração).
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
        // O tile tem 140dp — sem `displayWidth`, cada foto seria decodificada
        // no tamanho original.
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
