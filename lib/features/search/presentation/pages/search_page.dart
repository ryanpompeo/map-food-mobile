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
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

/// Quantidade máxima de lojas exibidas em cada seção da visão de navegação
/// (nenhuma categoria marcada, sem busca ativa).
const int _maxSectionItems = 10;

class SearchPage extends StatefulWidget {
  /// Ação do botão de voltar no topo. `null` (o caso de consumidor e
  /// visitante) esconde o cabeçalho inteiro: ali esta página é uma **aba**, e
  /// aba não tem para onde voltar.
  ///
  /// Existe por causa do comerciante, cuja barra inferior trocou "Buscar" por
  /// "Estatísticas" — para ele a busca passou a ser empurrada a partir do
  /// mapa, e página empurrada precisa de saída visível.
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

  /// Categoria em foco, pelo nome. `null` é a listagem sem recorte — o estado
  /// que a tira de filtros não oferece como item e para o qual se volta
  /// desmarcando a categoria ativa (ver `CategoryFiltersWidget`). Guardado
  /// pelo nome, e não pelo índice, porque `_categorias` é recarregável: um
  /// índice sobreviveria à recarga apontando para outra categoria.
  String? _categoriaSelecionada;

  bool _isLoading = false;
  String? _errorMessage;
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

  /// Busca a posição atual uma única vez (sem stream contínuo — o carrossel
  /// "Perto de você" não precisa reordenar a cada passo do usuário, ao
  /// contrário do mapa da aba "Início").
  Future<void> _carregarLocalizacaoUsuario() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 10));
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 10));
      if (permission == LocationPermission.denied) {
        // No Flutter Web o prompt é nativo do navegador, fora do canvas do
        // Flutter — sem timeout, um prompt ignorado/não respondido trava
        // este `await` pra sempre (mesmo problema em NearbyStoresSection,
        // que roda ao mesmo tempo na aba "Início").
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
      // Sem GPS disponível — "Perto de você" cai no fallback sem ordenar por distância.
    }
  }

  /// Puxar para atualizar: refaz as duas buscas de rede desta tela — as
  /// categorias (que alimentam a tira de filtros) e a lista de lojas ativas.
  ///
  /// A lista vem do `ActiveStoresManager` e não de uma chamada local: pedir
  /// direto ao manager mantém uma única fonte para as lojas, e o resultado
  /// chega aqui pelo listener que já existe. Buscar em paralelo porque as duas
  /// são independentes — em série, o gesto duraria a soma das duas.
  Future<void> _recarregar() async {
    await Future.wait([
      _loadInitialData(mostrarSpinner: false),
      _activeStoresManager.load(),
    ]);
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

  /// A API não oferece um endpoint de busca combinada (nome + categoria),
  /// então carregamos todas as lojas ativas uma vez e filtramos localmente.
  ///
  /// [mostrarSpinner] falso no "puxe para atualizar": lá o próprio gesto já é
  /// o indicador de progresso, e ligar `_isLoading` trocaria a tela inteira
  /// por um `CircularProgressIndicator` justamente enquanto a pessoa segura a
  /// lista — o conteúdo sumiria debaixo do dedo.
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
        // Uma categoria que saiu do ar não pode continuar recortando a
        // listagem: sem cartão marcado na tira, o filtro ficaria invisível e
        // não haveria como desfazê-lo.
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
    // Filtra por nome, não por id: o endpoint que alimenta `_allStores`
    // (/mobile/api/v1/lojas, via ActiveStoresManager) devolve `categorias`
    // como lista de nomes crus, sem id (ver StoreDto._parseCategoriaIds) —
    // filtrar por `categoriaIds` aqui nunca daria match e zerava a lista
    // pra qualquer categoria selecionada.
    final categoryName = _categoriaSelecionada;

    var lojasFiltradas = _allStores;
    if (categoryName != null) {
      lojasFiltradas = lojasFiltradas
          .where((s) => s.categoriaNomes.contains(categoryName))
          .toList();
    }
    // `buscarLojas` (não um `contains` no nome): ignora acento, procura também
    // em categoria/cidade/endereço/descrição, tolera um erro de digitação em
    // termos longos e devolve já ordenado por relevância.
    lojasFiltradas = buscarLojas(lojasFiltradas, _searchQuery);

    final emAlta =
        lojasFiltradas.where((s) => (s.avaliacao ?? 0) > 4.5).toList()
          ..sort((a, b) => (b.avaliacao ?? 0).compareTo(a.avaliacao ?? 0));

    List<StoreDto> pertoDeVoce;
    if (_userLat != null && _userLng != null) {
      double distancia(StoreDto s) => Geolocator.distanceBetween(
        _userLat!,
        _userLng!,
        s.latitude!,
        s.longitude!,
      );
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
    // "Perto de você" + "Em Alta" é a visão de navegação: nenhuma categoria
    // marcada e nenhuma busca ativa. É para cá que a tela volta quando a
    // categoria em foco é desmarcada. Com uma query digitada, sempre mostra a
    // lista vertical de resultados, mesmo sem categoria marcada.
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
          // Recarrega categorias e lojas. A lista vem do
          // `ActiveStoresManager`, que só busca a cada 20s — puxar encurta
          // essa espera quando a pessoa quer ver agora quem acabou de abrir.
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
                        // `null` chega quando o toque desmarcou a categoria que
                        // estava ativa — e a tela volta à visão de navegação.
                        onFilterChanged: (nome) {
                          // Idem: cancela um debounce de digitação pendente pra
                          // ele não sobrescrever essa troca de categoria depois.
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
