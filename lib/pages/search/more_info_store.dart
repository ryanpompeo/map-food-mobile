import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/search/widgets/floating_map_buttom.dart';
import 'package:map_food/models/store/store_dto.dart';

class MoreInfoStorePage extends StatelessWidget {
  final StoreDto store;

  const MoreInfoStorePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            floating: false,
            pinned: true,
            surfaceTintColor: ColorsPalette.whiteBackground,
            backgroundColor: ColorsPalette.whiteBackground,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsPalette.whiteBackground.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    color: ColorsPalette.redComponents,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorsPalette.whiteBackground,
                    ),
                    child: store.imagens != null && store.imagens!.isNotEmpty
                        ? ClipRRect(
                            child: Image.network(
                              store.imagens![0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      LucideIcons.image,
                                      size: 64.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              LucideIcons.image,
                              size: 64.0,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.nome,
                    style: AppText.subtitulo(context).copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 24.0,
                      color: ColorsPalette.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    "Sobre o local",
                    style: AppText.subtitulo(context).copyWith(
                      fontWeight: FontWeight.w900,
                      color: ColorsPalette.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    store.descricao ??
                        "O vendedor não adicionou uma descrição detalhada para este comércio. Aqui você encontra os melhores produtos da categoria preparados com muito cuidado.",
                    style: AppText.corpo(
                      context,
                    ).copyWith(color: ColorsPalette.greyText, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Galeria de fotos",
                        style: AppText.subtitulo(context).copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColorsPalette.black,
                        ),
                      ),
                      Text(
                        "${store.imagens?.length ?? 0} fotos",
                        style: AppText.legenda(context).copyWith(
                          color: ColorsPalette.greyText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 140.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemCount: store.imagens?.length ?? 0,
                      separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 140.0,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              store.imagens![index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      LucideIcons.image,
                                      color: Colors.grey,
                                      size: 32.0,
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40.0),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.xl,
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                      ),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          boxShadow: [
                            BoxShadow(
                              color: ColorsPalette.redComponents.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsPalette.redComponents,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            elevation: 0,
                          ),
                          child: Center(
                            child: Text(
                              "Visualizar no mapa",
                              style: AppText.botao(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
