import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/search/data/services/search_history_service.dart';
import 'package:map_food/features/search/presentation/widgets/category_filters.dart';
import 'package:map_food/features/store/presentation/widgets/em_alta_list_widget.dart';
import 'package:map_food/features/store/presentation/widgets/perto_de_voce_carrossel_widget.dart';
import 'package:map_food/features/search/presentation/widgets/search_field.dart';
import 'package:map_food/features/search/presentation/widgets/search_history.dart';
import 'package:map_food/features/store/presentation/widgets/store_list_widgets.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

/// Quantidade máxima de lojas exibidas em cada seção da aba "Todos".
const int _maxSectionItems = 10;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final CategoriaService _categoriaService = CategoriaService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final ActiveStoresManager _activeStoresManager = ActiveStoresManager.instance;
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

  /// "Em Alta": lojas com avaliação acima de 4.5 dentro do filtro atual.
  List<StoreDto> _emAltaStores = [];

  /// "Perto de você": lojas com localização cadastrada, ordenadas pela
  /// distância até o usuário. Sem `_userLat`/`_userLng` (sem permissão/GPS
  /// indisponível), cai no fallback de mostrar a lista sem ordenar por
  /// distância — melhor que esconder a seção inteira.
  double? _userLat;
  double? _userLng;
  List<StoreDto> _pertoDeVoceStores = [];

  List<String> get _filtros => ['Todos', ..._categorias.map((c) => c.nome)];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _allStores = _activeStoresManager.stores;
    _activeStoresManager.addListener(_onActiveStoresChanged);
    _loadInitialData();
    _loadSearchHistory();
    _carregarLocalizacaoUsuario();
  }

  /// Busca a posição atual uma única vez (sem stream contínuo — o carrossel
  /// "Perto de você" não precisa reordenar a cada passo do usuário, ao
  /// contrário do mapa da aba "Início").
  Future<void> _carregarLocalizacaoUsuario() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;
      setState(() {
        _userLat = posicao.latitude;
        _userLng = posicao.longitude;
      });
      _applyFilters();
    } catch (_) {
      // Sem GPS disponível — "Perto de você" cai no fallback sem ordenar por distância.
    }
  }

  /// Chamado quando o `ActiveStoresManager` (polling a cada 20s, compartilhado
  /// com as home pages) atualiza a lista de lojas ativas — sem isso, a Search
  /// Page buscava as lojas uma única vez no initState e nunca via uma loja
  /// que acabou de ser ativada enquanto a aba já estava montada.
  void _onActiveStoresChanged() {
    if (!mounted) return;
    setState(() => _allStores = _activeStoresManager.stores);
    _applyFilters();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService.getHistory();
    if (mounted) setState(() => _searchHistory = history);
  }

  void _onQueryFromHistory(String query) {
    // Cancela um debounce de digitação pendente — senão ele dispara ~500ms
    // depois com o texto antigo e desfaz essa seleção do histórico.
    _debounce?.cancel();
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
      final categorias = await _categoriaService.getAll();
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
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
    // Filtra por nome, não por id: o endpoint que alimenta `_allStores`
    // (/mobile/api/v1/lojas, via ActiveStoresManager) devolve `categorias`
    // como lista de nomes crus, sem id (ver StoreDto._parseCategoriaIds) —
    // filtrar por `categoriaIds` aqui nunca daria match e zerava a lista
    // pra qualquer categoria selecionada.
    final categoryName = _selectedFilterIndex == 0
        ? null
        : _categorias[_selectedFilterIndex - 1].nome;

    var lojasFiltradas = _allStores;
    if (categoryName != null) {
      lojasFiltradas = lojasFiltradas.where((s) => s.categoriaNomes.contains(categoryName)).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final termoBuscaNormalizado = _searchQuery.trim().toLowerCase();
      lojasFiltradas = lojasFiltradas.where((s) => s.nome.toLowerCase().contains(termoBuscaNormalizado)).toList();
    }

    final emAlta = lojasFiltradas.where((s) => (s.avaliacao ?? 0) > 4.5).toList()
      ..sort((a, b) => (b.avaliacao ?? 0).compareTo(a.avaliacao ?? 0));

    List<StoreDto> pertoDeVoce;
    if (_userLat != null && _userLng != null) {
      double distancia(StoreDto s) => Geolocator.distanceBetween(_userLat!, _userLng!, s.latitude!, s.longitude!);
      pertoDeVoce = lojasFiltradas.where((s) => s.temLocalizacao).toList()
        ..sort((a, b) => distancia(a).compareTo(distancia(b)));
    } else {
      pertoDeVoce = lojasFiltradas;
    }

    setState(() {
      _filteredStores = lojasFiltradas;
      _emAltaStores = emAlta.take(_maxSectionItems).toList();
      _pertoDeVoceStores = pertoDeVoce.take(_maxSectionItems).toList();
    });
  }

  @override
  void dispose() {
    _activeStoresManager.removeListener(_onActiveStoresChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _filtros[_selectedFilterIndex];
    // "Perto de você" é a visão de navegação (categoria "Todos" sem busca
    // ativa). Com uma query digitada, sempre mostra a lista vertical de
    // resultados, mesmo com o índice de categoria resetado para 0.
    final bool isTodos = selectedCategory == 'Todos' && _searchQuery.isEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.mapColors.mainBackground,
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
                        // Idem: cancela um debounce de digitação pendente pra
                        // ele não sobrescrever essa troca de categoria depois.
                        _debounce?.cancel();
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
                      Icon(
                        PhosphorIconsRegular.wifiSlash,
                        size: 48,
                        color: context.mapColors.iconMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppText.corpo(
                          context,
                        ).copyWith(color: context.mapColors.secondaryText),
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
                  child: PertoDeVoceCarrosselWidget(items: _pertoDeVoceStores, userRole: _userRole),
                ),
              ),
              const SliverToBoxAdapter(child: EmAltaSectionHeaderWidget()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              EmAltaListSliverWidget(lojas: _emAltaStores, userRole: _userRole),
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
