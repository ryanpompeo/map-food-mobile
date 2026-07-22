import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/widgets/home_filter_modal.dart';
import 'package:map_food/features/store/presentation/widgets/nearby_stores_section.dart';

/// Aba "Início" de guest, consumidor e comerciante: mapa em tela cheia com
/// uma busca (redireciona pra aba de busca) e um botão de filtro que abre um
/// modal de categoria/distância — substitui o antigo cabeçalho fixo com
/// texto + fileira de chips, que competia por espaço vertical com o mapa.
class HomeMapExplorer extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final VoidCallback onSearchTap;

  const HomeMapExplorer({
    super.key,
    required this.onSearchTap,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<HomeMapExplorer> createState() => _HomeMapExplorerState();
}

class _HomeMapExplorerState extends State<HomeMapExplorer> {
  final _categoriaService = CategoriaService();
  List<CategoriaModel> _categorias = [];

  String _categoriaAtiva = 'Todos';
  double? _raioKm = 5.0;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {
      // Sem categorias carregadas, o modal continua funcionando só com "Todos".
    }
  }

  Future<void> _abrirFiltros() async {
    final resultado = await showHomeFilterModal(
      context,
      categorias: _categorias,
      categoriaAtiva: _categoriaAtiva,
      raioAtivo: _raioKm,
    );
    if (resultado != null && mounted) {
      setState(() {
        _categoriaAtiva = resultado.categoria;
        _raioKm = resultado.raioKm;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // fit: StackFit.expand — sem isso, o Stack se dimensiona pelo maior filho
    // NÃO posicionado (aqui, a barra de busca) em vez de preencher a tela,
    // e o mapa em Positioned.fill fica espremido nessa altura pequena.
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _buildMapa()),
        // Positioned (não um filho solto) pra não ser esticada pelo
        // StackFit.expand acima — fica presa no topo com altura natural.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: _buildBarraBusca()),
                  const SizedBox(width: 10.0),
                  _buildBotaoFiltro(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapa() {
    return ListenableBuilder(
      listenable: ActiveStoresManager.instance,
      builder: (context, _) {
        final manager = ActiveStoresManager.instance;
        if (manager.isLoading && manager.stores.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ColorsPalette.redComponents),
          );
        }
        final lojas = _categoriaAtiva == 'Todos'
            ? manager.stores
            : manager.stores.where((l) => l.categoriaNomes.contains(_categoriaAtiva)).toList();
        return NearbyStoresSection(
          stores: lojas,
          initialLatitude: widget.initialLatitude,
          initialLongitude: widget.initialLongitude,
          raioKm: _raioKm,
        );
      },
    );
  }

  Widget _buildBarraBusca() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Container(
        height: 48.0,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          // Elemento flutuante sobre o mapa — sempre cardSurface, nunca
          // Colors.white literal (ver Lote 4B).
          color: context.mapColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsRegular.magnifyingGlass, color: context.mapColors.iconMuted, size: 20.0),
            const SizedBox(width: 10.0),
            Text(
              'Buscar lojas...',
              style: TextStyle(color: context.mapColors.secondaryText, fontSize: 15.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoFiltro() {
    return GestureDetector(
      onTap: _abrirFiltros,
      child: Container(
        height: 48.0,
        width: 48.0,
        decoration: BoxDecoration(
          color: context.mapColors.cardSurface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(PhosphorIconsRegular.slidersHorizontal, color: ColorsPalette.redComponents),
      ),
    );
  }
}
