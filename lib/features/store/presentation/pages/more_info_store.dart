import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/favorites/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/store_map_page.dart';
import 'package:map_food/features/store/presentation/widgets/store_gallery_viewer.dart';

class MoreInfoStorePage extends StatefulWidget {
  final StoreDto store;

  const MoreInfoStorePage({super.key, required this.store});

  @override
  State<MoreInfoStorePage> createState() => _MoreInfoStorePageState();
}

class _MoreInfoStorePageState extends State<MoreInfoStorePage> {
  final AvaliacaoService _avaliacaoService = AvaliacaoService();
  final StoreService _storeService = StoreService();

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoadingRatings = true;
  String? _ratingsError;

  /// Papel do usuário, lido do [SessionStore] — síncrono, sem I/O e sem
  /// `setState`. Antes vinha de um `AuthStorage.getSession()` no `initState`
  /// que reconstruía esta página inteira (capa, galeria, avaliações) só para
  /// escrever uma string — e que carregava junto um `_userName` nunca usado.
  String get _userRole => SessionStore.instance.role;

  // Filtro por estrelas na lista de avaliações — null significa "todas". A
  // API sempre devolve a lista completa; o filtro é só client-side.
  int? _filtroEstrelas;

  // Recolhe/expande a lista de avaliações + os chips de filtro juntos,
  // mantendo o cabeçalho (título, contagem, nota média) sempre visível —
  // começa expandida pra não mudar o comportamento visual atual por padrão.
  bool _avaliacoesExpandidas = true;

  // Agregação de avaliação vinda do backend (Fase 4) — não é mais calculada
  // no cliente. Começa com o que já veio em `widget.store` (pode já estar
  // populado se a tela de origem usou /mobile/api/v1/lojas) e é atualizada
  // com o dado mais fresco assim que a busca abaixo responde.
  double? _mediaAvaliacao;

  // Guard de "sair sem salvar": true enquanto o usuário tiver nota/comentário
  // digitados no ConsumerReviewWidget sem enviar — a página inteira precisa
  // saber disso porque o widget de avaliação é só uma seção dela, não uma
  // tela própria. ValueNotifier (não bool + setState) pra não reconstruir a
  // página inteira (galeria, avaliações, mapa) a cada tecla digitada na
  // avaliação — o rebuild fica isolado no UnsavedChangesGuard.
  final ValueNotifier<bool> _hasUnsavedReview = ValueNotifier(false);

  void _onReviewUnsavedChanged(bool value) {
    if (_hasUnsavedReview.value != value) _hasUnsavedReview.value = value;
  }

  List<AvaliacaoModel> get _avaliacoesFiltradas => _filtroEstrelas == null
      ? _avaliacoes
      : _avaliacoes.where((r) => r.nota == _filtroEstrelas).toList();

  @override
  void initState() {
    super.initState();
    _mediaAvaliacao = widget.store.avaliacao;
    _carregarAvaliacoes();
    _carregarResumoLoja();
  }

  @override
  void dispose() {
    _hasUnsavedReview.dispose();
    super.dispose();
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final ratings = await _avaliacaoService.buscarAvaliacoesDaLoja(widget.store.id);
      if (!mounted) return;
      setState(() {
        _avaliacoes = ratings;
        _isLoadingRatings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ratingsError = 'Não foi possível carregar as avaliações.';
        _isLoadingRatings = false;
      });
    }
  }

  /// Busca a agregação de avaliação pronta do backend — garante o selo de
  /// nota correto independente de `widget.store` ter vindo de uma tela que
  /// já usa o endpoint novo ou de uma que ainda não (ex: Favoritos).
  Future<void> _carregarResumoLoja() async {
    try {
      final resumo = await _storeService.getResumo(widget.store.id);
      if (!mounted) return;
      setState(() => _mediaAvaliacao = resumo.avaliacao);
    } catch (_) {
      // Mantém o que já tinha (de widget.store, ou "Novo") se a busca falhar.
    }
  }

  String _formatRating(double? rating) {
    if (rating == null || rating == 0.0) return 'Novo';
    return rating.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedReview,
      child: Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            surfaceTintColor: context.mapColors.mainBackground,
            backgroundColor: context.mapColors.mainBackground,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.mapColors.cardSurface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FavoriteButtonWidget(store: store, iconSize: 20.0),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: SizedBox(
                  height: 260.0,
                  width: double.infinity,
                  child: resolveImagemUrl(store.capaUrl) != null
                      ? Image.network(
                          resolveImagemUrl(store.capaUrl)!, fit: BoxFit.cover,
                          // Hero da tela — o nome da loja não aparece perto o
                          // suficiente pra servir de rótulo implícito aqui.
                          semanticLabel: 'Foto de capa de ${store.nome}',
                          // Só cacheWidth: com os dois definidos o decoder
                          // ignora a proporção original e estica a imagem.
                          cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
                          errorBuilder: (context, error, stackTrace) => Container(color: context.mapColors.cardSurface, child: Center(child: Icon(AppIcons.image, size: 64.0, color: context.mapColors.iconMuted))),
                        )
                      : Container(color: context.mapColors.cardSurface, child: Center(child: Icon(AppIcons.image, size: 64.0, color: context.mapColors.iconMuted))),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          store.nome,
                          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, fontSize: 24.0, color: context.mapColors.primaryText, height: 1.1),
                        ),
                      ),
                      if (_userRole == 'CONSUMIDOR' || _userRole == 'GUEST')
                        ConsumerActionWidget(lojaId: store.id, userRole: _userRole),
                    ],
                  ),
                  if (store.enderecoCompleto != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(AppIcons.mapPin, size: 16.0, color: context.mapColors.iconMuted),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            store.enderecoCompleto!,
                            // Sem override de cor: legenda() já resolve pra secondaryText.
                            style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatsRow(context, store),
                  if (store.categoriaNomes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(spacing: 6.0, runSpacing: 6.0, children: _buildCategoryChips(context, store)),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  Text('Sobre o local', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    store.descricao ?? 'O vendedor não adicionou uma descrição detalhada para este comércio.',
                    style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Galeria de fotos', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText)),
                      // Sem override de cor: legenda() já resolve pra secondaryText.
                      Text('${store.galeria.length} fotos', style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Builder(
                    builder: (context) {
                      final galeriaResolvida = store.galeria
                          .map(resolveImagemUrl)
                          .whereType<String>()
                          .toList();
                      return SizedBox(
                        height: 140.0,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), clipBehavior: Clip.none,
                          itemCount: store.galeria.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                          itemBuilder: (context, index) {
                            final url = resolveImagemUrl(store.galeria[index]);
                            final indiceResolvido = url == null ? -1 : galeriaResolvida.indexOf(url);
                            return SemanticTapArea(
                              label: 'Foto ${index + 1} de ${store.galeria.length} da galeria',
                              onTap: url == null || galeriaResolvida.isEmpty
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        appPageRoute(
                                          builder: (_) => StoreGalleryViewer(
                                            imagens: galeriaResolvida,
                                            initialIndex: indiceResolvido < 0 ? 0 : indiceResolvido,
                                          ),
                                        ),
                                      ),
                              child: Container(
                                width: 140.0,
                                decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(AppRadius.md), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  child: url != null
                                      // Tile é 140x140 — decodifica só nesse tamanho físico.
                                      ? Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          excludeFromSemantics: true,
                                          // Só cacheWidth: com os dois definidos
                                          // o decoder ignora a proporção original.
                                          cacheWidth: (140.0 * MediaQuery.devicePixelRatioOf(context)).round(),
                                          errorBuilder: (context, error, stackTrace) => Center(child: Icon(AppIcons.image, color: context.mapColors.iconMuted, size: 32.0)),
                                        )
                                      : Center(child: Icon(AppIcons.image, color: context.mapColors.iconMuted, size: 32.0)),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const Divider(thickness: 0.2),
                  const SizedBox(height: AppSpacing.lg),

                  _buildAvaliacoesSection(context, store),

                  // Visitante também vê o formulário, mas em modo vitrine:
                  // qualquer toque abre a parede de login (ver
                  // ConsumerReviewWidget).
                  if (_userRole == 'CONSUMIDOR' || _userRole == 'GUEST') ...[
                    const SizedBox(height: AppSpacing.xl),
                    ConsumerReviewWidget(
                      lojaId: store.id,
                      userRole: _userRole,
                      onReviewSubmitted: _carregarAvaliacoes,
                      onUnsavedChanged: _onReviewUnsavedChanged,
                    ),
                  ],

                  const SizedBox(height: 120.0),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AppButton(
          label: 'Visualizar no mapa',
          icon: AppIcons.mapTrifold,
          onPressed: () => Navigator.push(
            context,
            appPageRoute(builder: (_) => StoreMapPage(store: store)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// Linha de estatísticas rápidas (nota média, avaliações, fotos,
  /// localização) — adaptação pro domínio de lojas do quadro de ícones
  /// "1200 sqft | 3 Beds | ..." da referência de imóveis. A nota média
  /// substitui a categoria aqui, o que permitiu remover o pill de estrela
  /// que ficava solto abaixo da imagem de capa.
  Widget _buildStatsRow(BuildContext context, StoreDto store) {
    final stats = [
      (AppIcons.star, _formatRating(_mediaAvaliacao), 'Nota média'),
      (AppIcons.chatCircle, '${store.totalAvaliacoes}', 'Avaliações'),
      (AppIcons.image, '${store.galeria.length}', 'Fotos'),
      (AppIcons.mapPin, store.temLocalizacao ? 'Sim' : 'Não', 'No mapa'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: context.mapColors.border)),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              // O divisor acompanha a altura do conteúdo ao lado; parado em 32
              // ele viraria um risco curto no meio de uma coluna alta.
              Container(
                width: 1,
                height: escalaComTeto(context, 32.0),
                color: context.mapColors.border,
              ),
            Expanded(
              child: Column(
                children: [
                  Icon(stats[i].$1, size: escalaIcone(context, 18.0), color: ColorsPalette.redComponents),
                  const SizedBox(height: 4.0),
                  Text(
                    stats[i].$2,
                    style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText, fontSize: 13.0),
                    // Quatro colunas dividindo a largura da tela: em escala
                    // alta "Nota média" não cabe numa linha, e cada coluna tem
                    // só um quarto do espaço para negociar.
                    maxLines: linhasParaRotulo(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Sem override de cor: legenda() já resolve pra secondaryText.
                  Text(
                    stats[i].$3,
                    style: AppText.legenda(context).copyWith(fontSize: 10.0),
                    textAlign: TextAlign.center,
                    maxLines: linhasParaRotulo(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCategoryChips(BuildContext context, StoreDto store) {
    final names = store.categoriaNomes.isNotEmpty ? store.categoriaNomes : [store.categoria.isNotEmpty ? store.categoria : 'Geral'];
    return names.map((name) {
      final cor = corParaCategoria(name);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(color: cor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: cor.withValues(alpha: 0.3))),
        child: Text(name, style: AppText.legenda(context).copyWith(color: cor, fontWeight: FontWeight.w700)),
      );
    }).toList();
  }

  Widget _buildAvaliacoesSection(BuildContext context, StoreDto store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticTapArea(
          label: _avaliacoesExpandidas ? 'Recolher avaliações' : 'Expandir avaliações',
          selected: _avaliacoesExpandidas,
          onTap: () => setState(() => _avaliacoesExpandidas = !_avaliacoesExpandidas),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Avaliações', style: AppText.titulo(context).copyWith(fontWeight: FontWeight.w900)),
                  Text(_isLoadingRatings ? 'Carregando...' : '${_avaliacoes.length} avaliações', style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText)),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: ColorsPalette.ratingStar.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: ColorsPalette.ratingStar, size: 20),
                        const SizedBox(width: 4),
                        Text(_formatRating(_mediaAvaliacao), style: AppText.subtitulo(context).copyWith(color: ColorsPalette.ratingStarText, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _avaliacoesExpandidas ? 0.5 : 0.0,
                    child: Icon(AppIcons.caretDown, size: 20, color: context.mapColors.iconMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !_avaliacoesExpandidas
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    if (!_isLoadingRatings && _ratingsError == null && _avaliacoes.isNotEmpty) ...[
                      _buildFiltroEstrelas(context),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    if (_isLoadingRatings)
                      const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: CircularProgressIndicator(color: ColorsPalette.redComponents, strokeWidth: 2.5)))
                    else if (_ratingsError != null)
                      _RatingsErrorWidget(onRetry: _carregarAvaliacoes)
                    else if (_avaliacoes.isEmpty)
                      _RatingsEmptyWidget()
                    else if (_avaliacoesFiltradas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(
                          child: Text(
                            'Nenhuma avaliação com $_filtroEstrelas estrelas.',
                            style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText),
                          ),
                        ),
                      )
                    else
                      ..._avaliacoesFiltradas.map((review) => _ReviewCard(review: review)),
                  ],
                ),
        ),
      ],
    );
  }

  /// Teto de escala da faixa de filtros. Tira horizontal dentro da lista de
  /// avaliações: crescer sem limite empurraria as próprias avaliações para
  /// fora da tela, que é o conteúdo que o filtro existe para organizar.
  static const double _tetoEscalaFiltros = 1.5;

  Widget _buildFiltroEstrelas(BuildContext context) {
    return MaxTextScale(
      max: _tetoEscalaFiltros,
      child: SizedBox(
        height: escalaComTeto(context, 36.0, teto: _tetoEscalaFiltros),
        child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _FiltroEstrelaChip(
            label: 'Todas',
            isSelected: _filtroEstrelas == null,
            onTap: () => setState(() => _filtroEstrelas = null),
          ),
            for (var estrelas = 5; estrelas >= 1; estrelas--) ...[
              const SizedBox(width: 8.0),
              _FiltroEstrelaChip(
                label: '$estrelas',
                icon: AppIcons.star,
                isSelected: _filtroEstrelas == estrelas,
                onTap: () => setState(() => _filtroEstrelas = estrelas),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FiltroEstrelaChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FiltroEstrelaChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SemanticTapArea(
      label: label,
      selected: isSelected,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Chip flutuante sobre a página — cardSurface quando não
          // selecionado; selecionado fica sólido preto de propósito
          // (mesmo CTA do Lote 1).
          color: isSelected ? ColorsPalette.black : context.mapColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: isSelected ? ColorsPalette.black : context.mapColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mesmo ✓ do AppChoiceChip: sem ele, o único sinal de qual
            // filtro de nota está ativo seria o par de cores.
            if (isSelected) ...[
              const ExcludeSemantics(
                child: Icon(AppIcons.check, size: 13.0, color: Colors.white),
              ),
              const SizedBox(width: 4.0),
            ] else if (icon != null) ...[
              Icon(icon, size: 13.0, color: ColorsPalette.ratingStar),
              const SizedBox(width: 4.0),
            ],
            Text(
              label,
              style: AppText.legenda(context).copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                // Não-selecionado sem override: legenda() já resolve pra secondaryText.
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final AvaliacaoModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final nome = review.consumidor?.nome ?? 'Usuário';
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';
    final data = _formatDate(review.dataAvaliacao);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: context.mapColors.border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.1), child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.bold, color: ColorsPalette.redComponents))),
                  const SizedBox(width: 8),
                  Text(nome, style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              // Sem override de cor: legenda() já resolve pra secondaryText.
              Text(data, style: AppText.legenda(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: List.generate(5, (index) => Icon(index < review.nota ? Icons.star_rounded : Icons.star_border_rounded, color: ColorsPalette.ratingStar, size: 16))),
          if (review.comentario != null && review.comentario!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(review.comentario!, style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText, height: 1.4)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) return 'Hoje';
      if (diff.inDays == 1) return 'Ontem';
      if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
      if (diff.inDays < 30) return 'Há ${(diff.inDays / 7).floor()} semanas';
      if (diff.inDays < 365) return 'Há ${(diff.inDays / 30).floor()} meses';
      return 'Há ${(diff.inDays / 365).floor()} anos';
    } catch (_) { return ''; }
  }
}

class _RatingsErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  const _RatingsErrorWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            Icon(AppIcons.warningCircle, size: 36, color: context.mapColors.iconMuted),
            const SizedBox(height: AppSpacing.md),
            Text('Não foi possível carregar as avaliações.', style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente', style: TextStyle(color: ColorsPalette.redComponents))),
          ],
        ),
      ),
    );
  }
}

class _RatingsEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: context.mapColors.border)),
      child: Column(
        children: [
          Icon(AppIcons.chatCircle, size: 36, color: context.mapColors.iconMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Nenhuma avaliação ainda', style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w700, color: context.mapColors.primaryText)),
          const SizedBox(height: AppSpacing.xs),
          // Sem override de cor: legenda() já resolve pra secondaryText.
          Text('Seja o primeiro a avaliar este comércio!', style: AppText.legenda(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Pill "Denunciar" ao lado do nome da loja. Aparece para consumidor **e
/// para visitante**: esconder a ação de quem não tem conta escondia também
/// que ela existe — o visitante só descobria que dá pra denunciar depois de
/// criar conta. Para o visitante o toque abre a parede de login em vez do
/// formulário.
class ConsumerActionWidget extends StatelessWidget {
  final int lojaId;
  final String userRole;

  const ConsumerActionWidget({super.key, required this.lojaId, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return SemanticTapArea(
      label: 'Denunciar comércio',
      // O visitante é levado à parede de login em vez do formulário — dizer
      // isso antes evita o toque que só descobre a exigência depois.
      hint: userRole == 'GUEST' ? 'Requer entrar na conta' : null,
      onTap: () {
        if (userRole == 'GUEST') {
          LoginWallHelper.showLoginWallBottomSheet(
            context,
            icon: AppIcons.flag,
            title: "Viu algo errado neste comércio?",
            description:
                "Crie uma conta gratuita em segundos para denunciar e acompanhar a situação da sua denúncia.",
          );
          return;
        }
        showDialog(
          context: context,
          builder: (context) => _DenunciaDialog(lojaId: lojaId),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Row(
          children: [
            const Icon(AppIcons.flag, size: 14, color: ColorsPalette.redComponents),
            const SizedBox(width: 6),
            Text("Denunciar", style: AppText.legenda(context).copyWith(color: ColorsPalette.redComponents, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _DenunciaDialog extends StatefulWidget {
  final int lojaId;
  const _DenunciaDialog({required this.lojaId});

  @override
  State<_DenunciaDialog> createState() => _DenunciaDialogState();
}

class _DenunciaDialogState extends State<_DenunciaDialog> {
  static const _motivos = ['Conteúdo inapropriado', 'Fraude ou golpe', 'Informações falsas', 'Spam', 'Outro'];
  static const _motivoPadrao = 'Outro';

  String _motivoSelecionado = _motivoPadrao;
  bool _isSubmitting = false;
  final _descricaoController = TextEditingController();
  final _denunciaService = DenunciaService();

  // Guard de "sair sem salvar": só considera alterado se o usuário fugiu do
  // motivo padrão ou escreveu alguma descrição — evita perguntar confirmação
  // pra quem só abriu o dialog e fechou sem preencher nada. ValueNotifier
  // (não bool simples) pra não reconstruir o dialog inteiro a cada tecla —
  // o rebuild fica isolado no ValueListenableBuilder do UnsavedChangesGuard.
  final ValueNotifier<bool> _hasUnsavedChanges = ValueNotifier(false);

  bool _computeHasUnsavedChanges() =>
      _motivoSelecionado != _motivoPadrao || _descricaoController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // O formulário sempre abre em branco: o backend (contrato legado) não
    // tem checagem de duplicidade nem endpoint pra pré-carregar denúncia
    // existente.
    _descricaoController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final dirty = _computeHasUnsavedChanges();
    if (_hasUnsavedChanges.value != dirty) _hasUnsavedChanges.value = dirty;
  }

  @override
  void dispose() {
    _descricaoController.removeListener(_onFormChanged);
    _descricaoController.dispose();
    _hasUnsavedChanges.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _isSubmitting = true);
    try {
      // POST /denuncias (contrato legado) não extrai o consumidor do JWT —
      // precisa do id da sessão local no corpo da requisição.
      final consumidorId = SessionStore.instance.userId;
      if (consumidorId == null) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        UIUtils.showErrorDialog(context, "Sessão expirada. Faça login novamente.");
        return;
      }
      await _denunciaService.create(
        lojaId: widget.lojaId,
        consumidorId: consumidorId,
        motivo: _motivoSelecionado,
        descricao: _descricaoController.text.trim(),
      );
      if (!mounted) return;
      // pop() direto (não maybePop): já foi salvo, então fecha sem passar
      // pela confirmação de "sair sem salvar" do PopScope abaixo.
      Navigator.pop(context);
      AppToast.success(context, "Denúncia enviada.");
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // Não fecha o dialog aqui — um erro de validação (ex: descrição muito
      // longa) fechava o dialog e descartava o texto digitado sem explicar
      // o motivo. Mantém o formulário aberto pro usuário corrigir e reenviar.
      UIUtils.showErrorDialog(context, "Erro ao enviar denúncia. Tente novamente.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        backgroundColor: context.mapColors.cardSurface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(AppIcons.flag, color: ColorsPalette.redComponents, size: 20),
                        const SizedBox(width: 8),
                        Text("Denunciar loja", style: AppText.titulo(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(icon: Icon(AppIcons.x, size: 20, color: context.mapColors.iconMuted), onPressed: () => Navigator.maybePop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text("Seu relatório será analisado pela nossa equipe. Obrigado por manter a plataforma segura.", style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText, fontSize: 13)),
                const SizedBox(height: AppSpacing.lg),
                Text("Motivo", style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold, color: context.mapColors.primaryText)),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: ColorsPalette.redComponents.withValues(alpha: 0.3), width: 1.2)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _motivoSelecionado,
                      isExpanded: true,
                      dropdownColor: context.mapColors.cardSurface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      icon: Icon(AppIcons.caretDown, size: 18, color: context.mapColors.primaryText),
                      items: _motivos.map((String motivo) {
                        return DropdownMenuItem<String>(value: motivo, child: Text(motivo, style: AppText.corpo(context).copyWith(color: context.mapColors.primaryText)));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _motivoSelecionado = newValue);
                          _onFormChanged();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text("Descrição (opcional)", style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold, color: context.mapColors.primaryText)),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _descricaoController,
                  maxLines: 3,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    hintText: 'Conte mais detalhes sobre o ocorrido...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: const BorderSide(color: ColorsPalette.redComponents)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.maybePop(context), child: Text("Cancelar", style: AppText.botao(context).copyWith(color: context.mapColors.secondaryText))),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _enviar,
                      style: ElevatedButton.styleFrom(backgroundColor: ColorsPalette.redComponents, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill))),
                      child: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Enviar denúncia", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConsumerReviewWidget extends StatefulWidget {
  final int lojaId;

  /// 'CONSUMIDOR' usa o formulário normalmente; 'GUEST' vê o mesmo bloco,
  /// mas inerte — o toque em qualquer parte dele abre a parede de login.
  final String userRole;

  final VoidCallback onReviewSubmitted;
  final ValueChanged<bool>? onUnsavedChanged;

  const ConsumerReviewWidget({
    super.key,
    required this.lojaId,
    required this.userRole,
    required this.onReviewSubmitted,
    this.onUnsavedChanged,
  });

  @override
  State<ConsumerReviewWidget> createState() => _ConsumerReviewWidgetState();
}

class _ConsumerReviewWidgetState extends State<ConsumerReviewWidget> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  final AvaliacaoService _avaliacaoService = AvaliacaoService();

  // Histórico de avaliações que o próprio consumidor já fez para esta loja.
  // Múltiplas avaliações são permitidas (API geral não bloqueia duplicidade
  // nem faz upsert) — cada envio soma uma nova linha ao histórico, em vez de
  // sobrescrever a anterior.
  List<AvaliacaoModel> _minhasAvaliacoes = [];
  bool _isLoadingHistorico = true;

  // Mesma lógica de recolher/expandir da seção "Avaliações" da loja,
  // aplicada ao histórico de avaliações do próprio consumidor — começa
  // expandida pra não mudar o comportamento visual atual por padrão.
  bool _minhasAvaliacoesExpandidas = true;

  bool get _isGuest => widget.userRole == 'GUEST';

  bool get _hasUnsavedChanges => _rating > 0 || _commentController.text.trim().isNotEmpty;

  void _notifyUnsavedChanged() => widget.onUnsavedChanged?.call(_hasUnsavedChanges);

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_notifyUnsavedChanged);
    if (_isGuest) {
      // Visitante não tem token: GET /avaliacoes/minhas responderia 401, que
      // além de inútil aqui passa pelo ErrorInterceptor. Nada de histórico
      // pra buscar — sai direto do estado de carregamento.
      _isLoadingHistorico = false;
    } else {
      _carregarHistorico();
    }
  }

  void _mostrarParedeLogin() {
    LoginWallHelper.showLoginWallBottomSheet(
      context,
      icon: AppIcons.star,
      title: "Conte como foi sua experiência",
      description:
          "Crie uma conta gratuita em segundos para avaliar este comércio e ajudar outras pessoas a decidir.",
    );
  }

  /// Busca todas as avaliações do consumidor autenticado (GET /avaliacoes/minhas)
  /// e filtra pelo lojaId no client-side — não existe endpoint que devolva só
  /// as avaliações de uma loja específica.
  Future<void> _carregarHistorico() async {
    try {
      final todasMinhas = await _avaliacaoService.getMinhasAvaliacoes();
      if (!mounted) return;
      setState(() {
        _minhasAvaliacoes = todasMinhas.where((a) => a.lojaId == widget.lojaId).toList();
        _isLoadingHistorico = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingHistorico = false);
    }
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppToast.error(context, 'Selecione uma nota de 1 a 5 estrelas.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _avaliacaoService.enviarAvaliacao(
        lojaId: widget.lojaId,
        nota: _rating,
        comentario: _commentController.text,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        // Limpa o formulário: cada envio é uma nova avaliação no histórico,
        // não uma edição da anterior.
        _rating = 0;
        _commentController.clear();
      });
      widget.onUnsavedChanged?.call(false);
      AppToast.success(context, 'Avaliação enviada com sucesso!');
      widget.onReviewSubmitted();
      unawaited(_carregarHistorico());
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      UIUtils.showErrorDialog(
        context,
        'Erro ao enviar avaliação (${e.statusCode ?? 's/ status'}): ${e.message}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      UIUtils.showErrorDialog(context, 'Erro inesperado ao enviar avaliação: $e');
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_notifyUnsavedChanged);
    _commentController.dispose();
    widget.onUnsavedChanged?.call(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.mapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingHistorico)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CircularProgressIndicator(color: ColorsPalette.redComponents, strokeWidth: 2),
              ),
            )
          else if (_minhasAvaliacoes.isNotEmpty) ...[
            SemanticTapArea(
              label: _minhasAvaliacoesExpandidas ? 'Recolher suas avaliações anteriores' : 'Expandir suas avaliações anteriores',
              selected: _minhasAvaliacoesExpandidas,
              onTap: () => setState(() => _minhasAvaliacoesExpandidas = !_minhasAvaliacoesExpandidas),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Suas avaliações anteriores', style: AppText.titulo(context).copyWith(fontWeight: FontWeight.bold)),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _minhasAvaliacoesExpandidas ? 0.5 : 0.0,
                    child: Icon(AppIcons.caretDown, size: 20, color: context.mapColors.iconMuted),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: !_minhasAvaliacoesExpandidas
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        ..._minhasAvaliacoes.map((review) => _ReviewCard(review: review)),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(thickness: 0.2),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildFormulario(context),
        ],
      ),
    );
  }

  /// Formulário de avaliação. Para o visitante ele é exibido igual, mas
  /// dentro de um `AbsorbPointer`: as estrelas não marcam, o campo não recebe
  /// foco (nem abre teclado) e o botão não envia — o toque é capturado pelo
  /// `GestureDetector` de fora, que abre a parede de login. Mostrar o
  /// formulário desabilitado, e não escondê-lo, é o que faz o visitante
  /// descobrir que avaliar existe.
  Widget _buildFormulario(BuildContext context) {
    final formulario = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avaliar este comércio',
          style: AppText.titulo(context).copyWith(fontWeight: FontWeight.bold),
        ),
        if (_isGuest) ...[
          const SizedBox(height: 4.0),
          Text(
            'Entre na sua conta para avaliar este comércio.',
            style: AppText.legenda(context),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: ColorsPalette.ratingStar,
                size: 40,
              ),
              onPressed: () {
                setState(() => _rating = index + 1);
                _notifyUnsavedChanged();
              },
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _commentController,
          maxLines: 3,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: 'Deixe um comentário (opcional)...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: const BorderSide(color: ColorsPalette.redComponents)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // `loading` do AppButton no lugar do spinner montado à mão: ele já
        // preserva a largura e bloqueia o toque durante o envio.
        AppButton(
          label: 'Enviar Avaliação',
          variant: AppButtonVariant.inverse,
          loading: _isSubmitting,
          onPressed: _submit,
        ),
      ],
    );

    if (!_isGuest) return formulario;

    return Semantics(
      button: true,
      label: 'Avaliar este comércio. Requer entrar na conta.',
      child: GestureDetector(
        onTap: _mostrarParedeLogin,
        behavior: HitTestBehavior.opaque,
        child: AbsorbPointer(child: formulario),
      ),
    );
  }
}
