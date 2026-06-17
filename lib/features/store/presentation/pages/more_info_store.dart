import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/search/widgets/floating_map_buttom.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class MoreInfoStorePage extends StatelessWidget {
  final StoreDto store;

  const MoreInfoStorePage({super.key, required this.store});

  // Mock estático isolado dentro da classe
  final List<Map<String, dynamic>> _avaliacoesMock = const [
    {
      'nome': 'Carlos Silva',
      'estrelas': 5,
      'comentario':
          'Sensacional! O pedido superou as expectativas e o atendimento foi rápido.',
      'data': 'Ontem',
    },
    {
      'nome': 'Ana Beatriz',
      'estrelas': 4,
      'comentario':
          'Muito bom, a qualidade é excelente. Único ponto é que a fila estava um pouco grande no local.',
      'data': 'Há 2 dias',
    },
    {
      'nome': 'Felipe Martins',
      'estrelas': 5,
      'comentario':
          'Recomendo de olhos fechados. Preço justo e muito saboroso.',
      'data': 'Há 1 semana',
    },
  ];

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
                    decoration: const BoxDecoration(
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

                  const SizedBox(height: AppSpacing.xl),
                  const Divider(thickness: 0.2),
                  const SizedBox(height: AppSpacing.lg),

                  // Injeção da Seção de Avaliações
                  _buildAvaliacoesSection(context),

                  const SizedBox(height: 40.0),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: Container(
                        height: 56,
                        width: double.infinity,
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

  Widget _buildAvaliacoesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Avaliações",
                  style: AppText.titulo(
                    context,
                  ).copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  "O que os clientes dizem",
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.greyText),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    store.avaliacao?.toString() ?? "4.8",
                    style: AppText.subtitulo(context).copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Mapeando a lista diretamente na Column garante alta performance
        // e previne bugs de SingleChildScrollView alinhados.
        ..._avaliacoesMock.map((review) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade100,
                          child: Text(
                            review['nome'][0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review['nome'],
                          style: AppText.corpo(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      review['data'],
                      style: AppText.legenda(
                        context,
                      ).copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['estrelas']
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  review['comentario'],
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
