import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/category_filter_chips.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/merchant_dashboard.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_profile_page.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/merchant/presentation/widgets/merchant_bottom_bar.dart';
import 'package:map_food/features/store/presentation/pages/working_page.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/widgets/nearby_stores_section.dart';
import 'package:map_food/features/store/presentation/widgets/store_switcher_bar.dart';

class MerchantHomePage extends StatefulWidget {
  const MerchantHomePage({super.key});

  @override
  State<MerchantHomePage> createState() => _MerchantHomePageState();
}

class _MerchantHomePageState extends State<MerchantHomePage> {
  int _selectedIndex = 0;
  String _filtroAtivo = 'Todos';

  String _userName = '';
  String _userEmail = '';
  // Muda a cada edição de perfil salva, forçando o MerchantProfilePage a
  // remontar (novo nome/e-mail/foto) em vez de continuar com os dados
  // carregados na primeira vez que a aba foi aberta.
  int _profileRefreshToken = 0;
  List<StoreDto> _stores = [];
  int _lojaSelecionadaIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  final _storeService = StoreService();
  final _categoriaService = CategoriaService();
  List<CategoriaModel> _categorias = [];

  List<String> get _filtrosMapa => ['Todos', ..._categorias.map((c) => c.nome)];

  @override
  void initState() {
    super.initState();
    _loadData();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {
      // Mantém apenas "Todos" se a API estiver indisponível.
    }
  }

  /// Chamado ao voltar da tela de Editar Perfil — recarrega só nome/e-mail
  /// da sessão (sem repetir o fluxo de `_loadData`, que também busca lojas e
  /// pode redirecionar) e força o MerchantProfilePage a remontar via key,
  /// pra também buscar a foto de novo.
  Future<void> _onProfileUpdated() async {
    final session = await AuthStorage.getSession();
    if (!mounted) return;
    setState(() {
      _userName = session?.nome ?? '';
      _userEmail = session?.email ?? '';
      _profileRefreshToken++;
    });
  }

  Future<void> _loadData() async {
    final session = await AuthStorage.getSession();
    if (!mounted) return;

    setState(() {
      _userName = session?.nome ?? '';
      _userEmail = session?.email ?? '';
    });

    if (session == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final stores = await _storeService.getByMerchant(session.id);

      if (!mounted) return;

      if (stores.isEmpty) {
        // Sem loja cadastrada → redireciona obrigatoriamente para criação
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StoreRegisterPage()),
        );
        return;
      }

      setState(() {
        _stores = stores;
        if (_lojaSelecionadaIndex >= _stores.length) _lojaSelecionadaIndex = 0;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados da loja.';
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  /// Mantém `_stores` em dia quando uma tela filha altera a loja no backend
  /// (toggle aberta/fechada, edição, posição da ronda) — sem isso, trocar de
  /// loja no switcher e voltar remontava a tela com o dado velho do boot,
  /// parecendo que a alteração não persistiu.
  void _onStoreUpdated(StoreDto atualizada) {
    final index = _stores.indexWhere((s) => s.id == atualizada.id);
    if (index == -1) return;
    setState(() => _stores[index] = atualizada);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.wifiOff,
                  size: 48,
                  color: ColorsPalette.greyText,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppText.corpo(context)
                      .copyWith(color: ColorsPalette.greyText),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final store = _stores[_lojaSelecionadaIndex];
    final switcher = StoreSwitcherBar(
      stores: _stores,
      selectedIndex: _lojaSelecionadaIndex,
      onSelect: (index) => setState(() => _lojaSelecionadaIndex = index),
    );

    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildAbaInicio(),
              const SearchPage(),
              WorkingPage(
                key: ValueKey('working-${store.id}'),
                store: store,
                storeSwitcher: switcher,
                onStoreUpdated: _onStoreUpdated,
              ),
              MerchantDashboard(
                key: ValueKey('dashboard-${store.id}'),
                store: store,
                storeSwitcher: switcher,
                onStoreUpdated: _onStoreUpdated,
              ),
              MerchantProfilePage(
                key: ValueKey('profile-$_profileRefreshToken'),
                userName: _userName,
                userEmail: _userEmail,
                onProfileUpdated: _onProfileUpdated,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MerchantBottomBar(
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
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      color: ColorsPalette.redComponents,
                      size: 28.0,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'MapFood',
                      style: AppText.titulo(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
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
        Expanded(
          child: ListenableBuilder(
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
              return NearbyStoresSection(stores: lojas);
            },
          ),
        ),
      ],
    );
  }
}
