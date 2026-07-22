import 'package:flutter/material.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
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
  int _selectedIndex = 0;

  String _userName = '';
  String _userEmail = '';
  bool _sessionLoaded = false;
  // Muda a cada edição de perfil salva, forçando o ConsumerProfilePage a
  // remontar (novo nome/e-mail/foto) em vez de continuar com os dados
  // carregados na primeira vez que a aba foi aberta.
  int _profileRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _loadSession();
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
      backgroundColor: context.mapColors.mainBackground,
      body: Stack(
        children: [
          // RepaintBoundary em cada aba: isola o layer de pintura de cada uma
          // — a troca de aba passa a ser só trocar qual layer já pronto
          // mostrar, sem repintar o mapa/formulário das abas que não mudaram.
          IndexedStack(
            index: _selectedIndex,
            children: [
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
}
