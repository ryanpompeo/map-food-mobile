import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/reviews/data/models/minha_avaliacao_model.dart';
import 'package:map_food/features/reviews/data/services/rating_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class ConsumerReviewPage extends StatefulWidget {
  const ConsumerReviewPage({super.key});

  @override
  State<ConsumerReviewPage> createState() => _ConsumerReviewPageState();
}

class _ConsumerReviewPageState extends State<ConsumerReviewPage> {
  final _ratingService = RatingService();

  bool _isLoading = true;
  String? _errorMessage;
  List<MinhaAvaliacaoModel> _avaliacoes = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final session = await AuthStorage.getSession();
      if (session == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final avaliacoes = await _ratingService.getMyRatings(session.id);
      if (!mounted) return;
      setState(() {
        _avaliacoes = avaliacoes;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível carregar suas avaliações.';
      });
    }
  }

  void _abrirLoja(MinhaAvaliacaoModel avaliacao) {
    // Deep link "mínimo": StoreDetailsPage só precisa do id pra funcionar de
    // verdade (ratings, favoritos etc. são buscados de novo por id lá
    // dentro) — mas capa/descrição não vêm junto aqui, então aparecem vazias
    // até o usuário navegar por essa loja pela busca normal também.
    final storeStub = StoreDto(
      id: avaliacao.lojaId,
      nome: avaliacao.nomeLoja,
      statusLoja: 'ATIVA',
      categoria: '',
      isPartial: true,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MoreInfoStorePage(store: storeStub)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Minhas Avaliações",
          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft, color: ColorsPalette.redComponents),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents))
            : _errorMessage != null
                ? _ErrorState(message: _errorMessage!, onRetry: _carregar)
                : _avaliacoes.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: _carregar,
                        color: ColorsPalette.redComponents,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: _avaliacoes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) => _AvaliacaoCard(
                            avaliacao: _avaliacoes[index],
                            onTapLoja: () => _abrirLoja(_avaliacoes[index]),
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _AvaliacaoCard extends StatelessWidget {
  final MinhaAvaliacaoModel avaliacao;
  final VoidCallback onTapLoja;

  const _AvaliacaoCard({required this.avaliacao, required this.onTapLoja});

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nome da loja clicável — Deep Link pra StoreDetailsPage.
              Expanded(
                child: InkWell(
                  onTap: onTapLoja,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          avaliacao.nomeLoja,
                          style: AppText.corpo(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorsPalette.redComponents,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(LucideIcons.externalLink, size: 14, color: ColorsPalette.redComponents),
                    ],
                  ),
                ),
              ),
              Text(_formatDate(avaliacao.dataCriacao), style: AppText.legenda(context).copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < avaliacao.nota ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
          if (avaliacao.comentario != null && avaliacao.comentario!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              avaliacao.comentario!,
              style: AppText.corpo(context).copyWith(color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(LucideIcons.star, color: ColorsPalette.redComponents, size: 42),
            ),
            const SizedBox(height: 20),
            Text("Nenhuma avaliação ainda", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "As lojas que você avaliar aparecerão aqui.",
              textAlign: TextAlign.center,
              style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wifiOff, size: 48, color: ColorsPalette.greyText),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPalette.redComponents,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
