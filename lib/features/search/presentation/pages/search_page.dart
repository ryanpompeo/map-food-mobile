import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_refresh.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/features/search/data/services/search_history_service.dart';
import 'package:map_food/features/search/data/store_search.dart';
import 'package:map_food/features/search/presentation/widgets/category_filters.dart';
import 'package:map_food/features/store/presentation/widgets/em_alta_list_widget.dart';
import 'package:map_food/features/store/presentation/widgets/perto_de_voce_carrossel_widget.dart';
import 'package:map_food/features/search/presentation/widgets/search_field.dart';
import 'package:map_food/features/search/presentation/widgets/search_history.dart';
import 'package:map_food/features/store/presentation/widgets/store_list_widgets.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/nearby_filter.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

const int _maxSectionItems = 10;

const double _pertoDeVoceRaioKm = 3.0;
const int _pertoDeVoceMaxItems = 5;

class SearchPage extends StatefulWidget {
  final VoidCallback? onVoltar;

  const SearchPage({super.key, this.onVoltar});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final CategoriaService _categoriaService = CategoriaService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final ActiveStoresManager _activeStoresManager = ActiveStoresManager.instance;
  Timer? _debounce;

  String? _categoriaSelecionada;

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  List<String> _searchHistory = [];

  List<CategoriaModel> _categorias = [];
  List<StoreDto> _allStores = [];

  List<StoreDto> _filteredStores = [];

  List<StoreDto> _emAltaStores = [];

  double? _userLat;
  double? _userLng;
  List<StoreDto> _pertoDeVoceStores = [];

  List<String> get _filtros => _categorias.map((c) => c.nome).toList();

  @override
  void initState() {
    super.initState();
    _allStores = _activeStoresManager.stores;
    _activeStoresManager.addListener(_onActiveStoresChanged);
    _loadInitialData();
    _loadSearchHistory();
    _carregarLocalizacaoUsuario();
  }

  Future<void> _carregarLocalizacaoUsuario() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 10));
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 10));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 10),
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _userLat = posicao.latitude;
        _userLng = posicao.longitude;
      });
      _applyFilters();
    } catch (_) {
    }
  }

  Future<void> _recarregar() async {
    await Future.wait([
      _loadInitialData(mostrarSpinner: false),
      _activeStoresManager.load(),
    ]);
  }

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
    _debounce?.cancel();
    setState(() {
      _searchController.text = query;
      _categoriaSelecionada = null;
      _searchQuery = query;
    });
    _applyFilters();
  }

  Future<void> _removeHistoryQuery(String query) async {
    await _searchHistoryService.removeQuery(query);
    unawaited(_loadSearchHistory());
  }

  Future<void> _clearSearchHistory() async {
    await _searchHistoryService.clear();
    unawaited(_loadSearchHistory());
  }

  Future<void> _loadInitialData({bool mostrarSpinner = true}) async {
    setState(() {
      if (mostrarSpinner) _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categorias = await _categoriaService.getAll();
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        if (!categorias.any((c) => c.nome == _categoriaSelecionada)) {
          _categoriaSelecionada = null;
        }
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
    final categoryName = _categoriaSelecionada;

    var lojasFiltradas = _allStores;
    if (categoryName != null) {
      lojasFiltradas = lojasFiltradas
          .where((s) => s.categoriaNomes.contains(categoryName))
          .toList();
    }
    lojasFiltradas = buscarLojas(lojasFiltradas, _searchQuery);

    final emAlta =
        lojasFiltradas.where((s) => (s.avaliacao ?? 0) > 4.5).toList()
          ..sort((a, b) => (b.avaliacao ?? 0).compareTo(a.avaliacao ?? 0));

    List<StoreDto> pertoDeVoce = lojasDentroDoRaio(
      lojasFiltradas,
      lat: _userLat,
      lng: _userLng,
      raioKm: _pertoDeVoceRaioKm,
    );

    if (_userLat != null && _userLng != null) {
      double distancia(StoreDto s) => Geolocator.distanceBetween(
        _userLat!,
        _userLng!,
        s.latitude!,
        s.longitude!,
      );
      pertoDeVoce = pertoDeVoce.toList()
        ..sort((a, b) => distancia(a).compareTo(distancia(b)));
    }

    setState(() {
      _filteredStores = lojasFiltradas;
      _emAltaStores = emAlta.take(_maxSectionItems).toList();
      _pertoDeVoceStores = pertoDeVoce.take(_pertoDeVoceMaxItems).toList();
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
    final bool semRecorte =
        _categoriaSelecionada == null && _searchQuery.isEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.mapColors.mainBackground,
      appBar: widget.onVoltar == null
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: context.mapColors.mainBackground,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              leading: IconButton(
                onPressed: widget.onVoltar,
                icon: const Icon(
                  AppIcons.caretLeft,
                  color: ColorsPalette.redComponents,
                ),
              ),
              title: Text(
                'Buscar',
                style: AppText.subtitulo(context).copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.mapColors.primaryText,
                ),
              ),
            ),
      body: SafeArea(
        child: AppRefresh(
          onRefresh: _recarregar,
          child: CustomScrollView(
            physics: AppRefresh.physics,
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
                          _debounce = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              setState(() => _categoriaSelecionada = null);
                              _searchQuery = val;
                              _applyFilters();
                              if (val.trim().isNotEmpty) {
                                _searchHistoryService
                                    .addQuery(val)
                                    .then((_) => _loadSearchHistory());
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CategoryFiltersWidget(
                        filtros: _filtros,
                        selecionada: _categoriaSelecionada,
                        onFilterChanged: (nome) {
                          _debounce?.cancel();
                          setState(() {
                            _categoriaSelecionada = nome;
                            _searchController.clear();
                            _searchQuery = '';
                          });
                          _applyFilters();
                        },
                      ),
                      if (_searchQuery.isEmpty &&
                          _searchHistory.isNotEmpty) ...[
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
                    child: EmptyState(
                      icon: AppIcons.wifiSlash,
                      title: 'Não foi possível carregar',
                      description: _errorMessage!,
                      actionLabel: 'Tentar novamente',
                      onAction: () => _loadInitialData(),
                      tone: EmptyStateTone.error,
                    ),
                  ),
                )
              else if (semRecorte) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: PertoDeVoceCarrosselWidget(
                      items: _pertoDeVoceStores,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: EmAltaSectionHeaderWidget()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),
                EmAltaListSliverWidget(lojas: _emAltaStores),
                const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
              ] else ...[
                VerticalDestaqueSliverWidget(items: _filteredStores),
                const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
