import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/category_icons.dart';
import 'package:map_food/core/ui/utils/rating_format.dart';
import 'package:map_food/core/ui/widgets/photo_hero_card.dart';
import 'package:map_food/features/favorites/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

/// Carrossel "Perto de você" — lojas ordenadas por distância até o usuário.
class PertoDeVoceCarrosselWidget extends StatefulWidget {
  final List<StoreDto> items;

  const PertoDeVoceCarrosselWidget({super.key, required this.items});

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
          // Carrossel horizontal: o card interno tem foto + texto, então a
          // altura acompanha a escala. Com teto, porque um PageView que cresce
          // sem limite empurra o resto da home para fora da primeira dobra.
          height: escalaComTeto(context, 230.0, teto: 1.5),
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.items.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: DestaqueCardWidget(destaque: widget.items[index]),
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
                    borderRadius: BorderRadius.circular(AppRadius.pill),
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

/// Card "imersivo": a foto preenche o card inteiro, com nome/endereço e
/// nota/categorias sobrepostos num gradiente escuro — sem CTA em pill (o
/// card inteiro já é clicável, o botão "Ver loja" quebrava a estética
/// minimalista sem agregar nada que o tap no card não fizesse). Casca de
/// foto+gradiente vem de `PhotoHeroCard` — este widget só monta o conteúdo
/// (badges, texto) específico do card de destaque.
class DestaqueCardWidget extends StatelessWidget {
  final StoreDto destaque;

  // Bem mais aberto que o AppRadius.xl (24) padrão do resto do app — mesmo
  // valor do card do "Em Alta", de propósito, pra esses dois se destacarem
  // como os cards "hero" da home.
  static const double _radius = 32.0;

  const DestaqueCardWidget({super.key, required this.destaque});

  @override
  Widget build(BuildContext context) {
    final endereco = destaque.enderecoCompleto;
    final categorias = destaque.categoriaNomes.isNotEmpty
        ? destaque.categoriaNomes
        : (destaque.categoria.isNotEmpty ? [destaque.categoria] : <String>[]);

    return PhotoHeroCard(
      imageUrl: destaque.capaUrl,
      radius: _radius,
      onTap: () => Navigator.push(context, appPageRoute(builder: (context) => MoreInfoStorePage(store: destaque))),
      cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
      topRight: FavoriteButtonWidget(store: destaque, frosted: true),
      topLeft: FrostedBadge(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.star, color: ColorsPalette.ratingStar, size: 14),
            const SizedBox(width: 4),
            Text(
              formatRating(destaque.avaliacao),
              style: AppText.legenda(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (categorias.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(width: 1, height: 12, color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(width: 6),
              for (int i = 0; i < categorias.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Icon(iconeParaCategoria(categorias[i]), color: Colors.white, size: 14),
              ],
            ],
          ],
        ),
      ),
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            destaque.nome,
            style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18.0),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          if (endereco != null) ...[
            const SizedBox(height: 2.0),
            Text(
              endereco,
              style: AppText.legenda(context).copyWith(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
