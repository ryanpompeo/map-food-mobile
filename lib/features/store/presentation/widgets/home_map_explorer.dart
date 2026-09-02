import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/widgets/home_filter_modal.dart';
import 'package:map_food/features/store/presentation/widgets/map_controls.dart';
import 'package:map_food/features/store/presentation/widgets/nearby_stores_section.dart';

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
  final _mapController = StoreMapController();

  List<CategoriaModel> _categorias = [];

  final Set<String> _categoriasAtivas = {};

  double? _raioKm = 5.0;

  LatLng? _posicaoUsuario;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {
    }
  }

  Future<void> _abrirFiltros() async {
    final resultado = await showHomeFilterModal(
      context,
      categorias: _categorias,
      categoriasAtivas: _categoriasAtivas,
      raioAtivo: _raioKm,
    );
    if (resultado != null && mounted) {
      setState(() {
        _categoriasAtivas
          ..clear()
          ..addAll(resultado.categorias);
        _raioKm = resultado.raioKm;
      });
    }
  }

  void _alternarCategoria(String nome) {
    if (nome == 'Todos') {
      setState(_categoriasAtivas.clear);
      return;
    }
    if (_categoriasAtivas.contains(nome)) {
      setState(() => _categoriasAtivas.remove(nome));
      return;
    }
    if (_categoriasAtivas.length >= maxCategoriasFiltro) {
      AppToast.warning(
        context,
        'Você pode combinar até $maxCategoriasFiltro categorias.',
      );
      return;
    }
    setState(() => _categoriasAtivas.add(nome));
  }

  void _onNearbyChanged(List<StoreDto> lojas, LatLng? posicao) {
    if (posicao == _posicaoUsuario) return;
    setState(() => _posicaoUsuario = posicao);
  }

  void _centralizarNoUsuario() {
    final posicao = _posicaoUsuario;
    if (posicao == null) return;
    _mapController.centralizarNoUsuario(
      posicao,
      alturaVisivel: MediaQuery.sizeOf(context).height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _buildMapa()),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 210,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.mapColors.background.withValues(alpha: 0.92),
                    context.mapColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, 0),
                  child: _buildBarraBusca(),
                ),
                const SizedBox(height: Spacing.md),
                _buildChipsCategoria(),
              ],
            ),
          ),
        ),

        _buildControlesDeCamera(context),
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
            child: CircularProgressIndicator(color: MfColor.brand),
          );
        }
        final lojas = _categoriasAtivas.isEmpty
            ? manager.stores
            : manager.stores
                .where((l) => l.categoriaNomes.any(_categoriasAtivas.contains))
                .toList();

        return NearbyStoresSection(
          stores: lojas,
          initialLatitude: widget.initialLatitude,
          initialLongitude: widget.initialLongitude,
          raioKm: _raioKm,
          mapController: _mapController,
          onNearbyChanged: _onNearbyChanged,
          showFloatingControls: false,
          showEmptyBanner: false,
        );
      },
    );
  }

  Widget _buildBarraBusca() {
    return Container(
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.only(left: Spacing.base, right: 4.0),
      decoration: BoxDecoration(
        color: context.mapColors.surface,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: context.mapColors.border),
        boxShadow: AppElevation.floating,
      ),
      child: Row(
        children: [
          Expanded(
            child: SemanticTapArea(
              label: 'Buscar comércios',
              hint: 'Abre a busca por nome',
              onTap: widget.onSearchTap,
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(AppIcons.magnifyingGlass, color: context.mapColors.textTertiary, size: AppIconSize.md),
                  ),
                  const SizedBox(width: Spacing.md),
                  Text(
                    'Buscar comércios...',
                    style: AppText.body(context).copyWith(color: context.mapColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          SemanticTapArea(
            label: 'Filtros',
            hint: _categoriasAtivas.isEmpty
                ? 'Escolhe categoria e distância'
                : '${_categoriasAtivas.length} de $maxCategoriasFiltro categorias selecionadas',
            onTap: _abrirFiltros,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 44.0,
                  width: 44.0,
                  decoration: const BoxDecoration(color: MfColor.brand, shape: BoxShape.circle),
                  child: const Icon(AppIcons.slidersHorizontal, color: ColorsPalette.white, size: AppIconSize.md),
                ),
                if (_categoriasAtivas.isNotEmpty)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      height: 18.0,
                      width: 18.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.mapColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: MfColor.brand, width: 1.5),
                      ),
                      child: Text(
                        '${_categoriasAtivas.length}',
                        style: AppText.legenda(context).copyWith(
                          fontSize: 10.0,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          color: context.mapColors.brandContent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const double _tetoEscalaChips = 1.5;

  Widget _buildChipsCategoria() {
    if (_categorias.isEmpty) return const SizedBox.shrink();
    final nomes = ['Todos', ..._categorias.map((c) => c.nome)];

    return MaxTextScale(
      max: _tetoEscalaChips,
      child: SizedBox(
        height: escalaComTeto(context, 38, teto: _tetoEscalaChips),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          itemCount: nomes.length,
          separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
          itemBuilder: (context, index) {
            final nome = nomes[index];
            return AppChoiceChip(
              label: nome,
              selected: nome == 'Todos'
                  ? _categoriasAtivas.isEmpty
                  : _categoriasAtivas.contains(nome),
              onTap: () => _alternarCategoria(nome),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlesDeCamera(BuildContext context) {
    return Positioned(
      right: Spacing.lg,
      bottom: AppBottomBar.spaceFor(context) + Spacing.base,
      child: Column(
        children: [
          MapZoomControls(controller: _mapController),
          const SizedBox(height: Spacing.sm),
          ValueListenableBuilder<bool>(
            valueListenable: _mapController.rotacaoTravada,
            builder: (context, travada, _) => MapControlButton(
              icon: travada ? AppIcons.lock : AppIcons.compass,
              tooltip: travada ? 'Destravar rotação do mapa' : 'Travar rotação do mapa',
              isActive: travada,
              onTap: _mapController.alternarTravaDeRotacao,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          MapControlButton(
            icon: AppIcons.gpsFix,
            tooltip: 'Centralizar na minha posição',
            onTap: _posicaoUsuario == null ? null : _centralizarNoUsuario,
          ),
        ],
      ),
    );
  }
}
