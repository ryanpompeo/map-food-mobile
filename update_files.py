import os

search_page_content = """import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/search/data/services/search_service.dart';
import 'package:map_food/features/search/presentation/pages/view_most_popular.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  Timer? _debounce;
  int _selectedFilterIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String _userRole = 'GUEST';

  final List<String> _filtros = [
    'Todos', 'Lanches e Hot Dogs', 'Espetinhos', 'Pastel e Salgados',
    'Doces e Sobremesas', 'Bebidas', 'Gelatos e Açaí', 'Milho e Pamonha',
    'Pipoca', 'Produtos Artesanais', 'Food Trucks', 'Outros',
  ];

  final Map<String, int> _categoryMapping = {
    'Lanches e Hot Dogs': 1, 'Espetinhos': 6, 'Pastel e Salgados': 2,
    'Doces e Sobremesas': 3, 'Bebidas': 4, 'Gelatos e Açaí': 5,
    'Milho e Pamonha': 7, 'Pipoca': 8, 'Produtos Artesanais': 9,
    'Food Trucks': 10, 'Outros': 11,
  };

  List<StoreDto> _destaques = [];
  List<StoreDto> _populares = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadStores();
  }

  Future<void> _loadUserRole() async {
    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() {
        _userRole = session?.tipo ?? 'GUEST';
      });
    }
  }

  Future<void> _loadStores({int? categoryId, String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<StoreDto> results = await _searchService.search(
        nome: (query != null && query.trim().isNotEmpty) ? query.trim() : null,
        categoriaId: categoryId,
      );

      if (!mounted) return;
      setState(() {
        _destaques = results;
        _populares = results.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível carregar as lojas. Tente novamente.';
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _filtros[_selectedFilterIndex];
    final bool isTodos = selectedCategory == 'Todos';
    final itemsToDisplay = _destaques;

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
                      onChanged: (val) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          setState(() => _selectedFilterIndex = 0);
                          _loadStores(query: val);
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CategoryFiltersWidget(
                      filtros: _filtros,
                      selectedIndex: _selectedFilterIndex,
                      onFilterChanged: (index) {
                        setState(() {
                          _selectedFilterIndex = index;
                          _searchController.clear();
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
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorsPalette.redComponents,
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.wifiOff,
                        size: 48,
                        color: ColorsPalette.greyText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppText.corpo(
                          context,
                        ).copyWith(color: ColorsPalette.greyText),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadStores(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsPalette.redComponents,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (isTodos)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: HorizontalDestaqueListWidget(items: itemsToDisplay, userRole: _userRole),
                ),
              )
            else
              VerticalDestaqueSliverWidget(items: itemsToDisplay, userRole: _userRole),
            if (!_isLoading && _errorMessage == null && isTodos)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 120.0),
                  child: PopularesSectionWidget(populares: _populares, userRole: _userRole),
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

String _formatRating(double? rating) {
  if (rating == null || rating == 0.0) return 'Novo';
  return rating.toStringAsFixed(1);
}

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchFieldWidget({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 54.0,
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
          style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w500, color: ColorsPalette.black),
          decoration: InputDecoration(
            hintText: "Buscar por comércios...",
            hintStyle: AppText.corpo(context).copyWith(color: Colors.grey.shade400),
            prefixIcon: const Icon(LucideIcons.search, color: ColorsPalette.redComponents, size: 20.0),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          onChanged: onChanged,
          onSubmitted: onChanged,
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
    super.key, required this.filtros, required this.selectedIndex, required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: 8.0, runSpacing: 12.0,
        children: List.generate(filtros.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onFilterChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
  final String userRole;

  const HorizontalDestaqueListWidget({super.key, required this.items, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Em Alta", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMostPopular())),
                child: Text("ver todas", style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 280.0,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16.0),
            itemBuilder: (context, index) => SizedBox(width: 280.0, child: DestaqueCardWidget(destaque: items[index], userRole: userRole)),
          ),
        ),
      ],
    );
  }
}

class DestaqueCardWidget extends StatelessWidget {
  final StoreDto destaque;
  final String userRole;

  const DestaqueCardWidget({super.key, required this.destaque, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreInfoStorePage(store: destaque))),
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
                  height: 160.0, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16.0)),
                  child: destaque.imagens != null && destaque.imagens!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            destaque.imagens![0], fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.image, size: 48.0, color: Colors.grey.shade300),
                          ),
                        )
                      : Icon(LucideIcons.image, size: 48.0, color: Colors.grey.shade300),
                ),
                Positioned(
                  top: 12.0, right: 12.0,
                  child: FavoriteButtonWidget(store: destaque, userRole: userRole),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                destaque.nome,
                style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black, fontSize: 18.0),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Icon(LucideIcons.star, color: Colors.amber.shade500, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "${_formatRating(destaque.avaliacao)} • ${destaque.categoria.isNotEmpty ? destaque.categoria : 'Geral'}",
                    style: AppText.legenda(context).copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
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
  final String userRole;

  const VerticalDestaqueSliverWidget({super.key, required this.items, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(child: Text("Nenhum comércio encontrado para esta categoria", style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText))),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StoreListItemWidget(store: items[index], userRole: userRole),
          );
        }, childCount: items.length),
      ),
    );
  }
}

class StoreListItemWidget extends StatelessWidget {
  final StoreDto store;
  final String userRole;

  const StoreListItemWidget({super.key, required this.store, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreInfoStorePage(store: store))),
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 72.0, height: 72.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: store.imagens != null && store.imagens!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        store.imagens![0], fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.image, size: 24.0, color: Colors.grey.shade400),
                      ),
                    )
                  : Icon(LucideIcons.image, size: 24.0, color: Colors.grey.shade400),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.nome, style: AppText.corpo(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800, color: ColorsPalette.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(LucideIcons.star, color: Colors.amber.shade500, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "${_formatRating(store.avaliacao)} • ${store.categoria.isNotEmpty ? store.categoria : 'Geral'}",
                        style: AppText.legenda(context).copyWith(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                ],
              ),
            ),
            FavoriteButtonWidget(store: store, userRole: userRole, iconSize: 24),
          ],
        ),
      ),
    );
  }
}

class PopularesSectionWidget extends StatelessWidget {
  final List<StoreDto> populares;
  final String userRole;

  const PopularesSectionWidget({super.key, required this.populares, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (populares.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Populares", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMostPopular())),
                child: Text("ver todas", style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600)),
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
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreInfoStorePage(store: item))),
                child: Container(
                  width: 150.0,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.grey.shade300),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: item.imagens != null && item.imagens!.isNotEmpty
                            ? Image.network(item.imagens![0], fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => ColoredBox(color: Colors.grey.shade200))
                            : ColoredBox(color: Colors.grey.shade200),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)], stops: const [0.5, 1.0]),
                        ),
                      ),
                      Positioned(
                        top: 10.0, right: 10.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(100.0)),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.star, color: Colors.white, size: 10.0),
                              const SizedBox(width: 4.0),
                              Text(_formatRating(item.avaliacao), style: AppText.legenda(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.0)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12.0, left: 12.0, right: 12.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nome, style: AppText.corpo(context).copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.0, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (item.categoria.isNotEmpty) ...[
                              const SizedBox(height: 2.0),
                              Text(item.categoria, style: AppText.legenda(context).copyWith(color: Colors.white.withValues(alpha: 0.75), fontSize: 10.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
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

class FavoriteButtonWidget extends StatelessWidget {
  final StoreDto store;
  final String userRole;
  final double iconSize;

  const FavoriteButtonWidget({super.key, required this.store, required this.userRole, this.iconSize = 18.0});

  @override
  Widget build(BuildContext context) {
    if (userRole == 'GUEST') {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
        child: GestureDetector(
          onTap: () => LoginWallHelper.showLoginWallBottomSheet(context),
          child: Icon(LucideIcons.heart, color: ColorsPalette.white, size: iconSize),
        ),
      );
    }
    
    // AuthFavoriteButton
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favoritado com sucesso!"), backgroundColor: ColorsPalette.redComponents));
        },
        child: Icon(LucideIcons.heart, color: ColorsPalette.white, size: iconSize),
      ),
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
            borderRadius: BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40.0, height: 4.0, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.0))),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.heart, color: ColorsPalette.redComponents, size: 32.0),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "Salve seus comércios favoritos!",
                textAlign: TextAlign.center,
                style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black, letterSpacing: -0.5),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Crie uma conta gratuita em segundos para salvar, avaliar e denunciar comércios na sua cidade.",
                textAlign: TextAlign.center,
                style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText, height: 1.3),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity, height: 52.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/accountType');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)), elevation: 0,
                  ),
                  child: Text("Criar Conta Gratuita", style: AppText.botao(context).copyWith(fontWeight: FontWeight.bold)),
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
                    style: AppText.legenda(context).copyWith(color: ColorsPalette.blackDetails, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
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
"""

more_info_store_content = """import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/reviews/data/models/avaliacao_model.dart';
import 'package:map_food/features/reviews/data/services/rating_service.dart';
import 'package:map_food/features/search/widgets/floating_map_buttom.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart' show LoginWallHelper;

class MoreInfoStorePage extends StatefulWidget {
  final StoreDto store;

  const MoreInfoStorePage({super.key, required this.store});

  @override
  State<MoreInfoStorePage> createState() => _MoreInfoStorePageState();
}

class _MoreInfoStorePageState extends State<MoreInfoStorePage> {
  final RatingService _ratingService = RatingService();

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoadingRatings = true;
  String? _ratingsError;
  String _userRole = 'GUEST';
  String _userName = 'Usuário';

  @override
  void initState() {
    super.initState();
    _fetchRatings();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() {
        _userRole = session?.tipo ?? 'GUEST';
        _userName = session?.nome ?? 'Usuário';
      });
    }
  }

  Future<void> _fetchRatings() async {
    try {
      final ratings = await _ratingService.getStoreRatings(widget.store.id);
      if (!mounted) return;
      setState(() {
        _avaliacoes = ratings;
        _isLoadingRatings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ratingsError = 'Não foi possível carregar as avaliações.';
        _isLoadingRatings = false;
      });
    }
  }

  String _formatRating(double? rating) {
    if (rating == null || rating == 0.0) return 'Novo';
    return rating.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

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
                  icon: const Icon(LucideIcons.chevronLeft, color: ColorsPalette.redComponents),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: ColorsPalette.whiteBackground),
                    child: store.imagens != null && store.imagens!.isNotEmpty
                        ? ClipRRect(
                            child: Image.network(
                              store.imagens![0], fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image, size: 64.0, color: Colors.grey)),
                            ),
                          )
                        : const Center(child: Icon(LucideIcons.image, size: 64.0, color: Colors.grey)),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)]),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          store.nome,
                          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, fontSize: 24.0, color: ColorsPalette.black, height: 1.1),
                        ),
                      ),
                      if (_userRole == 'CONSUMIDOR')
                        ConsumerActionWidget(),
                    ],
                  ),
                  if (store.categoriaNomes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(spacing: 6.0, runSpacing: 6.0, children: _buildCategoryChips(context, store)),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  Text('Sobre o local', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    store.descricao ?? 'O vendedor não adicionou uma descrição detalhada para este comércio.',
                    style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Galeria de fotos', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black)),
                      Text('${store.imagens?.length ?? 0} fotos', style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 140.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), clipBehavior: Clip.none,
                      itemCount: store.imagens?.length ?? 0,
                      separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 140.0,
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16.0), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(store.imagens![index], fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image, color: Colors.grey, size: 32.0))),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Divider(thickness: 0.2),
                  const SizedBox(height: AppSpacing.lg),

                  _buildAvaliacoesSection(context, store),

                  const SizedBox(height: 120.0),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPalette.redComponents,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
              elevation: 4,
            ),
            child: Text(
              'Visualizar no mapa',
              style: AppText.botao(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> _buildCategoryChips(BuildContext context, StoreDto store) {
    final names = store.categoriaNomes.isNotEmpty ? store.categoriaNomes : [store.categoria.isNotEmpty ? store.categoria : 'Geral'];
    return names.map((name) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: ColorsPalette.redComponents.withValues(alpha: 0.2))),
      child: Text(name, style: AppText.legenda(context).copyWith(color: ColorsPalette.redComponents, fontWeight: FontWeight.w700)),
    )).toList();
  }

  Widget _buildAvaliacoesSection(BuildContext context, StoreDto store) {
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
                Text('Avaliações', style: AppText.titulo(context).copyWith(fontWeight: FontWeight.w900)),
                Text(_isLoadingRatings ? 'Carregando...' : '${_avaliacoes.length} avaliações', style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100.0)),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(_formatRating(store.avaliacao), style: AppText.subtitulo(context).copyWith(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        if (_isLoadingRatings)
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: CircularProgressIndicator(color: ColorsPalette.redComponents, strokeWidth: 2.5)))
        else if (_ratingsError != null)
          _RatingsErrorWidget(onRetry: _fetchRatings)
        else if (_avaliacoes.isEmpty)
          _RatingsEmptyWidget()
        else
          ..._avaliacoes.map((review) => _ReviewCard(review: review)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final AvaliacaoModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final nome = review.consumidor?.nome ?? 'Usuário';
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';
    final data = _formatDate(review.dataAvaliacao);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.1), child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.bold, color: ColorsPalette.redComponents))),
                  const SizedBox(width: 8),
                  Text(nome, style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Text(data, style: AppText.legenda(context).copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: List.generate(5, (index) => Icon(index < review.nota ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 16))),
          if (review.comentario != null && review.comentario!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(review.comentario!, style: AppText.corpo(context).copyWith(color: Colors.grey.shade700, height: 1.4)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) return 'Hoje';
      if (diff.inDays == 1) return 'Ontem';
      if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
      if (diff.inDays < 30) return 'Há ${(diff.inDays / 7).floor()} semanas';
      if (diff.inDays < 365) return 'Há ${(diff.inDays / 30).floor()} meses';
      return 'Há ${(diff.inDays / 365).floor()} anos';
    } catch (_) { return ''; }
  }
}

class _RatingsErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  const _RatingsErrorWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            Icon(LucideIcons.alertCircle, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.md),
            Text('Não foi possível carregar as avaliações.', style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente', style: TextStyle(color: ColorsPalette.redComponents))),
          ],
        ),
      ),
    );
  }
}

class _RatingsEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(LucideIcons.messageSquare, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: AppSpacing.md),
          Text('Nenhuma avaliação ainda', style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w700, color: ColorsPalette.black)),
          const SizedBox(height: AppSpacing.xs),
          Text('Seja o primeiro a avaliar este comércio!', style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ConsumerActionWidget extends StatelessWidget {
  const ConsumerActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String motivoSelecionado = 'Outro';
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(AppSpacing.lg),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.flag, color: ColorsPalette.redComponents, size: 20),
                                  const SizedBox(width: 8),
                                  Text("Denunciar loja", style: AppText.titulo(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              IconButton(icon: const Icon(LucideIcons.x, size: 20, color: Colors.grey), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text("Seu relatório será analisado pela nossa equipe. Obrigado por manter a plataforma segura.", style: AppText.corpo(context).copyWith(color: Colors.brown.shade800, fontSize: 13)),
                          const SizedBox(height: AppSpacing.lg),
                          Text("Motivo", style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0), border: Border.all(color: ColorsPalette.redComponents.withValues(alpha: 0.3), width: 1.2)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: motivoSelecionado,
                                isExpanded: true,
                                dropdownColor: const Color(0xFFFCF9F9),
                                borderRadius: BorderRadius.circular(12.0),
                                icon: const Icon(LucideIcons.chevronDown, size: 18, color: Colors.black87),
                                items: ['Conteúdo inapropriado', 'Fraude ou golpe', 'Informações falsas', 'Spam', 'Outro'].map((String motivo) {
                                  return DropdownMenuItem<String>(value: motivo, child: Text(motivo, style: AppText.corpo(context).copyWith(color: Colors.black87)));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) setModalState(() => motivoSelecionado = newValue);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar", style: AppText.botao(context).copyWith(color: Colors.brown.shade800))),
                              const SizedBox(width: AppSpacing.sm),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Denúncia enviada."), backgroundColor: ColorsPalette.redComponents));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: ColorsPalette.redComponents, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill))),
                                child: const Text("Enviar denúncia", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
        child: Row(
          children: [
            const Icon(LucideIcons.flag, size: 14, color: ColorsPalette.redComponents),
            const SizedBox(width: 6),
            Text("Denunciar", style: AppText.legenda(context).copyWith(color: ColorsPalette.redComponents, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
"""

with open("lib/features/search/presentation/pages/search_page.dart", "w") as f:
    f.write(search_page_content)

with open("lib/features/store/presentation/pages/more_info_store.dart", "w") as f:
    f.write(more_info_store_content)
