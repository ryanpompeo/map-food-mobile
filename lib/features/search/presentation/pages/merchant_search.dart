import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class MerchantSearch extends StatefulWidget {
  const MerchantSearch({super.key});

  @override
  State<MerchantSearch> createState() => _MerchantSearchPage();
}

class _MerchantSearchPage extends State<MerchantSearch> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final List<String> _filtros = [
    'Todos',
    'Lanches e Hot Dogs',
    'Espetinhos',
    'Pastel e Salgados',
    'Doces e Sobremesas',
    'Bebidas',
    'Gelatos e Açaí',
    'Milho e Pamonha',
    'Pipoca',
    'Produtos Artesanais',
    'Food Trucks',
    'Outros',
  ];

  final Map<String, int> _categoryMapping = {
    'Lanches e Hot Dogs': 1,
    'Espetinhos': 6,
    'Pastel e Salgados': 2,
    'Doces e Sobremesas': 3,
    'Bebidas': 4,
    'Gelatos e Açaí': 5,
    'Milho e Pamonha': 7,
    'Pipoca': 8,
    'Produtos Artesanais': 9,
    'Food Trucks': 10,
    'Outros': 11,
  };

  final List<StoreDto> _mockDatabase = [
    StoreDto(
      id: 3,
      statusLoja: 'ATIVA',
      nome: 'Salgado do Eduardo',
      descricao:
          'A melhor seleção de sorvetes da região, com ingredientes frescos e selecionados para proporcionar uma experiência única para nossos clientes',
      categoria: 'Pastel e Salgados',
      imagens: [
        'assets/images/e-s-capa.jpeg',
        'assets/images/e-s-2.jpeg',
        'assets/images/e-s-1.jpeg',
      ],
      avaliacao: 5,
    ),
    StoreDto(
      id: 1,
      statusLoja: 'ATIVA',
      nome: 'Brotesco Bebida',
      descricao:
          'A melhor seleção de bebidas geladas para matar sua sede! De sucos naturais a refrigerantes, temos tudo para refrescar seu dia',
      categoria: 'Bebidas',
      imagens: [
        'https://images.unsplash.com/photo-1625740822008-e45abf4e01d5?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8cmVmcmlnZXJhbnRlfGVufDB8fDB8fHww',

        'https://images.unsplash.com/photo-1543253687-c931c8e01820?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHJlZnJpZ2VyYW50ZXxlbnwwfHwwfHx8MA%3D%3D',

        'https://images.unsplash.com/photo-1546695259-ad30ff3fd643?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzF8fHJlZnJpZ2VyYW50ZXxlbnwwfHwwfHx8MA%3D%3D',

        'https://images.unsplash.com/photo-1738569594383-d7d6516eb42f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Njh8fHJlZnJpZ2VyYW50ZXxlbnwwfHwwfHx8MA%3D%3D',
      ],
      avaliacao: 4.5,
    ),
    StoreDto(
      id: 2,
      statusLoja: 'ATIVA',
      nome: 'Guira Picolé',
      descricao:
          'A melhor seleção de sorvetes da região, com ingredientes frescos e selecionados para proporcionar uma experiência única para nossos clientes',
      categoria: 'Gelatos e Açaí',
      imagens: [
        'https://images.unsplash.com/photo-1599849338190-0ed15f300519?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHBpY29sJUMzJUE5fGVufDB8fDB8fHww',

        'https://images.unsplash.com/photo-1699400203948-b309ddf47443?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBpY29sJUMzJUE5fGVufDB8fDB8fHww',

        'https://images.unsplash.com/photo-1572269579647-d941424e3b82?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzF8fHBpY29sJUMzJUE5fGVufDB8fDB8fHww',
      ],
      avaliacao: 4.7,
    ),
  ];

  List<StoreDto> _destaques = [];
  List<StoreDto> _populares = [];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  void _loadStores({int? categoryId, String? query}) {
    List<StoreDto> results = _mockDatabase;

    if (query != null && query.isNotEmpty) {
      results = results
          .where(
            (store) => store.nome.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } else if (categoryId != null) {
      final categoryName = _categoryMapping.entries
          .firstWhere(
            (entry) => entry.value == categoryId,
            orElse: () => const MapEntry('', 0),
          )
          .key;

      if (categoryName.isNotEmpty) {
        results = results
            .where((store) => store.categoria == categoryName)
            .toList();
      }
    }

    setState(() {
      _destaques = results;
      _populares = results.take(1).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _filtros[_selectedFilterIndex];
    final bool isTodos = selectedCategory == 'Todos';

    final itemsToDisplay = isTodos
        ? _destaques
        : _destaques
              .where((item) => item?.categoria == selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchFieldWidget(
                      controller: _searchController,
                      onSearch: (val) => _loadStores(query: val),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CategoryFiltersWidget(
                      filtros: _filtros,
                      selectedIndex: _selectedFilterIndex,
                      onFilterChanged: (index) {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                        final category = _filtros[index];
                        final id = _categoryMapping[category];
                        _loadStores(categoryId: id);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            if (isTodos)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: HorizontalDestaqueListWidget(items: itemsToDisplay),
                ),
              )
            else
              VerticalDestaqueSliverWidget(items: itemsToDisplay),
            if (isTodos)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 120.0),
                  child: PopularesSectionWidget(populares: _populares),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
          ],
        ),
      ),
    );
  }
}

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 54.0,
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(100.0),
          boxShadow: [
            BoxShadow(
              color: ColorsPalette.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: AppText.corpo(
            context,
          ).copyWith(fontWeight: FontWeight.w500, color: ColorsPalette.black),
          decoration: InputDecoration(
            hintText: "Buscar por comércios...",
            hintStyle: AppText.corpo(
              context,
            ).copyWith(color: Colors.grey.shade400),
            prefixIcon: const Icon(
              LucideIcons.search,
              color: ColorsPalette.redComponents,
              size: 20.0,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          onSubmitted: onSearch,
        ),
      ),
    );
  }
}

class CategoryFiltersWidget extends StatelessWidget {
  final List<String> filtros;
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;

  const CategoryFiltersWidget({
    super.key,
    required this.filtros,
    required this.selectedIndex,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 12.0,
        children: List.generate(filtros.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onFilterChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? ColorsPalette.black : ColorsPalette.white,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text(
                filtros[index],
                style: AppText.corpo(context).copyWith(
                  color: isSelected ? Colors.white : ColorsPalette.greyText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class HorizontalDestaqueListWidget extends StatelessWidget {
  final List<StoreDto> items;

  const HorizontalDestaqueListWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 280.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16.0),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 280.0,
            child: DestaqueCardWidget(destaque: items[index]),
          );
        },
      ),
    );
  }
}

class DestaqueCardWidget extends StatelessWidget {
  final StoreDto destaque;

  const DestaqueCardWidget({super.key, required this.destaque});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoreInfoStorePage(store: destaque),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: ColorsPalette.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 160.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child:
                      destaque.imagens != null && destaque.imagens!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            destaque.imagens![0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              LucideIcons.image,
                              size: 48.0,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        )
                      : Icon(
                          LucideIcons.image,
                          size: 48.0,
                          color: Colors.grey.shade300,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                destaque.nome,
                style: AppText.subtitulo(context).copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColorsPalette.black,
                  fontSize: 18.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.star,
                    color: Colors.amber.shade500,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${destaque.avaliacao ?? 'Novo'} • ${destaque.categoria ?? 'Geral'}",
                    style: AppText.legenda(context).copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class VerticalDestaqueSliverWidget extends StatelessWidget {
  final List<StoreDto> items;

  const VerticalDestaqueSliverWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: Text(
              "Nenhum comércio encontrado para esta categoria",
              style: AppText.corpo(
                context,
              ).copyWith(color: ColorsPalette.greyText),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StoreListItemWidget(store: items[index]),
          );
        }, childCount: items.length),
      ),
    );
  }
}

class StoreListItemWidget extends StatelessWidget {
  final StoreDto store;

  const StoreListItemWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoreInfoStorePage(store: store),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: store.imagens != null && store.imagens!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        store.imagens![0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          LucideIcons.image,
                          size: 24.0,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Icon(
                      LucideIcons.image,
                      size: 24.0,
                      color: Colors.grey.shade400,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.nome,
                    style: AppText.corpo(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ColorsPalette.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.star,
                        color: Colors.amber.shade500,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${store.avaliacao ?? 'Novo'} • ${store.categoria ?? 'Geral'}",
                        style: AppText.legenda(context).copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularesSectionWidget extends StatelessWidget {
  final List<StoreDto> populares;

  const PopularesSectionWidget({super.key, required this.populares});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mais populares",
                style: AppText.subtitulo(context).copyWith(
                  fontWeight: FontWeight.w800,
                  color: ColorsPalette.black,
                ),
              ),
              Text(
                "ver todas",
                style: AppText.legenda(context).copyWith(
                  color: ColorsPalette.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200.0,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: populares.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12.0),
            itemBuilder: (context, index) {
              final item = populares[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreInfoStorePage(store: item),
                    ),
                  );
                },
                child: Container(
                  width: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.shade300,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: item.imagens != null && item.imagens!.isNotEmpty
                            ? Image.network(
                                item.imagens![0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    ColoredBox(color: Colors.grey.shade200),
                              )
                            : ColoredBox(color: Colors.grey.shade200),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10.0,
                        right: 10.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.star,
                                color: Colors.white,
                                size: 10.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                "${item.avaliacao ?? 'Novo'}",
                                style: AppText.legenda(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12.0,
                        left: 12.0,
                        right: 12.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nome,
                              style: AppText.corpo(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.0,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                          ],
                        ),
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
}

class LoginWallHelper {
  static void showLoginWallBottomSheet(BuildContext context) {
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
                  size: 32.0,
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
}
