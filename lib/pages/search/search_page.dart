import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';

import 'package:map_food/pages/search/category_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _buscasRecentes = [
    'Hambúrguer artesanal',
    'Açaí',
    'Pizza',
    'Marmita',
  ];

  final List<Map<String, dynamic>> _categorias = [
    {
      'nome': 'Lanches & Hot Dogs',
      'icon': LucideIcons.sandwich,
      'color': Colors.deepOrange,
    },
    {'nome': 'Espetinhos', 'icon': LucideIcons.flame, 'color': Colors.red},
    {
      'nome': 'Pastel & Salgados',
      'icon': LucideIcons.croissant,
      'color': Colors.amber.shade700,
    },
    {
      'nome': 'Doces & Churros',
      'icon': LucideIcons.cakeSlice,
      'color': Colors.pink.shade400,
    },
    {
      'nome': 'Gelados & Açaí',
      'icon': LucideIcons.popsicle,
      'color': Colors.purple.shade700,
    },
    {
      'nome': 'Milho & Pamonha',
      'icon': LucideIcons.wheat,
      'color': Colors.yellow.shade800,
    },
    {'nome': 'Bebidas', 'icon': LucideIcons.cupSoda, 'color': Colors.blue},
    {
      'nome': 'Refeições',
      'icon': LucideIcons.soup,
      'color': Colors.green.shade700,
    },
  ];

  final List<Map<String, dynamic>> _emAlta = [
    {
      'nome': 'Hamburgueria Central',
      'avaliacao': '4.9',
      'categoria': 'Lanches',
      'distancia': '1.2 km',
      'isAberto': true,
    },
    {
      'nome': 'Pizza do Zé',
      'avaliacao': '4.8',
      'categoria': 'Pizzas',
      'distancia': '2.5 km',
      'isAberto': false,
    },
    {
      'nome': 'Açaí da Praça',
      'avaliacao': '4.8',
      'categoria': 'Doces',
      'distancia': '0.8 km',
      'isAberto': true,
    },
    {
      'nome': 'Espetinho Brasa',
      'avaliacao': '4.7',
      'categoria': 'Carnes',
      'distancia': '3.1 km',
      'isAberto': true,
    },
    {
      'nome': 'Marmitaria Caseira',
      'avaliacao': '4.6',
      'categoria': 'Marmita',
      'distancia': '1.5 km',
      'isAberto': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: AppSpacing.xl),

                    if (_buscasRecentes.isNotEmpty) ...[
                      _buildHistorico(context),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    _buildCategorias(context),
                    const SizedBox(height: AppSpacing.xl),

                    _buildEmAlta(context),
                    const SizedBox(height: 120.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52.0,
      decoration: BoxDecoration(
        color: ColorsPalette.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: ColorsPalette.black.withValues(alpha: 0.07),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: AppText.corpo(
          context,
        ).copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.black),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Busque por comércios...",
          hintStyle: AppText.corpo(
            context,
          ).copyWith(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(
            LucideIcons.search,
            color: ColorsPalette.redComponents,
            size: AppIconSize.md,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: Colors.grey.shade400,
                    size: AppIconSize.md,
                  ),
                  onPressed: () => setState(() => _searchController.clear()),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildHistorico(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pesquisas recentes",
              style: AppText.subtitulo(context).copyWith(
                fontWeight: FontWeight.w800,
                color: ColorsPalette.black,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _buscasRecentes.clear()),
              child: Text(
                "Limpar",
                style: AppText.legenda(context).copyWith(
                  color: ColorsPalette.blackDetails,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _buscasRecentes.map((termo) {
            return InkWell(
              onTap: () => setState(() => _searchController.text = termo),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: ColorsPalette.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsPalette.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.history,
                      size: AppIconSize.sm,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      termo,
                      style: AppText.legenda(context).copyWith(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorias(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categorias",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 150.0,
          child: ListView.separated(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 24.0,
              left: 4.0,
              right: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categorias.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12.0),
            itemBuilder: (context, index) {
              final cat = _categorias[index];
              final Color catColor = cat['color'] ?? Colors.grey;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryResultPage(
                        categoryName: cat['nome'],
                        categoryColor: catColor,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  width: 100.0,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: catColor.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsPalette.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: ColorsPalette.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: catColor.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            cat['icon'],
                            size: AppIconSize.lg,
                            color: catColor,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          cat['nome'],
                          textAlign: TextAlign.center,
                          style: AppText.legenda(context).copyWith(
                            color: ColorsPalette.blackDetails,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.0,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmAlta(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              LucideIcons.trendingUp,
              color: ColorsPalette.redComponents,
              size: AppIconSize.lg,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              "Em Alta",
              style: AppText.subtitulo(context).copyWith(
                fontWeight: FontWeight.w900,
                color: ColorsPalette.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _emAlta.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            final loja = _emAlta[index];
            final bool isAberto = loja['isAberto'] ?? false;

            return Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: ColorsPalette.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: ColorsPalette.black.withValues(alpha: 0.07),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64.0,
                    height: 64.0,
                    decoration: BoxDecoration(
                      color: ColorsPalette.whiteBackground,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      LucideIcons.image,
                      color: Colors.grey.shade400,
                      size: AppIconSize.lg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loja['nome'],
                          style: AppText.corpo(context).copyWith(
                            fontWeight: FontWeight.w800,
                            color: ColorsPalette.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: isAberto
                                    ? Colors.green.shade600.withValues(
                                        alpha: 0.1,
                                      )
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
                                "${loja['categoria']} • ${loja['distancia']}",
                                style: AppText.legenda(context).copyWith(
                                  color: ColorsPalette.greyText,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsPalette.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.star,
                          color: Colors.amber,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          loja['avaliacao'],
                          style: AppText.legenda(context).copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColorsPalette.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
