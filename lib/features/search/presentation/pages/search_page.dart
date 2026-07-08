import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/search/presentation/pages/view_most_popular.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final StoreService _storeService = StoreService();
  final CategoriaService _categoriaService = CategoriaService();
  Timer? _debounce;
  int _selectedFilterIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String _userRole = 'GUEST';
  String _searchQuery = '';

  List<CategoriaModel> _categorias = [];
  List<StoreDto> _allStores = [];
  List<StoreDto> _destaques = [];
  List<StoreDto> _populares = [];

  List<String> get _filtros => ['Todos', ..._categorias.map((c) => c.nome)];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadInitialData();
  }

  Future<void> _loadUserRole() async {
    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() {
        _userRole = session?.tipo ?? 'GUEST';
      });
    }
  }

  /// A API não oferece um endpoint de busca combinada (nome + categoria),
  /// então carregamos todas as lojas ativas uma vez e filtramos localmente.
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _categoriaService.getAll(),
        _storeService.getActive(),
      ]);
      if (!mounted) return;
      setState(() {
        _categorias = results[0] as List<CategoriaModel>;
        _allStores = results[1] as List<StoreDto>;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível carregar as lojas. Tente novamente.';
      });
    }
  }

  void _applyFilters() {
    final categoryId = _selectedFilterIndex == 0
        ? null
        : _categorias[_selectedFilterIndex - 1].id;

    var list = _allStores;
    if (categoryId != null) {
      list = list.where((s) => s.categoriaIds.contains(categoryId)).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((s) => s.nome.toLowerCase().contains(q)).toList();
    }

    setState(() {
      _destaques = list;
      _populares = list.take(5).toList();
    });
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
                          _searchQuery = val;
                          _applyFilters();
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
                          _searchQuery = '';
                        });
                        _applyFilters();
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
                        onPressed: () => _loadInitialData(),
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
    
    return AnimatedBuilder(
      animation: FavoritesManager.instance,
      builder: (context, _) {
        final isFavorite = FavoritesManager.instance.isFavorite(store.id);
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
          child: GestureDetector(
            onTap: () {
              FavoritesManager.instance.toggle(store);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isFavorite ? "Removido dos favoritos." : "Favoritado com sucesso!"),
                backgroundColor: ColorsPalette.redComponents,
              ));
            },
            child: Icon(
              LucideIcons.heart,
              color: isFavorite ? ColorsPalette.redComponents : ColorsPalette.white,
              size: iconSize,
            ),
          ),
        );
      },
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
                    Navigator.pushNamed(context, AppRoutes.accountType);
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
                  Navigator.pushNamed(context, AppRoutes.login);
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
