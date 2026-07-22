import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

import '../controllers/favorites_manager.dart';

class ConsumerFavoritesPage extends StatefulWidget {
  const ConsumerFavoritesPage({super.key});

  @override
  State<ConsumerFavoritesPage> createState() => _ConsumerFavoritesPageState();
}

class _ConsumerFavoritesPageState extends State<ConsumerFavoritesPage> {
  @override
  void initState() {
    super.initState();

    FavoritesManager.instance.addListener(_refresh);
    FavoritesManager.instance.load();
  }

  @override
  void dispose() {
    FavoritesManager.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesManager.instance.favorites;
    final isLoading = FavoritesManager.instance.isLoading;

    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.mapColors.mainBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(PhosphorIconsRegular.caretLeft, color: ColorsPalette.redComponents),
        ),
        title: Text(
          "Favoritos",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText),
        ),
      ),
      body: isLoading && favorites.isEmpty
          ? const Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents))
          : favorites.isEmpty
          ? _EmptyFavoritesWidget()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: favorites.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final store = favorites[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      appPageRoute(
                        builder: (_) => MoreInfoStorePage(store: store),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.mapColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.mapColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          // Um tom abaixo do cardSurface do card que envolve esta
                          // miniatura (mesmo padrão de superfície aninhada dos lotes anteriores).
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: context.mapColors.mainBackground,
                          ),
                          child: resolveImagemUrl(store.capaUrl) != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    resolveImagemUrl(store.capaUrl)!,
                                    fit: BoxFit.cover,
                                    // Container é 80x80 — decodifica só nesse
                                    // tamanho físico em vez da resolução cheia.
                                    cacheWidth: (80.0 * MediaQuery.devicePixelRatioOf(context)).round(),
                                    cacheHeight: (80.0 * MediaQuery.devicePixelRatioOf(context)).round(),
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      PhosphorIconsRegular.image,
                                      color: context.mapColors.iconMuted,
                                    ),
                                  ),
                                )
                              : Icon(PhosphorIconsRegular.image, color: context.mapColors.iconMuted),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.corpo(context).copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: context.mapColors.primaryText,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                store.categoria.isNotEmpty
                                    ? store.categoria
                                    : "Sem categoria",
                                style: AppText.legenda(context),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.star,
                                    size: 14,
                                    color: Colors.amber.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${store.avaliacao ?? 'Novo'}",
                                    style: AppText.legenda(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            PhosphorIconsRegular.heart,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            try {
                              await FavoritesManager.instance.toggle(store);
                            } catch (_) {
                              if (!context.mounted) return;
                              AppToast.error(
                                context,
                                "Não foi possível remover dos favoritos. Tente novamente.",
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyFavoritesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsRegular.heart, color: Colors.red, size: 42),
            ),

            const SizedBox(height: 20),

            Text(
              "Nenhum favorito ainda",
              style: AppText.subtitulo(
                context,
              ).copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              "Os comércios que você favoritar aparecerão aqui.",
              textAlign: TextAlign.center,
              style: AppText.corpo(
                context,
              ).copyWith(color: context.mapColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
