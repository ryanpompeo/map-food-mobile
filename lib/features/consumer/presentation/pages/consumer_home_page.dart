import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/category_filter_chips.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/favorites/presentation/pages/consumer_favorites_page.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_profile_page.dart';
import 'package:map_food/features/consumer/presentation/widgets/consumer_bottom_bar.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/nearby_stores_section.dart';

class ConsumerHomePage extends StatefulWidget {
  const ConsumerHomePage({super.key});

  @override
  State<ConsumerHomePage> createState() => _ConsumerHomePage();
}

class _ConsumerHomePage extends State<ConsumerHomePage> {
  int _selectedIndex = 0;
  String _filtroAtivo = 'Todos';

  String _userName = '';
  String _userEmail = '';
  bool _sessionLoaded = false;

  final _categoriaService = CategoriaService();
  List<CategoriaModel> _categorias = [];

  final _locationService = LocationService();
  String? _locationLabel;
  double? _userLatitude;
  double? _userLongitude;
  bool _locationLoading = true;
  bool _locationDenied = false;

  final _storeService = StoreService();
  List<StoreDto> _lojas = [];
  bool _isLoadingLojas = true;

  List<String> get _filtrosMapa => ['Todos', ..._categorias.map((c) => c.nome)];

  List<StoreDto> get _lojasFiltradas => _filtroAtivo == 'Todos'
      ? _lojas
      : _lojas.where((l) => l.categoriaNomes.contains(_filtroAtivo)).toList();

  @override
  void initState() {
    super.initState();
    _loadSession();
    _carregarCategorias();
    _loadLocation();
    _carregarLojas();
  }

  Future<void> _carregarLojas() async {
    try {
      final lojas = await _storeService.getActive();
      if (mounted) setState(() => _lojas = lojas);
    } catch (_) {
      // Mapa fica vazio se a API estiver indisponível.
    } finally {
      if (mounted) setState(() => _isLoadingLojas = false);
    }
  }

  Future<void> _loadLocation() async {
    setState(() {
      _locationLoading = true;
      _locationDenied = false;
    });
    try {
      final result = await _locationService.getCurrentAddressLabel();
      if (!mounted) return;
      setState(() {
        _locationLoading = false;
        _locationDenied = result.status != LocationStatus.granted;
        _locationLabel = result.label;
        _userLatitude = result.latitude;
        _userLongitude = result.longitude;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationLoading = false;
        _locationDenied = true;
      });
    }
  }

  Future<void> _onLocationTap() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }
    _loadLocation();
  }

  Future<void> _loadSession() async {
    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() {
        _userName = session?.nome ?? '';
        _userEmail = session?.email ?? '';
        _sessionLoaded = true;
      });
    }
    FavoritesManager.instance.load();
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {
      // Mantém apenas "Todos" se a API estiver indisponível.
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildAbaInicio(),
              const SearchPage(),
              ConsumerFavoritesPage(),
              ConsumerProfilePage(
                userName: _userName,
                userEmail: _userEmail,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ConsumerBottomBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbaInicio() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12.0,
            bottom: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: ColorsPalette.whiteBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
                  onTap: (_locationDenied || _locationLabel == null) ? _onLocationTap : null,
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        color: ColorsPalette.redComponents,
                        size: 28.0,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _locationLoading
                              ? 'Buscando localização...'
                              : _locationDenied
                                  ? 'Toque para ativar localização'
                                  // Permissão ok mas sem endereço legível
                                  // (ex: web, onde o geocoding não roda).
                                  : _locationLabel ?? 'Localização ativa',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.titulo(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CategoryFilterChips(
                filtros: _filtrosMapa,
                ativo: _filtroAtivo,
                onSelect: (filtro) => setState(() => _filtroAtivo = filtro),
              ),
            ],
          ),
        ),
        Expanded(child: _buildConteudo()),
      ],
    );
  }

  Widget _buildConteudo() {
    if (_isLoadingLojas) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsPalette.redComponents),
      );
    }
    return NearbyStoresSection(
      stores: _lojasFiltradas,
      initialLatitude: _userLatitude,
      initialLongitude: _userLongitude,
    );
  }
}
