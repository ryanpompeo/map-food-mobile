import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/reviews/data/models/avaliacao_model.dart';
import 'package:map_food/features/reviews/data/services/rating_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/features/reviews/data/services/denuncia_service.dart';
import 'package:map_food/core/errors/exception.dart';

class MoreInfoStorePage extends StatefulWidget {
  final StoreDto store;

  const MoreInfoStorePage({super.key, required this.store});

  @override
  State<MoreInfoStorePage> createState() => _MoreInfoStorePageState();
}

class _MoreInfoStorePageState extends State<MoreInfoStorePage> {
  final RatingService _ratingService = RatingService();

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoadingRatings = true;
  String? _ratingsError;
  String _userRole = 'GUEST';
  String _userName = 'Usuário';

  @override
  void initState() {
    super.initState();
    _fetchRatings();
    _loadUserRole();
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
      final ratings = await _ratingService.getStoreRatings(widget.store.id);
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
    final store = widget.store;

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
                    child: resolveImagemUrl(store.capaUrl) != null
                        ? ClipRRect(
                            child: Image.network(
                              resolveImagemUrl(store.capaUrl)!, fit: BoxFit.cover,
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
                  const SizedBox(height: AppSpacing.xl),

                  Text('Sobre o local', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    store.descricao ?? 'O vendedor não adicionou uma descrição detalhada para este comércio.',
                    style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Galeria de fotos', style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black)),
                      Text('${store.galeria.length} fotos', style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 140.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), clipBehavior: Clip.none,
                      itemCount: store.galeria.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                      itemBuilder: (context, index) {
                        final url = resolveImagemUrl(store.galeria[index]);
                        return Container(
                          width: 140.0,
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16.0), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: url != null
                                ? Image.network(url, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image, color: Colors.grey, size: 32.0)))
                                : const Center(child: Icon(LucideIcons.image, color: Colors.grey, size: 32.0)),
                          ),
                        );
                      },
                    ),
                  ),

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
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
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
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String motivoSelecionado = 'Outro';
            bool isSubmitting = false;
            final DenunciaService denunciaService = DenunciaService();

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(AppSpacing.lg),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return SingleChildScrollView(
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
                                  const Icon(LucideIcons.flag, color: ColorsPalette.redComponents, size: 20),
                                  const SizedBox(width: 8),
                                  Text("Denunciar loja", style: AppText.titulo(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              IconButton(icon: const Icon(LucideIcons.x, size: 20, color: Colors.grey), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text("Seu relatório será analisado pela nossa equipe. Obrigado por manter a plataforma segura.", style: AppText.corpo(context).copyWith(color: Colors.brown.shade800, fontSize: 13)),
                          const SizedBox(height: AppSpacing.lg),
                          Text("Motivo", style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0), border: Border.all(color: ColorsPalette.redComponents.withValues(alpha: 0.3), width: 1.2)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: motivoSelecionado,
                                isExpanded: true,
                                dropdownColor: const Color(0xFFFCF9F9),
                                borderRadius: BorderRadius.circular(12.0),
                                icon: const Icon(LucideIcons.chevronDown, size: 18, color: Colors.black87),
                                items: ['Conteúdo inapropriado', 'Fraude ou golpe', 'Informações falsas', 'Spam', 'Outro'].map((String motivo) {
                                  return DropdownMenuItem<String>(value: motivo, child: Text(motivo, style: AppText.corpo(context).copyWith(color: Colors.black87)));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) setModalState(() => motivoSelecionado = newValue);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar", style: AppText.botao(context).copyWith(color: Colors.brown.shade800))),
                              const SizedBox(width: AppSpacing.sm),
                              ElevatedButton(
                                onPressed: isSubmitting ? null : () async {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await denunciaService.create(
                                      lojaId: lojaId,
                                      motivo: motivoSelecionado,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Denúncia enviada."), backgroundColor: Colors.green));
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    setModalState(() => isSubmitting = false);
                                    Navigator.pop(context);
                                    if (e.toString().contains('409') || (e is AppException && e.statusCode == 409)) {
                                      UIUtils.showErrorDialog(context, "Você já possui uma denúncia registrada para este comércio. Acesse seu perfil para gerenciá-la.");
                                    } else {
                                      UIUtils.showErrorDialog(context, "Erro ao enviar denúncia. Tente novamente.");
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: ColorsPalette.redComponents, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill))),
                                child: isSubmitting
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Enviar denúncia", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
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
