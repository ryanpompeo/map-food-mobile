import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
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
import 'package:map_food/features/store/presentation/widgets/home_section_title.dart';

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
        const HomeSectionTitle(
          icon: AppIcons.navigationArrow,
          title: 'Perto de você',
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
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

class DestaqueCardWidget extends StatelessWidget {
  final StoreDto destaque;

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
      onTap: () => abrirDetalheDaLoja(context, destaque),
      displayWidth: MediaQuery.sizeOf(context).width,
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
