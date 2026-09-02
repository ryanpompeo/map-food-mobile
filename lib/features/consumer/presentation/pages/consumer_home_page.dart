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

  final ValueNotifier<int> _abaAtual = ValueNotifier(0);

  String _userName = '';
  String _userEmail = '';
  int _profileRefreshToken = 0;

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

  void _loadSession() {
    final session = SessionStore.instance.value;
    _userName = session?.nome ?? '';
    _userEmail = session?.email ?? '';

    unawaited(FavoritesManager.instance.load());
  }

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

    final abas = [
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
