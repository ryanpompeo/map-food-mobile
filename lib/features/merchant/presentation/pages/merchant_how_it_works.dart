import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

class MerchantHowItWorksPage extends StatelessWidget {
  const MerchantHowItWorksPage({super.key});

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
                    decoration: const BoxDecoration(
                      color: ColorsPalette.whiteBackground,
                      shape: BoxShape.circle,
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
                        "Gerencie seu comércio",
                        style: AppText.titulo(context).copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 28.0,
                          color: ColorsPalette.black,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Veja como dominar o MapFood e atrair mais clientes para o seu ponto de venda",
                        style: AppText.corpo(
                          context,
                        ).copyWith(color: ColorsPalette.greyText, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildStepCard(
                        context,
                        title: "Ative sua Loja",
                        description:
                            "Interaja com o botão 'Loja Aberta' para aparecer no mapa e ser encontrado pelos clientes na hora",
                        icon: PhosphorIconsRegular.storefront,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildStepCard(
                        context,
                        title: "Fique em Ronda",
                        description:
                            "Enquanto sua loja estiver aberta, sua posição é atualizada automaticamente no mapa conforme você se movimenta",
                        icon: PhosphorIconsRegular.navigationArrow,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildStepCard(
                        context,
                        title: "Gerencie Avaliações",
                        description:
                            "Acompanhe o feedback dos seus clientes e mantenha sua reputação sempre em alta",
                        icon: PhosphorIconsRegular.star,
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Entendi, vamos lá!",
                    style: AppText.botao(context).copyWith(color: Colors.white),
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsPalette.redComponents.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ColorsPalette.redComponents,
              size: AppIconSize.md,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.subtitulo(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
