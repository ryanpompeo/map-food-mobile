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
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/widgets/home_filter_modal.dart';
import 'package:map_food/features/store/presentation/widgets/map_controls.dart';
import 'package:map_food/features/store/presentation/widgets/nearby_stores_section.dart';

/// Aba "Início" de guest, consumidor e comerciante: o mapa em tela cheia.
///
/// Sobre o mapa flutuam apenas a busca/filtro, a faixa de categorias e os
/// controles de câmera. O painel arrastável de "comércios próximos" que
/// existia aqui foi removido: o mapa com os pins já é a lista, e a busca
/// continua sendo o caminho para ver os comércios em formato de lista.
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
  String _categoriaAtiva = 'Todos';
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
      // Sem categorias carregadas, a home continua funcionando só com
      // "Todos" — o filtro é um atalho, não um requisito para ver o mapa.
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

  /// Só a posição do usuário interessa aqui — é o que o botão de recentralizar
  /// precisa. A lista de lojas no raio fica com o mapa.
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

        // Véu no topo: garante contraste da busca sobre qualquer tile —
        // telhado branco, praça clara, área de mata escura.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          // Cobre busca + faixa de categorias.
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
        // O filtro é aplicado DENTRO do builder, e não no build do State: aqui
        // ele lê a lista no mesmo instante em que reage à notificação do
        // manager. Calculado lá fora, o valor ficava preso na closure da
        // primeira montagem (quase sempre vazia) e o mapa só saía do vazio de
        // carona num setState de outra origem — com GPS negado, nunca.
        final lojas = _categoriaAtiva == 'Todos'
            ? manager.stores
            : manager.stores
                .where((l) => l.categoriaNomes.contains(_categoriaAtiva))
                .toList();

        return NearbyStoresSection(
          stores: lojas,
          initialLatitude: widget.initialLatitude,
          initialLongitude: widget.initialLongitude,
          raioKm: _raioKm,
          mapController: _mapController,
          onNearbyChanged: _onNearbyChanged,
          // Os controles vivem fora do mapa nesta tela, ancorados acima da
          // bottom bar flutuante do app.
          showFloatingControls: false,
          // O banner de "sem lojas" colidia com a barra de busca flutuante.
          showEmptyBanner: false,
        );
      },
    );
  }

  /// Busca + filtro num único pill flutuante, com sombra de nível 2 (a de
  /// "flutua sobre outro conteúdo") e superfície do tema — nunca branco
  /// literal, que sumiria no tema escuro.
  Widget _buildBarraBusca() {
    return Container(
      // Altura mínima: a barra vive numa Column dentro de SafeArea, então tem
      // para onde crescer quando a fonte do sistema aumenta.
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
                  // Decorativo: o rótulo da área de toque já diz "Buscar".
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
            hint: 'Escolhe categoria e distância',
            onTap: _abrirFiltros,
            child: Container(
              height: 44.0,
              width: 44.0,
              decoration: const BoxDecoration(color: MfColor.brand, shape: BoxShape.circle),
              child: const Icon(AppIcons.slidersHorizontal, color: ColorsPalette.white, size: AppIconSize.md),
            ),
          ),
        ],
      ),
    );
  }

  /// Faixa de categorias sobre o mapa. Cada pílula se recorta da cartografia
  /// pelo fundo opaco + borda do próprio [AppChoiceChip], reforçados pelo véu
  /// em gradiente que cobre esta faixa — sem sombra.
  ///
  /// Teto de escala da faixa de categorias. Ela é uma tira horizontal
  /// flutuando **sobre o mapa**: diferente da barra de busca, não tem para
  /// onde crescer — cada ponto a mais de altura é um ponto a menos de mapa
  /// visível, que é o conteúdo principal desta tela. Acima de 1,5× a faixa
  /// passaria a competir com o próprio mapa.
  static const double _tetoEscalaChips = 1.5;

  Widget _buildChipsCategoria() {
    if (_categorias.isEmpty) return const SizedBox.shrink();
    final nomes = ['Todos', ..._categorias.map((c) => c.nome)];

    // O teto entra nos dois lugares de propósito: na altura da faixa e na
    // escala do texto dentro dela. Limitar só um dos dois é o que produz ou
    // texto cortado (faixa parada, texto crescendo) ou faixa com sobra
    // (faixa crescendo, texto parado).
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
            // Sem sombra. A pílula já se recorta da cartografia pelo fundo
            // opaco + borda do próprio AppChoiceChip, e o véu em gradiente
            // logo acima cobre justamente esta faixa. A sombra que existia
            // aqui só empilhava um halo escuro atrás de cada chip — visível
            // como sujeira entre um chip e outro, não como profundidade.
            return AppChoiceChip(
              label: nome,
              selected: nome == _categoriaAtiva,
              onTap: () => setState(() => _categoriaAtiva = nome),
            );
          },
        ),
      ),
    );
  }

  /// Controles de câmera ancorados acima da bottom bar flutuante — sem isso
  /// eles nasceriam atrás dela.
  Widget _buildControlesDeCamera(BuildContext context) {
    return Positioned(
      right: Spacing.lg,
      // Acima da bottom bar fixa, incluindo a área segura do aparelho — a
      // barra agora encosta na borda inferior da tela.
      bottom: AppBottomBar.spaceFor(context) + Spacing.base,
      child: Column(
        children: [
          // Ampliar/reduzir por toque: nesta tela o mapa ocupa a tela inteira
          // e a pinça era a única forma de mudar o zoom.
          MapZoomControls(controller: _mapController),
          const SizedBox(height: Spacing.sm),
          // Trava de rotação: vive aqui (e não dentro do mapa) porque os
          // controles internos do StoreMapView estão desligados nesta tela.
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
            // Sem posição ainda, o botão é anunciado como desabilitado em vez
            // de aceitar o toque e não fazer nada.
            onTap: _posicaoUsuario == null ? null : _centralizarNoUsuario,
          ),
        ],
      ),
    );
  }
}
