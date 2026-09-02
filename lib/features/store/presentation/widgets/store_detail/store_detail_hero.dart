import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/favorites/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class StoreDetailHero extends StatelessWidget {
  final StoreDto store;

  static const double alturaExpandida = 280.0;

  static double larguraDaCapa(BuildContext context) => MediaQuery.sizeOf(context).width;

  const StoreDetailHero({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: alturaExpandida,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 60.0,
      leading: Center(
        child: _HeroCircleButton(
          icon: AppIcons.caretLeft,
          label: 'Voltar',
          onTap: () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Spacing.xs),
          child: FavoriteButtonWidget(store: store, iconSize: AppIconSize.md),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final alturaColapsada = kToolbarHeight + MediaQuery.paddingOf(context).top;
          final colapsado = constraints.maxHeight <= alturaColapsada + 8.0;

          return FlexibleSpaceBar(
            expandedTitleScale: 1.0,
            titlePadding: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 60.0,
              bottom: 14.0,
            ),
            title: AnimatedOpacity(
              duration: Motion.fast,
              opacity: colapsado ? 1.0 : 0.0,
              child: Text(
                store.nome,
                style: AppText.title(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            stretchModes: const [StretchMode.zoomBackground],
            background: _Capa(store: store, visivel: !colapsado),
          );
        },
      ),
    );
  }
}

class _Capa extends StatelessWidget {
  final StoreDto store;

  final bool visivel;

  const _Capa({required this.store, required this.visivel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppNetworkImage(
          path: store.capaUrl,
          semanticLabel: 'Foto de capa de ${store.nome}',
          displayWidth: StoreDetailHero.larguraDaCapa(context),
          fallback: const _CapaVazia(),
        ),

        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xB3000000)],
            ),
          ),
        ),

        Positioned(
          left: Spacing.lg,
          right: Spacing.lg,
          bottom: Spacing.lg,
          child: AnimatedOpacity(
            duration: Motion.fast,
            opacity: visivel ? 1.0 : 0.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.nome,
                  style: AppText.h1(context).copyWith(color: ColorsPalette.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (store.enderecoCompleto != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: [
                      const Icon(
                        AppIcons.mapPin,
                        size: AppIconSize.sm,
                        color: ColorsPalette.white,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          store.enderecoCompleto!,
                          style: AppText.secondary(context).copyWith(
                            color: ColorsPalette.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CapaVazia extends StatelessWidget {
  const _CapaVazia();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MfColor.ink, MfColor.brand],
        ),
      ),
      child: Center(
        child: Icon(
          AppIcons.storefront,
          size: 72.0,
          color: ColorsPalette.white.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SemanticTapArea(
      label: label,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: context.mapColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorsPalette.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: AppIconSize.md,
              color: context.mapColors.brandContent,
            ),
          ),
        ),
      ),
    );
  }
}
