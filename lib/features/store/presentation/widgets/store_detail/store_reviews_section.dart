import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/presentation/widgets/filtro_de_estrelas.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/review_card.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/section_header.dart';

class StoreReviewsSection extends StatefulWidget {
  final List<AvaliacaoModel> avaliacoes;
  final bool carregando;

  final int totalConhecido;

  final String? erro;
  final VoidCallback onRetry;

  const StoreReviewsSection({
    super.key,
    required this.avaliacoes,
    required this.carregando,
    this.totalConhecido = 0,
    required this.erro,
    required this.onRetry,
  });

  @override
  State<StoreReviewsSection> createState() => _StoreReviewsSectionState();
}

class _StoreReviewsSectionState extends State<StoreReviewsSection> {
  int? _filtroEstrelas;

  bool _expandida = true;

  List<AvaliacaoModel> get _filtradas => _filtroEstrelas == null
      ? widget.avaliacoes
      : widget.avaliacoes.where((r) => r.nota == _filtroEstrelas).toList();

  @override
  Widget build(BuildContext context) {
    final total = widget.carregando ? widget.totalConhecido : widget.avaliacoes.length;
    final temLista = !widget.carregando && widget.erro == null && total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Avaliações',
          subtitle: widget.carregando && total == 0
              ? 'Carregando'
              : '$total ${total == 1 ? 'avaliação' : 'avaliações'}',
          expanded: _expandida,
          onToggle: () => setState(() => _expandida = !_expandida),
        ),
        AnimatedSize(
          duration: Motion.medium,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !_expandida
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (temLista) ...[
                      const SizedBox(height: Spacing.base),
                      FiltroDeEstrelas(
                        selecionado: _filtroEstrelas,
                        onSelecionar: (valor) => setState(() => _filtroEstrelas = valor),
                      ),
                    ],
                    const SizedBox(height: Spacing.base),
                    _buildConteudo(context),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildConteudo(BuildContext context) {
    if (widget.carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
          child: CircularProgressIndicator(color: MfColor.brand, strokeWidth: 2.5),
        ),
      );
    }

    if (widget.erro != null) {
      return EmptyState(
        icon: AppIcons.warningCircle,
        title: 'Não foi possível carregar',
        description: widget.erro,
        actionLabel: 'Tentar novamente',
        onAction: widget.onRetry,
        tone: EmptyStateTone.error,
        dense: true,
      );
    }

    if (widget.avaliacoes.isEmpty) {
      return const EmptyState(
        icon: AppIcons.chatCircle,
        title: 'Nenhuma avaliação ainda',
        description: 'Seja o primeiro a avaliar este comércio!',
        dense: true,
      );
    }

    final filtradas = _filtradas;
    if (filtradas.isEmpty) {
      return EmptyState(
        icon: AppIcons.star,
        title: 'Nada com ${rotuloEstrelas(_filtroEstrelas!)}',
        description: 'Toque em "Todas" para ver as demais avaliações',
        actionLabel: 'Ver todas',
        onAction: () => setState(() => _filtroEstrelas = null),
        dense: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final review in filtradas) ReviewCard(review: review)],
    );
  }
}
