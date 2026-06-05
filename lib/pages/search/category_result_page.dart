import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class CategoryResultPage extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;

  const CategoryResultPage({
    super.key,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<CategoryResultPage> createState() => _CategoryResultPageState();
}

class _CategoryResultPageState extends State<CategoryResultPage> {
  final List<String> _filtros = [
    'Todos',
    'Abertos',
    'Melhor Avaliados',
    'Mais Próximos',
  ];
  int _filtroSelecionadoIndex = 0;

  void _showLoginWallBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.heart,
                  color: ColorsPalette.redComponents,
                  size: AppIconSize.xl,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "Salve seus comércios favoritos!",
                textAlign: TextAlign.center,
                style: AppText.subtitulo(context).copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColorsPalette.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Crie uma conta gratuita em segundos para salvar, avaliar e denunciar comércios na sua cidade.",
                textAlign: TextAlign.center,
                style: AppText.corpo(
                  context,
                ).copyWith(color: ColorsPalette.greyText, height: 1.3),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/accountType');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Criar Conta Gratuita",
                    style: AppText.botao(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    "Já tenho uma conta",
                    style: AppText.legenda(context).copyWith(
                      color: ColorsPalette.blackDetails,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.black,
        surfaceTintColor: ColorsPalette.whiteBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: widget.categoryColor,
            size: AppIconSize.lg,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.slidersHorizontal,
              color: ColorsPalette.blackDetails,
              size: AppIconSize.md,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _filtros.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = index == _filtroSelecionadoIndex;
                return ChoiceChip(
                  label: Text(
                    _filtros[index],
                    style: AppText.legenda(context).copyWith(
                      color: isSelected ? Colors.white : ColorsPalette.greyText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: widget.categoryColor,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    side: BorderSide(
                      color: isSelected
                          ? widget.categoryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      _filtroSelecionadoIndex = index;
                    });
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Text.rich(
              TextSpan(
                text: "12 ",
                style: AppText.subtitulo(context).copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColorsPalette.black,
                ),
                children: [
                  TextSpan(
                    text: "Resultados encontrados",
                    style: AppText.corpo(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorsPalette.greyText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: 12,
              separatorBuilder: (_, __) => Divider(
                color: Colors.grey.shade200,
                height: 1.0,
                thickness: 1.0,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              itemBuilder: (context, index) {
                final isAberto = index % 3 != 0;
                return _buildFlatStoreItem(context, index, isAberto);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatStoreItem(BuildContext context, int index, bool isAberto) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 88.0,
                  height: 88.0,
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    LucideIcons.image,
                    color: widget.categoryColor.withValues(alpha: 0.4),
                    size: AppIconSize.xl,
                  ),
                ),

                Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: GestureDetector(
                    onTap: () => _showLoginWallBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.heart,
                        size: 16.0,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nome do Comércio ${index + 1}",
                    style: AppText.corpo(context).copyWith(
                      fontWeight: FontWeight.w900,
                      color: ColorsPalette.black,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: isAberto
                              ? Colors.green.shade600.withValues(alpha: 0.1)
                              : ColorsPalette.redComponents.withValues(
                                  alpha: 0.1,
                                ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.0,
                              height: 6.0,
                              decoration: BoxDecoration(
                                color: isAberto
                                    ? Colors.green.shade700
                                    : ColorsPalette.redComponents,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              isAberto ? "ABERTO" : "FECHADO",
                              style: AppText.legenda(context).copyWith(
                                color: isAberto
                                    ? Colors.green.shade700
                                    : ColorsPalette.redComponents,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          "Centro • ${1 + (index * 0.5)} km",
                          style: AppText.legenda(context).copyWith(
                            color: ColorsPalette.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                        "4.${9 - (index % 5)}",
                        style: AppText.legenda(context).copyWith(
                          fontWeight: FontWeight.w800,
                          color: ColorsPalette.black,
                        ),
                      ),
                      Text(
                        " (120)",
                        style: AppText.legenda(context).copyWith(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
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
