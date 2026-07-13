import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/search/data/services/search_history_service.dart';
import 'package:map_food/features/search/presentation/widgets/category_filters_widget.dart';
import 'package:map_food/features/search/presentation/widgets/em_alta_section_widget.dart';
import 'package:map_food/features/search/presentation/widgets/populares_section_widget.dart';
import 'package:map_food/features/search/presentation/widgets/search_field_widget.dart';
import 'package:map_food/features/search/presentation/widgets/search_history_widget.dart';
import 'package:map_food/features/search/presentation/widgets/store_list_widgets.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

/// Quantidade máxima de lojas exibidas em cada seção da aba "Todos".
const int _maxSectionItems = 10;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final StoreService _storeService = StoreService();
  final CategoriaService _categoriaService = CategoriaService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  Timer? _debounce;
  int _selectedFilterIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String _userRole = 'GUEST';
  String _searchQuery = '';
  List<String> _searchHistory = [];

  List<CategoriaModel> _categorias = [];
  List<StoreDto> _allStores = [];

  /// Lista completa filtrada por categoria/busca — usada na visão vertical
  /// quando uma categoria específica está selecionada.
  List<StoreDto> _filteredStores = [];

  /// "Em Alta": melhores notas dentro do filtro atual.
  List<StoreDto> _emAltaStores = [];

  /// "Populares": mais avaliadas pela comunidade, excluindo quem já
  /// aparece em "Em Alta" para não repetir a mesma loja duas vezes.
  List<StoreDto> _popularesStores = [];

  List<String> get _filtros => ['Todos', ..._categorias.map((c) => c.nome)];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadInitialData();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService.getHistory();
    if (mounted) setState(() => _searchHistory = history);
  }

  void _onQueryFromHistory(String query) {
    setState(() {
      _searchController.text = query;
      _selectedFilterIndex = 0;
      _searchQuery = query;
    });
    _applyFilters();
  }

  Future<void> _removeHistoryQuery(String query) async {
    await _searchHistoryService.removeQuery(query);
    _loadSearchHistory();
  }

  Future<void> _clearSearchHistory() async {
    await _searchHistoryService.clear();
    _loadSearchHistory();
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

    final emAlta = [...list]
      ..sort((a, b) => (b.avaliacao ?? 0).compareTo(a.avaliacao ?? 0));
    final emAltaTop = emAlta.take(_maxSectionItems).toList();
    final emAltaIds = emAltaTop.map((s) => s.id).toSet();

    final populares = list.where((s) => !emAltaIds.contains(s.id)).toList()
      ..sort((a, b) => b.totalAvaliacoes.compareTo(a.totalAvaliacoes));

    setState(() {
      _filteredStores = list;
      _emAltaStores = emAltaTop;
      _popularesStores = populares.take(_maxSectionItems).toList();
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
    // "Em Alta"/"Populares" são a visão de navegação (categoria "Todos" sem
    // busca ativa). Com uma query digitada, sempre mostra a lista vertical
    // de resultados, mesmo com o índice de categoria resetado para 0.
    final bool isTodos = selectedCategory == 'Todos' && _searchQuery.isEmpty;

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
                          if (val.trim().isNotEmpty) {
                            _searchHistoryService.addQuery(val).then((_) => _loadSearchHistory());
                          }
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
                    if (_searchQuery.isEmpty && _searchHistory.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      SearchHistoryWidget(
                        history: _searchHistory,
                        onQueryTap: _onQueryFromHistory,
                        onRemove: _removeHistoryQuery,
                        onClear: _clearSearchHistory,
                      ),
                    ],
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
            else if (isTodos) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: EmAltaSectionWidget(items: _emAltaStores, userRole: _userRole),
                ),
              ),
              SliverToBoxAdapter(child: PopularesSectionHeaderWidget(populares: _popularesStores, userRole: _userRole)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              PopularesGridSliverWidget(populares: _popularesStores, userRole: _userRole),
              const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
            ] else ...[
              VerticalDestaqueSliverWidget(items: _filteredStores, userRole: _userRole),
              const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
            ],
          ],
        ),
      ),
    );
  }
}
