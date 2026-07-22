import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/rating_format.dart';
import 'package:map_food/features/favorites/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/store/presentation/widgets/store_card_badges.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

/// Carrossel "Perto de você" — lojas ordenadas por distância até o usuário.
class PertoDeVoceCarrosselWidget extends StatefulWidget {
  final List<StoreDto> items;
  final String userRole;

  const PertoDeVoceCarrosselWidget({super.key, required this.items, required this.userRole});

  @override
  State<PertoDeVoceCarrosselWidget> createState() => _PertoDeVoceCarrosselWidgetState();
}

class _PertoDeVoceCarrosselWidgetState extends State<PertoDeVoceCarrosselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text("Perto de você", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText)),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 340.0,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.items.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: DestaqueCardWidget(destaque: widget.items[index], userRole: widget.userRole),
            ),
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.items.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  width: isActive ? 20.0 : 6.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: isActive ? ColorsPalette.redComponents : context.mapColors.border,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                );
              }),
            ),
          ),
        ],
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
    // Categorias da loja fazem as vezes dos chips de atributo do anexo
    // ("3 quartos", "2 vagas", "145 m²") — não há equivalente literal pra
    // uma loja, então usamos até 3 categorias como os atributos do card.
    final atributos = destaque.categoriaNomes.isNotEmpty
        ? destaque.categoriaNomes.take(3).toList()
        : (destaque.categoria.isNotEmpty ? [destaque.categoria] : <String>[]);
    final endereco = destaque.enderecoCompleto;

    return InkWell(
      onTap: () => Navigator.push(context, appPageRoute(builder: (context) => MoreInfoStorePage(store: destaque))),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: context.mapColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto com cantos arredondados nos 4 lados, com respiro pro
            // fundo branco do card — só o favorito (vidro fosco) flutua
            // por cima, igual ao anexo de referência.
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Stack(
                children: [
                  // RepaintBoundary próprio pra a foto não repintar a cada
                  // troca de favorito ou scroll do carrossel ao lado. Precisa
                  // ser o filho não-posicionado do Stack (com width/height
                  // explícitos) — senão, dentro da Column com
                  // crossAxisAlignment.start, o Stack colapsa pra 0x0 e a
                  // foto some, deixando o card em branco.
                  RepaintBoundary(
                    child: Container(
                      height: 180.0, width: double.infinity,
                      // Um tom abaixo do cardSurface do card que envolve a
                      // foto, senão o placeholder fica invisível contra o
                      // próprio card antes da imagem carregar.
                      color: context.mapColors.mainBackground,
                      child: resolveImagemUrl(destaque.capaUrl) != null
                          ? Image.network(
                              resolveImagemUrl(destaque.capaUrl)!, fit: BoxFit.cover,
                              // Card ocupa quase a largura da tela — decodifica só
                              // nesse tamanho físico em vez da resolução cheia da
                              // foto, que pode ter vários MB.
                              cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
                              errorBuilder: (context, error, stackTrace) => Icon(PhosphorIconsRegular.image, size: 48.0, color: context.mapColors.iconMuted),
                            )
                          : Icon(PhosphorIconsRegular.image, size: 48.0, color: context.mapColors.iconMuted),
                    ),
                  ),
                  Positioned(
                    top: 10.0, right: 10.0,
                    child: FavoriteButtonWidget(store: destaque, userRole: userRole, frosted: true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 14.0, 2.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome + avaliação na mesma linha, no lugar de
                  // título/preço do anexo.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          destaque.nome,
                          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText, fontSize: 19.0),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Icon(PhosphorIconsRegular.star, color: Colors.amber.shade500, size: 16),
                          const SizedBox(width: 3),
                          Text(
                            formatRating(destaque.avaliacao),
                            style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText, fontSize: 19.0),
                          ),
                          if (destaque.totalAvaliacoes > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              "(${destaque.totalAvaliacoes})",
                              // Sem override de cor: legenda() já resolve pra secondaryText.
                              style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (endereco != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      endereco,
                      // Sem override de cor: legenda() já resolve pra secondaryText.
                      style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (atributos.isNotEmpty) ...[
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < atributos.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8.0),
                          Flexible(child: AttributeChip(label: atributos[i])),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
