import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';

// O import da página de resultados de categoria
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

  // Mock: Categorias baseadas na sua imagem
  final List<Map<String, dynamic>> _categorias = [
    {'nome': 'Pizzas', 'icon': LucideIcons.pizza},
    {'nome': 'Lanches', 'icon': LucideIcons.sandwich},
    {'nome': 'Frango', 'icon': LucideIcons.drumstick},
    {'nome': 'Bebidas', 'icon': LucideIcons.cupSoda},
    {'nome': 'Carnes', 'icon': LucideIcons.beef},
    {'nome': 'Doces', 'icon': LucideIcons.cake},
  ];

  // Mock: Top 5 Comércios Em Alta
  final List<Map<String, dynamic>> _emAlta = [
    {
      'nome': 'Hamburgueria Central',
      'avaliacao': '4.9',
      'categoria': 'Lanches',
      'distancia': '1.2 km',
    },
    {
      'nome': 'Pizza do Zé',
      'avaliacao': '4.8',
      'categoria': 'Pizzas',
      'distancia': '2.5 km',
    },
    {
      'nome': 'Açaí da Praça',
      'avaliacao': '4.8',
      'categoria': 'Doces',
      'distancia': '0.8 km',
    },
    {
      'nome': 'Espetinho Brasa',
      'avaliacao': '4.7',
      'categoria': 'Carnes',
      'distancia': '3.1 km',
    },
    {
      'nome': 'Marmitaria Caseira',
      'avaliacao': '4.6',
      'categoria': 'Marmita',
      'distancia': '1.5 km',
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
                    const SizedBox(height: 120.0), // Respiro para a BottomBar
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
        color: ColorsPalette.whiteBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        style: AppText.corpo(
          context,
        ).copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.black),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Encontre comercios",
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
    // Mantive a sua implementação original intacta aqui
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
                  color: ColorsPalette.whiteBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: Colors.grey.shade300),
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
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 110.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categorias.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12.0),
            itemBuilder: (context, index) {
              final cat = _categorias[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryResultPage(categoryName: cat['nome']),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  width: 90.0,
                  decoration: BoxDecoration(
                    color: ColorsPalette.whiteBackground,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: Colors.grey.shade300, width: 1.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'],
                        size: AppIconSize.xl,
                        color: ColorsPalette.black,
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        cat['nome'],
                        style: AppText.legenda(
                          context,
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 13.0),
                      ),
                    ],
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
          physics:
              const NeverScrollableScrollPhysics(), // Scroll controlado pela CustomScrollView pai
          itemCount: _emAlta.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            final loja = _emAlta[index];
            return Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: ColorsPalette.whiteBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              child: Row(
                children: [
                  // Placeholder da Imagem da Loja
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
                        Text(
                          "${loja['categoria']} • ${loja['distancia']}",
                          style: AppText.legenda(context).copyWith(
                            color: ColorsPalette.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nota / Avaliação
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsPalette.black.withOpacity(0.05),
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
                            fontWeight: FontWeight.w800,
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
