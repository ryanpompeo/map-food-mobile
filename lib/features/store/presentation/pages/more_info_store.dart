import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/services/notification_service.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/features/reviews/data/models/avaliacao_model.dart';
import 'package:map_food/features/reviews/data/services/rating_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/fullscreen_image_viewer.dart';
import 'package:map_food/features/store/presentation/widgets/report_store_form.dart';

class MoreInfoStorePage extends StatefulWidget {
  final StoreDto store;

  const MoreInfoStorePage({super.key, required this.store});

  @override
  State<MoreInfoStorePage> createState() => _MoreInfoStorePageState();
}

class _MoreInfoStorePageState extends State<MoreInfoStorePage> {
  final RatingService _ratingService = RatingService();
  final StoreService _storeService = StoreService();

  late StoreDto _store;
  bool _isHydrating = false;

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoadingRatings = true;
  String? _ratingsError;
  String _userRole = 'GUEST';
  String _userName = 'Usuário';

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    if (_store.isPartial) {
      _hydrateStore();
    }
    _fetchRatings();
    _loadUserRole();
  }

  /// Deep link "mínimo" (ex: vindo de Minhas Avaliações, só com id/nome) —
  /// busca a loja completa (capa, galeria, categorias) por id antes de
  /// renderizar de verdade.
  Future<void> _hydrateStore() async {
    setState(() => _isHydrating = true);
    try {
      final completo = await _storeService.getById(_store.id);
      if (!mounted) return;
      setState(() {
        _store = completo;
        _isHydrating = false;
      });
    } catch (_) {
      // Mantém o stub — melhor mostrar algo incompleto do que travar a tela.
      if (!mounted) return;
      setState(() => _isHydrating = false);
    }
  }

  Future<void> _loadUserRole() async {
    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() {
        _userRole = session?.tipo ?? 'GUEST';
        _userName = session?.nome ?? 'Usuário';
      });
    }
  }

  Future<void> _fetchRatings() async {
    try {
      final ratings = await _ratingService.getStoreRatings(_store.id);
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

  String _formatRating(double? rating) {
    if (rating == null || rating == 0.0) return 'Novo';
    return rating.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isHydrating) {
      return Scaffold(
        backgroundColor: ColorsPalette.whiteBackground,
        body: const SafeArea(
          child: Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents)),
        ),
      );
    }

    final store = _store;

    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            floating: false,
            pinned: true,
            surfaceTintColor: ColorsPalette.whiteBackground,
            backgroundColor: ColorsPalette.whiteBackground,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsPalette.whiteBackground.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.chevronLeft, color: ColorsPalette.redComponents),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: ColorsPalette.whiteBackground),
                    child: store.imagens != null && store.imagens!.isNotEmpty
                        ? ClipRRect(
                            child: Image.network(
                              store.imagens![0], fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image, size: 64.0, color: Colors.grey)),
                            ),
                          )
                        : const Center(child: Icon(LucideIcons.image, size: 64.0, color: Colors.grey)),
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
                          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, fontSize: 24.0, color: ColorsPalette.black, height: 1.1),
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
                  const SizedBox(height: AppSpacing.lg),

                  _VisualizarNoMapaButton(
                    onTap: () => NotificationService.instance.warning('Integração de rotas em breve.'),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text('Sobre o local', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    store.descricao ?? 'O vendedor não adicionou uma descrição detalhada para este comércio.',
                    style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText, height: 1.5),
                  ),

                  // A capa (imagens[0]) já é o hero do SliverAppBar acima — a
                  // galeria abaixo mostra só o restante, e a seção some
                  // inteira se não houver nenhuma foto além da capa.
                  if (_galeria(store).isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Galeria de fotos', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black)),
                        Text('${_galeria(store).length} fotos', style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _galeria(store).length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemBuilder: (context, index) {
                        final url = _galeria(store)[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, FullscreenImageViewer.route(url)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              color: Colors.grey.shade100,
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(LucideIcons.image, color: Colors.grey, size: 24.0)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  const Divider(thickness: 0.2),
                  const SizedBox(height: AppSpacing.lg),

                  _buildAvaliacoesSection(context, store),

                  if (_userRole == 'CONSUMIDOR') ...[
                    const SizedBox(height: AppSpacing.xl),
                    ConsumerReviewWidget(lojaId: store.id, onReviewSubmitted: _fetchRatings),
                  ],

                  const SizedBox(height: 120.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Todas as fotos exceto a capa (`imagens[0]`), que já é o hero do
  /// SliverAppBar — evita mostrar a mesma imagem duas vezes.
  List<String> _galeria(StoreDto store) {
    final imagens = store.imagens;
    if (imagens == null || imagens.length <= 1) return const [];
    return imagens.sublist(1);
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
                Text(_isLoadingRatings ? 'Carregando...' : '${_avaliacoes.length} avaliações', style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100.0)),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(_formatRating(store.avaliacao), style: AppText.subtitulo(context).copyWith(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        if (_isLoadingRatings)
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xl), child: CircularProgressIndicator(color: ColorsPalette.redComponents, strokeWidth: 2.5)))
        else if (_ratingsError != null)
          _RatingsErrorWidget(onRetry: _fetchRatings)
        else if (_avaliacoes.isEmpty)
          _RatingsEmptyWidget()
        else
          ..._avaliacoes.map((review) => _ReviewCard(review: review)),
      ],
    );
  }
}

/// Botão de intenção "Visualizar no Mapa" — a API ainda não retorna
/// latitude/longitude (travado pela Fase 3), então o toque só avisa que a
/// integração está a caminho, sem navegar a lugar nenhum de verdade.
class _VisualizarNoMapaButton extends StatelessWidget {
  final VoidCallback onTap;

  const _VisualizarNoMapaButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.mapPin, color: ColorsPalette.redComponents, size: 18),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                'Visualizar no mapa',
                style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w700, color: ColorsPalette.black),
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey.shade400),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
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
              Text(data, style: AppText.legenda(context).copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: List.generate(5, (index) => Icon(index < review.nota ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 16))),
          if (review.comentario != null && review.comentario!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(review.comentario!, style: AppText.corpo(context).copyWith(color: Colors.grey.shade700, height: 1.4)),
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
            Icon(LucideIcons.alertCircle, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.md),
            Text('Não foi possível carregar as avaliações.', style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText), textAlign: TextAlign.center),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(LucideIcons.messageSquare, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: AppSpacing.md),
          Text('Nenhuma avaliação ainda', style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w700, color: ColorsPalette.black)),
          const SizedBox(height: AppSpacing.xs),
          Text('Seja o primeiro a avaliar este comércio!', style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText), textAlign: TextAlign.center),
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
      onTap: () => showDialog(
        context: context,
        builder: (_) => ReportStoreForm(lojaId: lojaId),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
        child: Row(
          children: [
            const Icon(LucideIcons.flag, size: 14, color: ColorsPalette.redComponents),
            const SizedBox(width: 6),
            Text("Denunciar", style: AppText.legenda(context).copyWith(color: ColorsPalette.redComponents, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ConsumerReviewWidget extends StatefulWidget {
  final int lojaId;
  final VoidCallback onReviewSubmitted;

  const ConsumerReviewWidget({super.key, required this.lojaId, required this.onReviewSubmitted});

  @override
  State<ConsumerReviewWidget> createState() => _ConsumerReviewWidgetState();
}

class _ConsumerReviewWidgetState extends State<ConsumerReviewWidget> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  final RatingService _ratingService = RatingService();

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma nota de 1 a 5 estrelas.'), backgroundColor: ColorsPalette.redComponents));
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      await _ratingService.submitRating(
        lojaId: widget.lojaId,
        nota: _rating,
        comentario: _commentController.text,
      );
      
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _rating = 0;
        _commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação enviada com sucesso!'), backgroundColor: Colors.green));
      widget.onReviewSubmitted();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      UIUtils.showErrorDialog(context, 'Erro ao enviar avaliação. Tente novamente mais tarde.');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Avaliar este comércio', style: AppText.titulo(context).copyWith(fontWeight: FontWeight.bold)),
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
                  : const Text('Enviar Avaliação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
