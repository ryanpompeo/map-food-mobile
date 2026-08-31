import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/app_refresh.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/category_icons.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
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
    unawaited(FavoritesManager.instance.load());
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
    final errorMessage = FavoritesManager.instance.errorMessage;

    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.mapColors.mainBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            AppIcons.caretLeft,
            color: ColorsPalette.redComponents,
          ),
        ),
        title: Text(
          "Favoritos",
          style: AppText.subtitulo(context).copyWith(
            fontWeight: FontWeight.w800,
            color: context.mapColors.primaryText,
          ),
        ),
      ),
      // Primeira carga sem nada na tela é a única situação sem "puxe para
      // atualizar": não há o que puxar, e o spinner já é a resposta. Nos
      // demais estados — inclusive erro e lista vazia — o gesto existe, porque
      // é exatamente ali que se quer tentar de novo.
      body: isLoading && favorites.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: ColorsPalette.redComponents,
              ),
            )
          : AppRefresh(
              onRefresh: FavoritesManager.instance.load,
              child: _buildConteudo(context, favorites, errorMessage),
            ),
    );
  }

  Widget _buildConteudo(
    BuildContext context,
    List<StoreDto> favorites,
    String? errorMessage,
  ) {
    // Erro tem precedência sobre o vazio: sem isso, uma falha de rede
    // aparecia como "nenhum favorito ainda" e o usuário concluía que
    // tinha perdido o que salvou.
    if (errorMessage != null && favorites.isEmpty) {
      return AppRefresh.centralizado(
        EmptyState(
          icon: AppIcons.wifiSlash,
          title: 'Não foi possível carregar',
          description: errorMessage,
          actionLabel: 'Tentar novamente',
          onAction: () => FavoritesManager.instance.load(),
          tone: EmptyStateTone.error,
        ),
      );
    }

    if (favorites.isEmpty) {
      return AppRefresh.centralizado(_EmptyFavoritesWidget());
    }

    return ListView.separated(
      physics: AppRefresh.physics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: favorites.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final store = favorites[index];
        final categoriaPrincipal = store.categoriaNomes.isNotEmpty
            ? store.categoriaNomes.first
            : (store.categoria.isNotEmpty ? store.categoria : null);
        final corCategoria = categoriaPrincipal != null
            ? corParaCategoria(categoriaPrincipal)
            : null;

        return InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => abrirDetalheDaLoja(context, store),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.mapColors.cardSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.mapColors.border),
              boxShadow: AppElevation.soft,
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      // Um tom abaixo do cardSurface do card que envolve esta
                      // miniatura (mesmo padrão de superfície aninhada dos lotes anteriores).
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        color: context.mapColors.mainBackground,
                      ),
                      // Decorativa (sem `semanticLabel`): o nome da
                      // loja já aparece como texto no card.
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: AppNetworkImage(
                          path: store.capaUrl,
                          displayWidth: 80.0,
                        ),
                      ),
                    ),
                    // Selo de canto com a cor de identidade da categoria
                    // principal — mesma paleta usada nos filtros.
                    if (categoriaPrincipal != null)
                      Positioned(
                        bottom: -4.0,
                        right: -4.0,
                        child: Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            color: corCategoria,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.mapColors.cardSurface,
                              width: 2.0,
                            ),
                          ),
                          child: Icon(
                            iconeParaCategoria(categoriaPrincipal),
                            size: 12.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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
                            AppIcons.star,
                            size: 14,
                            color: ColorsPalette.ratingStar,
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
                  icon: const Icon(AppIcons.heart, color: Colors.red),
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
    );
  }
}

class _EmptyFavoritesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmptyState(
        icon: AppIcons.heart,
        title: "Nenhum favorito ainda",
        description: "Os comércios que você favoritar aparecerão aqui.",
      ),
    );
  }
}
