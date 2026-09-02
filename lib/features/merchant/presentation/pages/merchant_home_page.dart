import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/utils/async_load_mixin.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/core/ui/widgets/keyboard_aware_bottom_bar.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/analytics/presentation/pages/merchant_analytics_page.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_store_page.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_profile_page.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/merchant/presentation/widgets/merchant_bottom_bar.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';
import 'package:map_food/features/store/presentation/widgets/home_map_explorer.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_switcher_bar.dart';

class MerchantHomePage extends StatefulWidget {
  const MerchantHomePage({super.key});

  @override
  State<MerchantHomePage> createState() => _MerchantHomePageState();
}

class _MerchantHomePageState extends State<MerchantHomePage>
    with AsyncLoadMixin<List<StoreDto>, MerchantHomePage> {
  final ValueNotifier<int> _abaAtual = ValueNotifier(0);

  static const int _indiceEstatisticas = 1;

  final ValueNotifier<bool> _estatisticasVisivel = ValueNotifier(false);

  String _userName = '';
  String _userEmail = '';
  int _profileRefreshToken = 0;
  int _lojaSelecionadaIndex = 0;

  final _storeService = StoreService();

  @override
  String get genericErrorMessage => 'Erro ao carregar dados da loja.';

  @override
  void initState() {
    super.initState();
    asyncState = const AsyncState.loading();
    _loadData();
  }

  void _onProfileUpdated() {
    final session = SessionStore.instance.value;
    setState(() {
      _userName = session?.nome ?? '';
      _userEmail = session?.email ?? '';
      _profileRefreshToken++;
    });
  }

  Future<void> _loadData() async {
    final session = SessionStore.instance.value;

    setState(() {
      _userName = session?.nome ?? '';
      _userEmail = session?.email ?? '';
    });

    if (session == null) {
      setState(() => asyncState = const AsyncState(data: []));
      return;
    }

    await load(
      () => _storeService.getByMerchant(session.id),
      onData: (stores) {
        if (stores.isEmpty) {
          Navigator.pushReplacement(
            context,
            appPageRoute(builder: (_) => const StoreRegisterPage()),
          );
          return false;
        }
        if (_lojaSelecionadaIndex >= stores.length) {
          setState(() => _lojaSelecionadaIndex = 0);
        }
        return true;
      },
    );
  }

  void _onItemTapped(int index) {
    if (_abaAtual.value == index) return;
    _abaAtual.value = index;
    _estatisticasVisivel.value = index == _indiceEstatisticas;
  }

  void _abrirBusca() {
    Navigator.push(
      context,
      appPageRoute(
        builder: (context) => SearchPage(onVoltar: () => Navigator.pop(context)),
      ),
    );
  }

  @override
  void dispose() {
    _abaAtual.dispose();
    _estatisticasVisivel.dispose();
    super.dispose();
  }

  void _onStoreUpdated(StoreDto atualizada) {
    final stores = asyncState.data;
    if (stores == null) return;
    final index = stores.indexWhere((s) => s.id == atualizada.id);
    if (index == -1) return;
    final atualizadas = List<StoreDto>.from(stores)..[index] = atualizada;
    setState(() => asyncState = AsyncState(data: atualizadas));
  }

  @override
  Widget build(BuildContext context) {
    if (asyncState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final errorMessage = asyncState.errorMessage;
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: EmptyState(
            icon: AppIcons.wifiSlash,
            title: 'Não foi possível carregar',
            description: errorMessage,
            actionLabel: 'Tentar novamente',
            onAction: _loadData,
            tone: EmptyStateTone.error,
          ),
        ),
      );
    }

    final stores = asyncState.data ?? const <StoreDto>[];
    if (stores.isEmpty) {
      return Scaffold(
        body: Center(
          child: EmptyState(
            icon: AppIcons.storefront,
            title: 'Nenhuma loja disponível',
            description: 'Faça login novamente para acessar suas lojas.',
            actionLabel: 'Tentar novamente',
            onAction: _loadData,
          ),
        ),
      );
    }

    final store = stores[_lojaSelecionadaIndex.clamp(0, stores.length - 1)];
    final switcher = StoreSwitcherBar(
      stores: stores,
      selectedIndex: _lojaSelecionadaIndex,
      onSelect: (index) => setState(() => _lojaSelecionadaIndex = index),
    );

    final abas = [
      RepaintBoundary(
        child: HomeMapExplorer(onSearchTap: _abrirBusca),
      ),
      RepaintBoundary(
        child: MerchantAnalyticsPage(lojas: stores, visivel: _estatisticasVisivel),
      ),
      RepaintBoundary(
        child: MerchantStorePage(
          store: store,
          storeSwitcher: switcher,
          onStoreUpdated: _onStoreUpdated,
          onStoreDeleted: _loadData,
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
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.mapColors.mainBackground,
      body: Stack(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _abaAtual,
            builder: (context, index, _) => IndexedStack(index: index, children: abas),
          ),
          KeyboardAwareBottomBar(
            child: ValueListenableBuilder<int>(
              valueListenable: _abaAtual,
              builder: (context, index, _) => MerchantBottomBar(
                selectedIndex: index,
                onItemTapped: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
