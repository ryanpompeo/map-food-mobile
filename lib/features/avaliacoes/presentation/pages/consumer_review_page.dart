import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class ConsumerReviewPage extends StatefulWidget {
  const ConsumerReviewPage({super.key});

  @override
  State<ConsumerReviewPage> createState() => _ConsumerReviewPageState();
}

class _ConsumerReviewPageState extends State<ConsumerReviewPage> {
  final _avaliacaoService = AvaliacaoService();
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
      final avaliacoes = await _avaliacaoService.getMinhasAvaliacoes();
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
      unawaited(Navigator.push(
          context, appPageRoute(builder: (_) => MoreInfoStorePage(store: store))));
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, "Não foi possível abrir esta loja.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        backgroundColor: context.mapColors.mainBackground,
        elevation: 0,
        foregroundColor: context.mapColors.mainBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Minhas Avaliações",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            AppIcons.caretLeft,
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
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) => _buildItem(_avaliacoes[index]),
                      ),
      ),
    );
  }

  Widget _buildItem(AvaliacaoModel avaliacao) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: avaliacao.lojaId != null ? () => _abrirLoja(avaliacao.lojaId!) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.mapColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.mapColors.border),
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
              // Um tom abaixo do cardSurface do card que envolve esta
              // miniatura (mesmo padrão de superfície aninhada dos lotes anteriores).
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: context.mapColors.mainBackground,
              ),
              child: resolveImagemUrl(avaliacao.lojaImagemUrl) != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.network(
                        resolveImagemUrl(avaliacao.lojaImagemUrl)!,
                        fit: BoxFit.cover,
                        // Decorativa: o nome da loja já aparece como texto ao lado.
                        excludeFromSemantics: true,
                        // Só cacheWidth: com os dois definidos o decoder
                        // ignora a proporção original e estica a imagem.
                        cacheWidth: (56.0 * MediaQuery.devicePixelRatioOf(context)).round(),
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(AppIcons.image, color: context.mapColors.iconMuted),
                      ),
                    )
                  : Icon(AppIcons.image, color: context.mapColors.iconMuted),
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
                    style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        AppIcons.star,
                        size: 14,
                        color: i < avaliacao.nota ? ColorsPalette.ratingStar : context.mapColors.border,
                      );
                    }),
                  ),
                  if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      avaliacao.comentario!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.legenda(context),
                    ),
                  ],
                  if (_formatDate(avaliacao.dataAvaliacao).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(avaliacao.dataAvaliacao),
                      style: AppText.legenda(context),
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
    return const Center(
      child: EmptyState(
        icon: AppIcons.star,
        title: "Nenhuma avaliação ainda",
        description: "As avaliações que você fizer nos comércios aparecerão aqui.",
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: EmptyState(
        icon: AppIcons.wifiSlash,
        title: 'Não foi possível carregar',
        description: _errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _carregarAvaliacoes,
        tone: EmptyStateTone.error,
      ),
    );
  }
}
