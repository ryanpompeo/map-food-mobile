import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/keyboard_aware_bottom_bar.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_profile_page.dart';
import 'package:map_food/features/consumer/presentation/widgets/consumer_bottom_bar.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/store/presentation/widgets/home_map_explorer.dart';

class ConsumerHomePage extends StatefulWidget {
  const ConsumerHomePage({super.key});

  @override
  State<ConsumerHomePage> createState() => _ConsumerHomePage();
}

class _ConsumerHomePage extends State<ConsumerHomePage> {
  static const int _indicePerfil = 2;

  /// Aba exibida. `ValueNotifier` e não um campo com `setState`: trocar de aba
  /// não muda mais **nada** nesta página além de qual filho o `IndexedStack`
  /// mostra, e um `setState` aqui reconstruiria o `build` inteiro — recriando
  /// as instâncias de `HomeMapExplorer`, `SearchPage` e `ConsumerProfilePage`.
  /// Widget recriado não é idêntico ao anterior, então o Flutter desce a
  /// árvore e reconstrói o mapa com todos os pins a cada toque na barra. Com o
  /// notifier, a lista de abas é construída uma vez por build da página, as
  /// instâncias são as mesmas, e `Element.updateChild` corta o trabalho por
  /// identidade.
  final ValueNotifier<int> _abaAtual = ValueNotifier(0);

  String _userName = '';
  String _userEmail = '';
  // Muda a cada edição de perfil salva, forçando o ConsumerProfilePage a
  // remontar (novo nome/e-mail/foto) em vez de continuar com os dados
  // carregados na primeira vez que a aba foi aberta.
  int _profileRefreshToken = 0;

  /// Avisa o perfil quando ele passa a ser a aba exibida. O IndexedStack
  /// constrói as três abas de uma vez e nunca as descarta, então o `initState`
  /// do perfil roda no login e nunca mais — sem esse aviso, a Atividade fica
  /// congelada no retrato daquele momento. `ValueNotifier` e não `setState`
  /// porque só o perfil precisa reagir a isso.
  final ValueNotifier<bool> _perfilVisivel = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _abaAtual.dispose();
    _perfilVisivel.dispose();
    super.dispose();
  }

  /// Lê a sessão do [SessionStore] — síncrono, já hidratado no `main()`.
  /// Antes era um `await AuthStorage.getSession()`, e a tela precisava mostrar
  /// um spinner de página inteira (`_sessionLoaded`) enquanto o disco
  /// respondia, só para descobrir o próprio nome do usuário.
  void _loadSession() {
    final session = SessionStore.instance.value;
    _userName = session?.nome ?? '';
    _userEmail = session?.email ?? '';

    // Fire-and-forget explícito: `load()` já converte falha em `errorMessage`
    // observável (ver FavoritesManager), então não há nada a aguardar aqui —
    // mas a intenção precisa estar escrita, não implícita.
    unawaited(FavoritesManager.instance.load());
  }

  /// Chamado ao voltar da tela de Editar Perfil — relê nome/e-mail da sessão e
  /// força o ConsumerProfilePage a remontar (via troca de key) pra também
  /// buscar a foto de novo, já que o card não se atualiza sozinho.
  void _onProfileUpdated() {
    setState(() {
      final session = SessionStore.instance.value;
      _userName = session?.nome ?? '';
      _userEmail = session?.email ?? '';
      _profileRefreshToken++;
    });
  }

  void _onItemTapped(int index) {
    if (_abaAtual.value == index) return;
    _abaAtual.value = index;
    _perfilVisivel.value = index == _indicePerfil;
  }

  @override
  Widget build(BuildContext context) {
    // O guard `_sessionLoaded` (spinner de página inteira) saiu: a sessão já
    // está em memória desde o `main()`, então a home nasce pronta.

    // Construída **fora** do ValueListenableBuilder de propósito: assim as três
    // instâncias sobrevivem à troca de aba e o IndexedStack só troca o índice.
    // Dentro do builder, cada toque na barra recriaria as três e o mapa seria
    // reconstruído do zero.
    final abas = [
      // RepaintBoundary em cada aba: isola o layer de pintura de cada uma
      // — a troca de aba passa a ser só trocar qual layer já pronto
      // mostrar, sem repintar o mapa/formulário das abas que não mudaram.
      RepaintBoundary(
        child: HomeMapExplorer(onSearchTap: () => _onItemTapped(1)),
      ),
      const RepaintBoundary(child: SearchPage()),
      RepaintBoundary(
        child: ConsumerProfilePage(
          key: ValueKey(_profileRefreshToken),
          userName: _userName,
          userEmail: _userEmail,
          onProfileUpdated: _onProfileUpdated,
          onExplorarTap: () => _onItemTapped(1),
          visivel: _perfilVisivel,
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
              builder: (context, index, _) => ConsumerBottomBar(
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
