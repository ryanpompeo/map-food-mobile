import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/widgets/category_filter_chips.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/guest/presentation/pages/guest_profile_page.dart';
import 'package:map_food/features/guest/presentation/widgets/floating_bottom_bar.dart';
import 'package:map_food/features/search/presentation/pages/search_page.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/nearby_stores_section.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  int _selectedIndex = 0;

  String _filtroAtivo = 'Todos';

  final _categoriaService = CategoriaService();
  List<CategoriaModel> _categorias = [];

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
    _carregarCategorias();
    _carregarLojas();
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {
      // Mantém apenas "Todos" se a API estiver indisponível.
    }
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

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildAbaInicio(),
              const SearchPage(),
              const GuestProfilePage(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingBottomBar(
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
    return NearbyStoresSection(stores: _lojasFiltradas);
  }
}
