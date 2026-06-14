import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/consumer_more_info.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';

class ConsumerSearch extends StatefulWidget {
  const ConsumerSearch({super.key});

  @override
  State<ConsumerSearch> createState() => _SearchPageState();
}

class _SearchPageState extends State<ConsumerSearch> {
  final TextEditingController _searchController = TextEditingController();
  final StoreService _storeService = StoreService();

  int _selectedFilterIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _filtros = [
    'Todos',
    'Lanches e Hot Dogs',
    'Espetinhos',
    'Pastel e Salgados',
    'Doces e Sobremesas',
    'Bebidas',
    'Gelados e Açaí',
    'Milho e Pamonha',
    'Pipoca',
  ];

  final Map<String, int> _categoryMapping = {
    'Lanches e Hot Dogs': 1,
    'Espetinhos': 6,
    'Pastel e Salgados': 2,
    'Doces e Sobremesas': 3,
    'Bebidas': 4,
    'Gelados e Açaí': 5,
    'Milho e Pamonha': 7,
    'Pipoca': 8,
  };

  List<StoreDto> _destaques = [];
  List<StoreDto> _populares = [];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores({int? categoryId, String? query}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<StoreDto> results;

      if (query != null && query.trim().isNotEmpty) {
        results = await _storeService.searchByName(query.trim());
      } else if (categoryId != null) {
        results = await _storeService.getByCategory(categoryId);
      } else {
        results = await _storeService.getActive();
      }

      if (!mounted) return;
      setState(() {
        _destaques = results;
        _populares = results.take(5).toList();
      });
    } on NetworkException {
      if (!mounted) return;
      setState(() => _errorMessage = 'Sem conexão. Verifique sua internet.');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onSearchSubmit(String val) async {
    if (val.trim().isEmpty) {
      setState(() => _selectedFilterIndex = 0);
      await _loadStores();
    } else {
      await _loadStores(query: val);
    }
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
        : _destaques.where((item) => item.categoria == selectedCategory).toList();

    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: ColorsPalette.redComponents,
          onRefresh: () => _loadStores(
            categoryId: _selectedFilterIndex == 0
                ? null
                : _categoryMapping[_filtros[_selectedFilterIndex]],
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchFieldWidget(
                        controller: _searchController,
                        onSearch: _onSearchSubmit,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CategoryFiltersWidget(
                        filtros: _filtros,
                        selectedIndex: _selectedFilterIndex,
                        onFilterChanged: (index) {
                          setState(() => _selectedFilterIndex = index);
                          _searchController.clear();
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

              // Estado: Carregando
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadingState(),
                )

              // Estado: Erro
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: _errorMessage!,
                    onRetry: () => _loadStores(
                      categoryId: _selectedFilterIndex == 0
                          ? null
                          : _categoryMapping[_filtros[_selectedFilterIndex]],
                    ),
                  ),
                )

              // Estado: Vazio
              else if (_destaques.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    message: _searchController.text.trim().isNotEmpty
                        ? 'Nenhum comércio encontrado para "${_searchController.text.trim()}"'
                        : 'Nenhum comércio ativo no momento.',
                  ),
                )

              // Estado: Com dados
              else ...[
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
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets de estado da página
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: ColorsPalette.redComponents,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Buscando comércios...',
            style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
          ),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.wifiOff,
                size: 36.0,
                color: ColorsPalette.redComponents,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Ops! Algo deu errado',
              style: AppText.subtitulo(context).copyWith(
                fontWeight: FontWeight.w800,
                color: ColorsPalette.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppText.corpo(context).copyWith(
                color: ColorsPalette.greyText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16.0),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPalette.redComponents,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.store, size: 36.0, color: Colors.grey.shade400),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppText.corpo(context).copyWith(
                color: ColorsPalette.greyText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Campo de Busca
// ---------------------------------------------------------------------------

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
          style: AppText.corpo(context)
              .copyWith(fontWeight: FontWeight.w500, color: ColorsPalette.black),
          decoration: InputDecoration(
            hintText: 'Buscar por comércios...',
            hintStyle: AppText.corpo(context).copyWith(color: Colors.grey.shade400),
            prefixIcon: const Icon(
              LucideIcons.search,
              color: ColorsPalette.redComponents,
              size: 20.0,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: onSearch,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filtros de Categoria
// ---------------------------------------------------------------------------

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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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

// ---------------------------------------------------------------------------
// Lista Horizontal de Destaques
// ---------------------------------------------------------------------------

class HorizontalDestaqueListWidget extends StatelessWidget {
  final List<StoreDto> items;

  const HorizontalDestaqueListWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Abertos agora',
            style: AppText.subtitulo(context).copyWith(
              fontWeight: FontWeight.w800,
              color: ColorsPalette.black,
            ),
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
            itemBuilder: (context, index) {
              return SizedBox(
                width: 280.0,
                child: DestaqueCardWidget(destaque: items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card de Destaque
// ---------------------------------------------------------------------------

class DestaqueCardWidget extends StatelessWidget {
  final StoreDto destaque;

  const DestaqueCardWidget({super.key, required this.destaque});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConsumerMoreInfo(store: destaque)),
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
                  child: destaque.imagens != null && destaque.imagens!.isNotEmpty
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
                      : Icon(LucideIcons.image, size: 48.0, color: Colors.grey.shade300),
                ),
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedBuilder(
                      animation: FavoritesManager.instance,
                      builder: (_, __) {
                        final isFavorite = FavoritesManager.instance.isFavorite(destaque.id);
                        return GestureDetector(
                          onTap: () => FavoritesManager.instance.toggle(destaque),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 180),
                            scale: isFavorite ? 1.15 : 1.0,
                            child: Icon(
                              LucideIcons.heart,
                              color: isFavorite ? Colors.red : ColorsPalette.white,
                              size: 18.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Badge de status ativa
                Positioned(
                  top: 12.0,
                  left: 12.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Aberto',
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
                  Icon(LucideIcons.star, color: Colors.amber.shade500, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${destaque.avaliacao != null ? destaque.avaliacao!.toStringAsFixed(1) : 'Novo'} • ${destaque.categoria}',
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

// ---------------------------------------------------------------------------
// Lista Vertical de Lojas (por categoria)
// ---------------------------------------------------------------------------

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
              'Nenhum comércio encontrado para esta categoria',
              style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StoreListItemWidget(store: items[index]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item de lista de loja (linha)
// ---------------------------------------------------------------------------

class StoreListItemWidget extends StatelessWidget {
  final StoreDto store;

  const StoreListItemWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConsumerMoreInfo(store: store)),
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
                  : Icon(LucideIcons.image, size: 24.0, color: Colors.grey.shade400),
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
                      Icon(LucideIcons.star, color: Colors.amber.shade500, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${store.avaliacao != null ? store.avaliacao!.toStringAsFixed(1) : 'Novo'} • ${store.categoria}',
                          style: AppText.legenda(context).copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: FavoritesManager.instance,
              builder: (_, __) {
                final isFavorite = FavoritesManager.instance.isFavorite(store.id);
                return IconButton(
                  icon: AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    scale: isFavorite ? 1.15 : 1.0,
                    child: Icon(
                      LucideIcons.heart,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                  onPressed: () => FavoritesManager.instance.toggle(store),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seção "Mais Populares" (primeiros resultados da API)
// ---------------------------------------------------------------------------

class PopularesSectionWidget extends StatelessWidget {
  final List<StoreDto> populares;

  const PopularesSectionWidget({super.key, required this.populares});

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
              Text(
                'Mais populares',
                style: AppText.subtitulo(context).copyWith(
                  fontWeight: FontWeight.w800,
                  color: ColorsPalette.black,
                ),
              ),
              Text(
                'ver todas',
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
                      builder: (context) => ConsumerMoreInfo(store: item),
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
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10.0,
                        right: 10.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.star, color: Colors.white, size: 10.0),
                              const SizedBox(width: 4.0),
                              Text(
                                item.avaliacao != null
                                    ? item.avaliacao!.toStringAsFixed(1)
                                    : 'Novo',
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
                        child: Text(
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

// ---------------------------------------------------------------------------
// Modal de parede de login (para convidados)
// ---------------------------------------------------------------------------

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
                'Salve seus comércios favoritos!',
                textAlign: TextAlign.center,
                style: AppText.subtitulo(context).copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColorsPalette.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Crie uma conta gratuita em segundos para salvar, avaliar e denunciar comércios na sua cidade.',
                textAlign: TextAlign.center,
                style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText, height: 1.3),
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
                    'Criar Conta Gratuita',
                    style: AppText.botao(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Já tenho uma conta',
                  style: AppText.corpo(context).copyWith(
                    color: ColorsPalette.blackDetails,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}
