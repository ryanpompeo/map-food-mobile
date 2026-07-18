import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/reviews/data/models/avaliacao_model.dart';
import 'package:map_food/features/reviews/data/services/rating_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class ConsumerReviewPage extends StatefulWidget {
  const ConsumerReviewPage({super.key});

  @override
  State<ConsumerReviewPage> createState() => _ConsumerReviewPageState();
}

class _ConsumerReviewPageState extends State<ConsumerReviewPage> {
  final _ratingService = RatingService();
  final _storeService = StoreService();

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarAvaliacoes();
  }

  Future<void> _carregarAvaliacoes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final avaliacoes = await _ratingService.getMinhasAvaliacoes();
      if (mounted) {
        setState(() {
          _avaliacoes = avaliacoes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Não foi possível carregar suas avaliações. Tente novamente.';
        });
      }
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _abrirLoja(int lojaId) async {
    try {
      final store = await _storeService.getById(lojaId);
      if (!mounted) return;
      Navigator.push(context, appPageRoute(builder: (_) => MoreInfoStorePage(store: store)));
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, "Não foi possível abrir esta loja.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        foregroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Minhas Avaliações",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: ColorsPalette.redComponents),
              )
            : _errorMessage != null
                ? _buildErro()
                : _avaliacoes.isEmpty
                    ? _buildVazio()
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: _avaliacoes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) => _buildItem(_avaliacoes[index]),
                      ),
      ),
    );
  }

  Widget _buildItem(AvaliacaoModel avaliacao) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: avaliacao.lojaId != null ? () => _abrirLoja(avaliacao.lojaId!) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: resolveImagemUrl(avaliacao.lojaImagemUrl) != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        resolveImagemUrl(avaliacao.lojaImagemUrl)!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(PhosphorIconsRegular.image, color: Colors.grey.shade400),
                      ),
                    )
                  : Icon(PhosphorIconsRegular.image, color: Colors.grey.shade400),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avaliacao.lojaNome ?? 'Loja removida',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        PhosphorIconsRegular.star,
                        size: 14,
                        color: i < avaliacao.nota ? Colors.amber.shade600 : Colors.grey.shade300,
                      );
                    }),
                  ),
                  if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      avaliacao.comentario!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText),
                    ),
                  ],
                  if (_formatDate(avaliacao.dataAvaliacao).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(avaliacao.dataAvaliacao),
                      style: AppText.legenda(context).copyWith(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(PhosphorIconsRegular.star, color: Colors.amber.shade600, size: 42),
            ),
            const SizedBox(height: 20),
            Text(
              "Nenhuma avaliação ainda",
              style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              "As avaliações que você fizer nos comércios aparecerão aqui.",
              textAlign: TextAlign.center,
              style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(PhosphorIconsRegular.wifiSlash, size: 48, color: ColorsPalette.greyText),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _carregarAvaliacoes,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPalette.redComponents,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
