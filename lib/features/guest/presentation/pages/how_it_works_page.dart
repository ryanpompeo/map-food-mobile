import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,

      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                pinned: true,
                backgroundColor: ColorsPalette.whiteBackground,
                foregroundColor: ColorsPalette.whiteBackground,
                surfaceTintColor: ColorsPalette.whiteBackground,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorsPalette.whiteBackground,
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
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Como o MapFood funciona?",
                        style: AppText.titulo(context).copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 28.0,
                          color: ColorsPalette.black,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Descubra os melhores comércios e vendedores de rua da sua cidade em 3 passos simples.",
                        style: AppText.corpo(
                          context,
                        ).copyWith(color: ColorsPalette.greyText, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildStepCard(
                        context,
                        stepNumber: "1",
                        title: "Explore o Mapa",
                        description:
                            "Navegue pelo mapa interativo e encontre vendedores de rua próximos a você em tempo real.",
                        icon: LucideIcons.mapPin,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildStepCard(
                        context,
                        stepNumber: "2",
                        title: "Escolha sua Categoria",
                        description:
                            "Use os filtros inteligentes para encontrar exatamente o que deseja: de espetinhos e lanches até doces e açaí.",
                        icon: LucideIcons.slidersHorizontal,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildStepCard(
                        context,
                        stepNumber: "3",
                        title: "Siga a Rota",
                        description:
                            "Toque em 'Visualizar no mapa' para traçar a rota exata até o comércio escolhido e aproveite.",
                        icon: LucideIcons.navigation,
                      ),

                      const SizedBox(height: 140.0),
                    ],
                  ),
                ),
              ),
            ],
          ),

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
                      color: ColorsPalette.redComponents.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    elevation: 0,
                  ),
                  child: Center(
                    child: Text(
                      "Começar a explorar",
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
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: ColorsPalette.redComponents.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: ColorsPalette.redComponents,
                size: AppIconSize.lg,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.subtitulo(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: ColorsPalette.black,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  description,
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.greyText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
