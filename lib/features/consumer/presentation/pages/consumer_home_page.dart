import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/category_filter_chips.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_profile_page.dart';
import 'package:map_food/features/consumer/presentation/widgets/consumer_bottom_bar.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
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
  // Muda a cada edição de perfil salva, forçando o ConsumerProfilePage a
  // remontar (novo nome/e-mail/foto) em vez de continuar com os dados
  // carregados na primeira vez que a aba foi aberta.
  int _profileRefreshToken = 0;

  final _categoriaService = CategoriaService();
  List<CategoriaModel> _categorias = [];

  final _locationService = LocationService();
  String? _locationLabel;
  double? _userLatitude;
  double? _userLongitude;
  bool _locationLoading = true;
  bool _locationDenied = false;

  List<String> get _filtrosMapa => ['Todos', ..._categorias.map((c) => c.nome)];

  @override
  void initState() {
    super.initState();
    _loadSession();
    _carregarCategorias();
    _loadLocation();
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

  /// Chamado ao voltar da tela de Editar Perfil — recarrega nome/e-mail da
  /// sessão e força o ConsumerProfilePage a remontar (via troca de key) pra
  /// também buscar a foto de novo, já que o card não se atualiza sozinho.
  Future<void> _onProfileUpdated() async {
    await _loadSession();
    if (mounted) setState(() => _profileRefreshToken++);
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

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorsPalette.whiteBackground,
      body: Stack(
        children: [
          // RepaintBoundary em cada aba: isola o layer de pintura de cada uma
          // — a troca de aba passa a ser só trocar qual layer já pronto
          // mostrar, sem repintar o mapa/formulário das abas que não mudaram.
          IndexedStack(
            index: _selectedIndex,
            children: [
              RepaintBoundary(child: _buildAbaInicio()),
              const RepaintBoundary(child: SearchPage()),
              RepaintBoundary(
                child: ConsumerProfilePage(
                  key: ValueKey(_profileRefreshToken),
                  userName: _userName,
                  userEmail: _userEmail,
                  onProfileUpdated: _onProfileUpdated,
                ),
              ),
            ],
          ),
          // resizeToAvoidBottomInset:false trava o Stack no lugar (a barra
          // não "sobe" agarrada ao teclado); esse Slide é o que dá a saída
          // suave por baixo da tela ao focar um campo, estilo iFood.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: keyboardVisible ? const Offset(0, 1) : Offset.zero,
              child: ConsumerBottomBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
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
                        PhosphorIconsRegular.mapPin,
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
        // Respiro entre o cabeçalho (que tem boxShadow própria) e o conteúdo
        // abaixo — sem isso, a sombra do cabeçalho caía direto em cima dos
        // chips de km/categoria do NearbyStoresSection, dando a impressão de
        // um sombreado "grudado" neles que não é deles.
        const SizedBox(height: 8),
        Expanded(child: _buildConteudo()),
      ],
    );
  }

  Widget _buildConteudo() {
    return ListenableBuilder(
      listenable: ActiveStoresManager.instance,
      builder: (context, _) {
        final manager = ActiveStoresManager.instance;
        if (manager.isLoading && manager.stores.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ColorsPalette.redComponents),
          );
        }
        final lojas = _filtroAtivo == 'Todos'
            ? manager.stores
            : manager.stores.where((l) => l.categoriaNomes.contains(_filtroAtivo)).toList();
        return NearbyStoresSection(
          stores: lojas,
          initialLatitude: _userLatitude,
          initialLongitude: _userLongitude,
        );
      },
    );
  }
}
