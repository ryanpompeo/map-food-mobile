import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,

      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                pinned: true,
                backgroundColor: context.mapColors.mainBackground,
                foregroundColor: context.mapColors.mainBackground,
                surfaceTintColor: context.mapColors.mainBackground,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      color: context.mapColors.mainBackground,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        PhosphorIconsRegular.caretLeft,
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
                          color: context.mapColors.primaryText,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Descubra os melhores comércios e vendedores de rua da sua cidade em 3 passos simples",
                        style: AppText.corpo(
                          context,
                        ).copyWith(color: context.mapColors.secondaryText, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Card 1: ilustração de marca (vermelho) — cores
                      // literais de propósito, inclusive colorText (que
                      // reaproveita ColorsPalette.whiteBackground como um
                      // branco-gelo de TEXTO sobre o card, não como fundo de
                      // página — não confundir com context.mapColors.mainBackground).
                      _buildStepCard(
                        context,
                        stepNumber: "1",
                        colorCard: ColorsPalette.redDegrade3,
                        colorIcon: ColorsPalette.white,
                        colorBorder: ColorsPalette.redDegrade3,
                        colorText: ColorsPalette.whiteBackground,
                        colorStep: ColorsPalette.white.withValues(alpha: 0.8),
                        title: "Explore o Mapa",
                        description:
                            "Navegue pelo mapa interativo e encontre vendedores de rua próximos a você em tempo real",
                        icon: PhosphorIconsRegular.mapPin,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Card 2: card neutro (não é ilustração de marca) —
                      // este sim usa os tokens de superfície/texto.
                      _buildStepCard(
                        colorCard: context.mapColors.cardSurface,
                        colorIcon: ColorsPalette.redComponents,
                        colorText: context.mapColors.primaryText,
                        colorBorder: ColorsPalette.transparent,
                        colorStep: context.mapColors.secondaryText,
                        context,
                        stepNumber: "2",
                        title: "Escolha sua Categoria",
                        description:
                            "Use os filtros inteligentes para encontrar exatamente o que deseja: de espetinhos e lanches até doces e açaí",
                        icon: PhosphorIconsRegular.slidersHorizontal,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildStepCard(
                        colorCard: ColorsPalette.blackComponents,
                        colorIcon: ColorsPalette.white,
                        colorText: ColorsPalette.white,
                        colorBorder: ColorsPalette.transparent,
                        colorStep: ColorsPalette.greyDetails,
                        context,
                        stepNumber: "3",
                        title: "Siga a Rota",
                        description:
                            "Toque em 'Visualizar no mapa' para traçar a rota exata até o comércio escolhido e aproveite",
                        icon: PhosphorIconsRegular.navigationArrow,
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
                  borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    elevation: 0,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Começar a explorar",
                          style: AppText.botao(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          PhosphorIconsRegular.caretRight,
                          color: Colors.white,
                          size: AppIconSize.md,
                        ),
                      ],
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
    required Color colorCard,
    required Color colorIcon,
    required Color colorText,
    required Color colorStep,
    required Color colorBorder,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colorBorder),
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
            height: 100,

            child: Center(
              child: Icon(icon, color: colorIcon, size: AppIconSize.xl),
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
                    color: colorText,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  description,
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: colorStep, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
