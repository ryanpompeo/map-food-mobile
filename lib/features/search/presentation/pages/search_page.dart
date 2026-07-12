import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/services/notification_service.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/favorite_confirmation_dialog.dart';
import 'package:map_food/core/ui/widgets/guest_favorite_cta_sheet.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

const double _kFeaturedCarouselHeight = 220.0;

String _formatRating(double? rating) {
  if (rating == null || rating == 0.0) return 'Novo';
  return rating.toStringAsFixed(1);
}

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
  List<StoreDto> _resultados = [];
  List<StoreDto> _destaques = [];

  List<String> get _filtros => ['Todos', ..._categorias.map((c) => c.nome)];
  bool get _isTodos => _selectedFilterIndex == 0 && _searchQuery.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadInitialData();
  }

  Future<void> _loadUserRole() async {
    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() => _userRole = session?.tipo ?? 'GUEST');
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _categoriaService.getAll(),
        _storeService.getDestaques(),
      ]);
      _categorias = results[0] as List<CategoriaModel>;
      _destaques = results[1] as List<StoreDto>;
      await _fetchResults();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível carregar as lojas. Tente novamente.';
      });
    }
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final categoryId = _selectedFilterIndex == 0
        ? null
        : _categorias[_selectedFilterIndex - 1].id;

    try {
      final results = await _storeService.search(
        nome: _searchQuery.trim(),
        categoriaId: categoryId,
      );
      if (!mounted) return;
      setState(() {
        _resultados = results;
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _selectedFilterIndex = 0;
        _searchQuery = value;
      });
      _fetchResults();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _searchQuery = '');
    _fetchResults();
  }

  void _onFilterChanged(int index) {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedFilterIndex = index;
      _searchQuery = '';
    });
    _fetchResults();
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
              child: _SearchHeader(
                controller: _searchController,
                filtros: _filtros,
                selectedIndex: _selectedFilterIndex,
                onSearchChanged: _onSearchChanged,
                onClearSearch: _clearSearch,
                onFilterChanged: _onFilterChanged,
              ),
            ),
            ..._buildBody(),
            const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_isLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: ColorsPalette.redComponents),
          ),
        ),
      ];
    }

    if (_errorMessage != null) {
      return [_ErrorState(message: _errorMessage!, onRetry: _loadInitialData)];
    }

    if (_resultados.isEmpty) {
      return [_EmptyState(query: _searchQuery.trim())];
    }

    if (_isTodos) {
      return [
        SliverToBoxAdapter(
          child: _SectionHeader(
            icon: LucideIcons.flame,
            title: 'Em destaque',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: _FeaturedCarousel(items: _destaques, userRole: _userRole),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            icon: LucideIcons.store,
            title: 'Todos os comércios',
            trailingLabel: '${_resultados.length}',
          ),
        ),
        _ResultsSliverList(items: _resultados, userRole: _userRole),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Text(
            '${_resultados.length} resultado${_resultados.length == 1 ? '' : 's'} encontrado${_resultados.length == 1 ? '' : 's'}',
            style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w700, color: ColorsPalette.greyText),
          ),
        ),
      ),
      _ResultsSliverList(items: _resultados, userRole: _userRole),
    ];
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final List<String> filtros;
  final int selectedIndex;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<int> onFilterChanged;

  const _SearchHeader({
    required this.controller,
    required this.filtros,
    required this.selectedIndex,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Buscar comércios',
              style: AppText.titulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SearchField(controller: controller, onChanged: onSearchChanged, onClear: onClearSearch),
          const SizedBox(height: AppSpacing.lg),
          _CategoryChips(filtros: filtros, selectedIndex: selectedIndex, onFilterChanged: onFilterChanged),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({required this.controller, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 56.0,
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 6.0),
            Container(
              width: 40.0,
              height: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorsPalette.redComponents.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.search, color: ColorsPalette.redComponents, size: 18.0),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: TextField(
                controller: controller,
                style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w500, color: ColorsPalette.black),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome do comércio...',
                  hintStyle: AppText.corpo(context).copyWith(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                onChanged: onChanged,
                onSubmitted: onChanged,
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.text.isEmpty) return const SizedBox(width: 12.0);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: onClear,
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: Icon(LucideIcons.x, size: 14.0, color: Colors.grey.shade500),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> filtros;
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;

  const _CategoryChips({required this.filtros, required this.selectedIndex, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.0,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filtros.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onFilterChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? ColorsPalette.black : ColorsPalette.white,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                filtros[index],
                style: AppText.legenda(context).copyWith(
                  color: isSelected ? Colors.white : ColorsPalette.greyText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingLabel;

  const _SectionHeader({required this.icon, required this.title, this.trailingLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.0, color: ColorsPalette.redComponents),
              const SizedBox(width: 8.0),
              Text(title, style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black)),
            ],
          ),
          if (trailingLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text(trailingLabel!, style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w700, color: ColorsPalette.greyText)),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  final List<StoreDto> items;
  final String userRole;

  const _FeaturedCarousel({required this.items, required this.userRole});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _controller = PageController(viewportFraction: 0.82);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _kFeaturedCarouselHeight,
          child: PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_controller.position.haveDimensions) {
                    final delta = (_controller.page ?? _page.toDouble()) - index;
                    scale = (1 - (delta.abs() * 0.12)).clamp(0.88, 1.0);
                  }
                  return Center(child: Transform.scale(scale: scale, child: child));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _FeaturedCard(store: widget.items[index], userRole: widget.userRole),
                ),
              );
            },
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.items.length, (index) {
                final isActive = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  width: isActive ? 20.0 : 6.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: isActive ? ColorsPalette.redComponents : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final StoreDto store;
  final String userRole;

  const _FeaturedCard({required this.store, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final hasImage = store.imagens != null && store.imagens!.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MoreInfoStorePage(store: store))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasImage
                ? Image.network(
                    store.imagens!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey.shade200, child: const Icon(LucideIcons.image, size: 40.0, color: Colors.grey)),
                  )
                : Container(color: Colors.grey.shade200, child: const Icon(LucideIcons.image, size: 40.0, color: Colors.grey)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(top: 12.0, right: 12.0, child: _FavoriteButton(store: store, userRole: userRole)),
            Positioned(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.nome,
                    style: AppText.subtitulo(context).copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(LucideIcons.star, color: Colors.amber.shade400, size: 14.0),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          '${_formatRating(store.avaliacao)} • ${store.categoria.isNotEmpty ? store.categoria : 'Geral'}',
                          style: AppText.legenda(context).copyWith(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

class _ResultsSliverList extends StatelessWidget {
  final List<StoreDto> items;
  final String userRole;

  const _ResultsSliverList({required this.items, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _StoreListTile(store: items[index], userRole: userRole),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _StoreListTile extends StatelessWidget {
  final StoreDto store;
  final String userRole;

  const _StoreListTile({required this.store, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final hasImage = store.imagens != null && store.imagens!.isNotEmpty;

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MoreInfoStorePage(store: store))),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(
                        store.imagens!.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.image, size: 26.0, color: Colors.grey.shade400),
                      ),
                    )
                  : Icon(LucideIcons.image, size: 26.0, color: Colors.grey.shade400),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.nome,
                    style: AppText.corpo(context).copyWith(fontSize: 15, fontWeight: FontWeight.w800, color: ColorsPalette.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(LucideIcons.star, color: Colors.amber.shade500, size: 12.0),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          '${_formatRating(store.avaliacao)} • ${store.categoria.isNotEmpty ? store.categoria : 'Geral'}',
                          style: AppText.legenda(context).copyWith(fontSize: 12.0, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FavoriteButton(store: store, userRole: userRole, iconSize: 22.0, dark: true),
            const SizedBox(width: 4.0),
            Icon(LucideIcons.chevronRight, size: 18.0, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(LucideIcons.searchX, color: ColorsPalette.redComponents, size: 36.0),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum comércio encontrado',
              textAlign: TextAlign.center,
              style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              query.isNotEmpty
                  ? 'Não encontramos resultados para "$query". Tente outro termo ou categoria.'
                  : 'Não há comércios ativos nessa categoria no momento.',
              textAlign: TextAlign.center,
              style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 48.0, color: ColorsPalette.greyText),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPalette.redComponents,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final StoreDto store;
  final String userRole;
  final double iconSize;
  final bool dark;

  const _FavoriteButton({required this.store, required this.userRole, this.iconSize = 18.0, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final badgeColor = dark ? Colors.grey.shade100 : Colors.black.withValues(alpha: 0.4);
    final idleColor = dark ? Colors.grey.shade400 : ColorsPalette.white;

    if (userRole == 'GUEST') {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
        child: GestureDetector(
          onTap: () => GuestFavoriteCtaSheet.show(context),
          child: Icon(LucideIcons.heart, color: idleColor, size: iconSize),
        ),
      );
    }

    return AnimatedBuilder(
      animation: FavoritesManager.instance,
      builder: (context, _) {
        final isFavorite = FavoritesManager.instance.isFavorite(store.id);
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
          child: GestureDetector(
            onTap: () async {
              final confirmado = await FavoriteConfirmationDialog.show(context, isFavorite: isFavorite);
              if (!confirmado) return;

              FavoritesManager.instance.toggle(store);
              NotificationService.instance.success(
                isFavorite ? 'Removido dos favoritos.' : 'Favoritado com sucesso!',
              );
            },
            child: Icon(
              LucideIcons.heart,
              color: isFavorite ? ColorsPalette.redComponents : idleColor,
              size: iconSize,
            ),
          ),
        );
      },
    );
  }
}

