import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
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
  String _userRole = 'GUEST';
  String _userName = 'Usuário';

  // Filtro por estrelas na lista de avaliações — null significa "todas". A
  // API sempre devolve a lista completa; o filtro é só client-side.
  int? _filtroEstrelas;

  // Agregação de avaliação vinda do backend (Fase 4) — não é mais calculada
  // no cliente. Começa com o que já veio em `widget.store` (pode já estar
  // populado se a tela de origem usou /mobile/api/v1/lojas) e é atualizada
  // com o dado mais fresco assim que a busca abaixo responde.
  double? _mediaAvaliacao;

  // Guard de "sair sem salvar": true enquanto o usuário tiver nota/comentário
  // digitados no ConsumerReviewWidget sem enviar — a página inteira precisa
  // saber disso porque o widget de avaliação é só uma seção dela, não uma
  // tela própria.
  bool _hasUnsavedReview = false;

  void _onReviewUnsavedChanged(bool value) {
    if (mounted) setState(() => _hasUnsavedReview = value);
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
    _carregarPapelDoUsuario();
  }

  Future<void> _carregarPapelDoUsuario() async {
    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() {
        _userRole = session?.tipo ?? 'GUEST';
        _userName = session?.nome ?? 'Usuário';
      });
    }
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
            expandedHeight: 320.0,
            floating: false,
            pinned: true,
            surfaceTintColor: context.mapColors.mainBackground,
            backgroundColor: context.mapColors.mainBackground,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                // Botão flutuante sobre a foto de capa — cardSurface, não a
                // cor de fundo da página (Lote 4B).
                decoration: BoxDecoration(
                  color: context.mapColors.cardSurface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(PhosphorIconsRegular.caretLeft, color: ColorsPalette.redComponents),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(color: context.mapColors.mainBackground),
                    child: resolveImagemUrl(store.capaUrl) != null
                        ? ClipRRect(
                            child: Image.network(
                              resolveImagemUrl(store.capaUrl)!, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(child: Icon(PhosphorIconsRegular.image, size: 64.0, color: context.mapColors.iconMuted)),
                            ),
                          )
                        : Center(child: Icon(PhosphorIconsRegular.image, size: 64.0, color: context.mapColors.iconMuted)),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)]),
                      ),
                    ),
                  ),
                ],
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
                      if (_userRole == 'CONSUMIDOR')
                        ConsumerActionWidget(lojaId: store.id),
                    ],
                  ),
                  if (store.categoriaNomes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(spacing: 6.0, runSpacing: 6.0, children: _buildCategoryChips(context, store)),
                  ],
                  if (store.enderecoCompleto != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.mapPin, size: 16.0, color: context.mapColors.iconMuted),
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
                          separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                          itemBuilder: (context, index) {
                            final url = resolveImagemUrl(store.galeria[index]);
                            final indiceResolvido = url == null ? -1 : galeriaResolvida.indexOf(url);
                            return GestureDetector(
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
                                decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(16.0), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: url != null
                                      ? Image.network(url, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Center(child: Icon(PhosphorIconsRegular.image, color: context.mapColors.iconMuted, size: 32.0)))
                                      : Center(child: Icon(PhosphorIconsRegular.image, color: context.mapColors.iconMuted, size: 32.0)),
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

                  if (_userRole == 'CONSUMIDOR') ...[
                    const SizedBox(height: AppSpacing.xl),
                    ConsumerReviewWidget(
                      lojaId: store.id,
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
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              appPageRoute(builder: (_) => StoreMapPage(store: store)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPalette.redComponents,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
              elevation: 4,
            ),
            child: Text(
              'Visualizar no mapa',
              style: AppText.botao(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  List<Widget> _buildCategoryChips(BuildContext context, StoreDto store) {
    final names = store.categoriaNomes.isNotEmpty ? store.categoriaNomes : [store.categoria.isNotEmpty ? store.categoria : 'Geral'];
    return names.map((name) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: ColorsPalette.redComponents.withValues(alpha: 0.2))),
      child: Text(name, style: AppText.legenda(context).copyWith(color: ColorsPalette.redComponents, fontWeight: FontWeight.w700)),
    )).toList();
  }

  Widget _buildAvaliacoesSection(BuildContext context, StoreDto store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100.0)),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(_formatRating(_mediaAvaliacao), style: AppText.subtitulo(context).copyWith(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
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
    );
  }

  Widget _buildFiltroEstrelas(BuildContext context) {
    return SizedBox(
      height: 36.0,
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
              icon: PhosphorIconsRegular.star,
              isSelected: _filtroEstrelas == estrelas,
              onTap: () => setState(() => _filtroEstrelas = estrelas),
            ),
          ],
        ],
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
    return GestureDetector(
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
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: isSelected ? ColorsPalette.black : context.mapColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13.0, color: isSelected ? Colors.amber : Colors.amber.shade600),
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
      decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(16.0), border: Border.all(color: context.mapColors.border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
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
          Row(children: List.generate(5, (index) => Icon(index < review.nota ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 16))),
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
            Icon(PhosphorIconsRegular.warningCircle, size: 36, color: context.mapColors.iconMuted),
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
      decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(16.0), border: Border.all(color: context.mapColors.border)),
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.chatCircle, size: 36, color: context.mapColors.iconMuted),
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

class ConsumerActionWidget extends StatelessWidget {
  final int lojaId;
  const ConsumerActionWidget({super.key, required this.lojaId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _DenunciaDialog(lojaId: lojaId),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
        child: Row(
          children: [
            const Icon(PhosphorIconsRegular.flag, size: 14, color: ColorsPalette.redComponents),
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
  // pra quem só abriu o dialog e fechou sem preencher nada.
  bool get _hasUnsavedChanges =>
      _motivoSelecionado != _motivoPadrao || _descricaoController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Reconstrói o dialog a cada tecla digitada para o PopScope sempre
    // enxergar o estado mais recente da descrição ao decidir se pede
    // confirmação de saída. O formulário sempre abre em branco: a API geral
    // bloqueia duplicidade com 409 (sem upsert/reabertura de denúncia já
    // tratada), então não há mais o que pré-carregar aqui.
    _descricaoController.addListener(_onFormChanged);
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    _descricaoController.removeListener(_onFormChanged);
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _isSubmitting = true);
    try {
      await _denunciaService.create(
        lojaId: widget.lojaId,
        motivo: _motivoSelecionado,
        descricao: _descricaoController.text.trim(),
      );
      if (!mounted) return;
      // pop() direto (não maybePop): já foi salvo, então fecha sem passar
      // pela confirmação de "sair sem salvar" do PopScope abaixo.
      Navigator.pop(context);
      AppToast.success(context, "Denúncia enviada.");
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (e.statusCode == 409) {
        // API geral bloqueia duplicidade (sem upsert/reabertura) — mostra a
        // mensagem amigável que já vem do backend, mantendo o dialog aberto.
        AppToast.error(context, e.message);
      } else {
        UIUtils.showErrorDialog(context, "Erro ao enviar denúncia. Tente novamente.");
      }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
                        const Icon(PhosphorIconsRegular.flag, color: ColorsPalette.redComponents, size: 20),
                        const SizedBox(width: 8),
                        Text("Denunciar loja", style: AppText.titulo(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(icon: Icon(PhosphorIconsRegular.x, size: 20, color: context.mapColors.iconMuted), onPressed: () => Navigator.maybePop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text("Seu relatório será analisado pela nossa equipe. Obrigado por manter a plataforma segura.", style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText, fontSize: 13)),
                const SizedBox(height: AppSpacing.lg),
                Text("Motivo", style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold, color: context.mapColors.primaryText)),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(color: context.mapColors.cardSurface, borderRadius: BorderRadius.circular(12.0), border: Border.all(color: ColorsPalette.redComponents.withValues(alpha: 0.3), width: 1.2)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _motivoSelecionado,
                      isExpanded: true,
                      dropdownColor: context.mapColors.cardSurface,
                      borderRadius: BorderRadius.circular(12.0),
                      icon: Icon(PhosphorIconsRegular.caretDown, size: 18, color: context.mapColors.primaryText),
                      items: _motivos.map((String motivo) {
                        return DropdownMenuItem<String>(value: motivo, child: Text(motivo, style: AppText.corpo(context).copyWith(color: context.mapColors.primaryText)));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) setState(() => _motivoSelecionado = newValue);
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: ColorsPalette.redComponents)),
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
  final VoidCallback onReviewSubmitted;
  final ValueChanged<bool>? onUnsavedChanged;

  const ConsumerReviewWidget({
    super.key,
    required this.lojaId,
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

  bool get _hasUnsavedChanges => _rating > 0 || _commentController.text.trim().isNotEmpty;

  void _notifyUnsavedChanged() => widget.onUnsavedChanged?.call(_hasUnsavedChanges);

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_notifyUnsavedChanged);
    _carregarHistorico();
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
      _carregarHistorico();
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
        borderRadius: BorderRadius.circular(16.0),
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
            Text('Suas avaliações anteriores', style: AppText.titulo(context).copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            ..._minhasAvaliacoes.map((review) => _ReviewCard(review: review)),
            const SizedBox(height: AppSpacing.sm),
            const Divider(thickness: 0.2),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            'Avaliar este comércio',
            style: AppText.titulo(context).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: ColorsPalette.redComponents)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPalette.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'Enviar Avaliação',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
