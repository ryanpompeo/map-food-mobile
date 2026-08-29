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
  /// Aba exibida. `ValueNotifier` e não um campo com `setState`: aqui o
  /// `IndexedStack` tem quatro filhos (mapa, estatísticas, minha loja,
  /// perfil), e um `setState` por toque na barra recriava as quatro instâncias
  /// — o Flutter então descia a árvore inteira, reconstruindo o mapa com os
  /// pins e o dashboard, só pra mudar qual delas fica visível. Ver a mesma
  /// nota, mais longa, em `KeyboardAwareBottomBar`.
  final ValueNotifier<int> _abaAtual = ValueNotifier(0);

  /// Índice da aba de Estatísticas na barra e no `IndexedStack`.
  static const int _indiceEstatisticas = 1;

  /// Avisa a aba de Estatísticas quando ela volta a ser exibida. Ela vive no
  /// `IndexedStack` e nunca é descartada, então o `initState` dela roda uma
  /// vez só — sem este aviso, os números ficariam congelados no momento em
  /// que o app abriu. `ValueNotifier` e não `setState` porque só ela reage.
  final ValueNotifier<bool> _estatisticasVisivel = ValueNotifier(false);

  String _userName = '';
  String _userEmail = '';
  // Muda a cada edição de perfil salva, forçando o MerchantProfilePage a
  // remontar (novo nome/e-mail/foto) em vez de continuar com os dados
  // carregados na primeira vez que a aba foi aberta.
  int _profileRefreshToken = 0;
  int _lojaSelecionadaIndex = 0;

  final _storeService = StoreService();

  @override
  String get genericErrorMessage => 'Erro ao carregar dados da loja.';

  @override
  void initState() {
    super.initState();
    // O trio isLoading/errorMessage/data do AsyncLoadMixin já nasce
    // `isLoading: false` por padrão — força `true` aqui, antes do primeiro
    // build, pra não desenhar um frame de "sem loja" (`data` ainda nulo)
    // enquanto `_loadData` aguarda a sessão local.
    asyncState = const AsyncState.loading();
    _loadData();
  }

  /// Chamado ao voltar da tela de Editar Perfil — recarrega só nome/e-mail
  /// da sessão (sem repetir o fluxo de `_loadData`, que também busca lojas e
  /// pode redirecionar) e força o MerchantProfilePage a remontar via key,
  /// pra também buscar a foto de novo.
  void _onProfileUpdated() {
    final session = SessionStore.instance.value;
    setState(() {
      _userName = session?.nome ?? '';
      _userEmail = session?.email ?? '';
      _profileRefreshToken++;
    });
  }

  Future<void> _loadData() async {
    // Sessão em memória (hidratada no `main()`): nome e e-mail saem daqui sem
    // I/O, e só a busca das lojas continua sendo assíncrona.
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
          // Sem loja cadastrada → redireciona obrigatoriamente para criação.
          // Devolve `false` pra nunca commitar essa lista vazia em
          // `asyncState` — a tela está sendo substituída, não faz sentido
          // ela chegar a renderizar com `stores` vazio antes de sair.
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

  /// A busca deixou de ser aba do comerciante (o lugar virou "Estatísticas") e
  /// passou a ser empurrada pelo botão de busca do mapa. `onVoltar` fecha a
  /// rota — sem ele a página empurrada não teria saída visível, já que a
  /// `SearchPage` não desenha cabeçalho quando é usada como aba.
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

  /// Mantém a lista de lojas em dia quando uma tela filha altera a loja no
  /// backend (toggle aberta/fechada, edição, posição da ronda) — sem isso,
  /// trocar de loja no switcher e voltar remontava a tela com o dado velho
  /// do boot, parecendo que a alteração não persistiu.
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
    // Sem loja e sem redirecionamento em voo: a sessão sumiu entre o `_loadData`
    // e este build (ex: 401 concorrente limpando o AuthStorage). Indexar aqui
    // dava RangeError e tela branca.
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

    // `clamp` como segunda linha de defesa: o índice também pode ficar fora do
    // intervalo se a lista encolher (loja excluída) antes do próximo build.
    final store = stores[_lojaSelecionadaIndex.clamp(0, stores.length - 1)];
    final switcher = StoreSwitcherBar(
      stores: stores,
      selectedIndex: _lojaSelecionadaIndex,
      onSelect: (index) => setState(() => _lojaSelecionadaIndex = index),
    );

    // Construídas **fora** do ValueListenableBuilder: assim as quatro
    // instâncias sobrevivem à troca de aba, e o IndexedStack só troca o
    // índice. Dentro do builder, cada toque na barra recriaria as quatro.
    final abas = [
      // RepaintBoundary em cada aba: sem isso, o Stack/Compositor trata a
      // troca de aba do IndexedStack como parte do mesmo layer de pintura
      // das outras abas (mesmo as invisíveis) — isolando cada uma, a troca
      // vira só uma questão de qual layer já pronto mostrar, sem repintar
      // o mapa/formulários das abas que não mudaram.
      RepaintBoundary(
        child: HomeMapExplorer(onSearchTap: _abrirBusca),
      ),
      RepaintBoundary(
        child: MerchantAnalyticsPage(lojas: stores, visivel: _estatisticasVisivel),
      ),
      RepaintBoundary(
        // Sem `key` por loja: a página resincroniza pelo `didUpdateWidget`, e
        // uma key nova a cada troca de loja remontaria a seção de operação —
        // derrubando a assinatura de GPS da ronda em curso.
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
