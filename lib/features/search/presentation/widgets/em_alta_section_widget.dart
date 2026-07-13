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

class EmAltaSectionWidget extends StatefulWidget {
  final List<StoreDto> items;
  final String userRole;

  const EmAltaSectionWidget({super.key, required this.items, required this.userRole});

  @override
  State<EmAltaSectionWidget> createState() => _EmAltaSectionWidgetState();
}

class _EmAltaSectionWidgetState extends State<EmAltaSectionWidget> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Em Alta", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black)),
              const SizedBox(height: 2.0),
              Text("As lojas mais bem avaliadas", style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 280.0,
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
                    color: isActive ? ColorsPalette.redComponents : Colors.grey.shade300,
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
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreInfoStorePage(store: destaque))),
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto em tela cheia como fundo do card — isolada num
              // RepaintBoundary próprio pra não repintar a cada troca de
              // favorito ou scroll do carrossel ao lado.
              RepaintBoundary(
                child: Container(
                  color: Colors.grey.shade200,
                  child: resolveImagemUrl(destaque.capaUrl) != null
                      ? Image.network(
                          resolveImagemUrl(destaque.capaUrl)!, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.image, size: 48.0, color: Colors.grey.shade400),
                        )
                      : Icon(LucideIcons.image, size: 48.0, color: Colors.grey.shade400),
                ),
              ),
              Positioned(
                top: 12.0, right: 12.0,
                child: FavoriteButtonWidget(store: destaque, userRole: userRole),
              ),
              // Nome + categoria no canto inferior esquerdo, pills de fundo
              // branco sólido (mesmo formato cápsula dos filtros de categoria).
              Positioned(
                left: 12.0, right: 90.0, bottom: 12.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _InfoPill(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        destaque.nome,
                        style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black, fontSize: 16.0),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (destaque.categoria.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      _InfoPill(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                        child: Text(
                          destaque.categoria,
                          style: AppText.legenda(context).copyWith(color: ColorsPalette.black, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Avaliação fixa no canto inferior direito do card.
              Positioned(
                right: 12.0, bottom: 12.0,
                child: _InfoPill(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.star, color: Colors.amber.shade600, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        formatRating(destaque.avaliacao),
                        style: AppText.legenda(context).copyWith(color: ColorsPalette.black, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill de fundo branco sólido usada nas informações sobre a foto do card.
class _InfoPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _InfoPill({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ColorsPalette.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}
