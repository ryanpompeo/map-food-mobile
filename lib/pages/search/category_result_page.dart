import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class CategoryResultPage extends StatelessWidget {
  final String categoryName;

  const CategoryResultPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.chevronLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        // Mock de 10 lojas dinâmicas sendo geradas
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return _buildStoreCard(context, index);
        },
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        // Redireciona para a página da loja ao clicar (Futura implementação)
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: ColorsPalette.whiteBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                LucideIcons.store,
                color: Colors.grey.shade400,
                size: AppIconSize.xl,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Comércio Mockado ${index + 1}",
                    style: AppText.corpo(context).copyWith(
                      fontWeight: FontWeight.w800,
                      color: ColorsPalette.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Especialidade em $categoryName",
                    style: AppText.legenda(
                      context,
                    ).copyWith(color: ColorsPalette.greyText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.star,
                        color: Colors.amber,
                        size: 14.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        "4.${9 - (index % 5)}", // Gera notas 4.9, 4.8, etc
                        style: AppText.legenda(context).copyWith(
                          fontWeight: FontWeight.w800,
                          color: ColorsPalette.black,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Icon(
                        LucideIcons.mapPin,
                        color: ColorsPalette.greyText,
                        size: 14.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        "${1 + (index * 0.5)} km", // Gera distâncias crescentes
                        style: AppText.legenda(context).copyWith(
                          color: ColorsPalette.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
