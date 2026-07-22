import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_dashboard.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_profile_page.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/merchant/presentation/widgets/merchant_bottom_bar.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_working_page.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';
import 'package:map_food/features/store/presentation/widgets/home_map_explorer.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_switcher_bar.dart';

class MerchantHomePage extends StatefulWidget {
  const MerchantHomePage({super.key});

  @override
  State<MerchantHomePage> createState() => _MerchantHomePageState();
}

class _MerchantHomePageState extends State<MerchantHomePage> {
  int _selectedIndex = 0;

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

  @override
  void initState() {
    super.initState();
    _loadData();
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
          appPageRoute(builder: (_) => const StoreRegisterPage()),
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
                Icon(
                  PhosphorIconsRegular.wifiSlash,
                  size: 48,
                  color: context.mapColors.iconMuted,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppText.corpo(context)
                      .copyWith(color: context.mapColors.secondaryText),
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

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.mapColors.mainBackground,
      body: Stack(
        children: [
          // RepaintBoundary em cada aba: sem isso, o Stack/Compositor trata a
          // troca de aba do IndexedStack como parte do mesmo layer de pintura
          // das outras abas (mesmo as invisíveis) — isolando cada uma, a troca
          // vira só uma questão de qual layer já pronto mostrar, sem repintar
          // o mapa/formulários das abas que não mudaram.
          IndexedStack(
            index: _selectedIndex,
            children: [
              RepaintBoundary(
                child: HomeMapExplorer(onSearchTap: () => _onItemTapped(1)),
              ),
              const RepaintBoundary(child: SearchPage()),
              RepaintBoundary(
                child: MerchantWorkingPage(
                  key: ValueKey('working-${store.id}'),
                  store: store,
                  storeSwitcher: switcher,
                  onStoreUpdated: _onStoreUpdated,
                ),
              ),
              RepaintBoundary(
                child: MerchantDashboard(
                  key: ValueKey('dashboard-${store.id}'),
                  store: store,
                  storeSwitcher: switcher,
                  onStoreUpdated: _onStoreUpdated,
                ),
              ),
              RepaintBoundary(
                child: MerchantProfilePage(
                  key: ValueKey('profile-$_profileRefreshToken'),
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
              child: MerchantBottomBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
