import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/review_card.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/section_header.dart';

/// As avaliações públicas da loja: cabeçalho, filtro por nota e a lista.
///
/// O estado de "recolhida" e o filtro por estrelas moravam na página, junto com
/// o carregamento da capa, da galeria e do resumo da loja. Trazidos para cá,
/// tocar num chip de filtro deixa de reconstruir a tela inteira — e a página
/// volta a ser só composição.
class StoreReviewsSection extends StatefulWidget {
  final List<AvaliacaoModel> avaliacoes;
  final bool carregando;

  /// Quantas avaliações a loja tem, segundo o dado que a página já tinha em
  /// mãos antes de a lista chegar.
  ///
  /// O cabeçalho dizia "Carregando..." durante a busca — uma informação que o
  /// app já possuía desde a listagem. Mostrar "12 avaliações" de cara, e só
  /// então preencher a lista, é a diferença entre uma tela que está trabalhando
  /// e uma que parece vazia.
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
  /// Teto de escala da faixa de filtros. Tira horizontal dentro da lista de
  /// avaliações: crescer sem limite empurraria as próprias avaliações para
  /// fora da tela, que é o conteúdo que o filtro existe para organizar.
  static const double _tetoEscalaFiltros = 1.5;

  /// `null` significa "todas". A API sempre devolve a lista completa; o filtro
  /// é só client-side.
  int? _filtroEstrelas;

  bool _expandida = true;

  List<AvaliacaoModel> get _filtradas => _filtroEstrelas == null
      ? widget.avaliacoes
      : widget.avaliacoes.where((r) => r.nota == _filtroEstrelas).toList();

  @override
  Widget build(BuildContext context) {
    // Durante a carga vale o total que a página já conhecia; depois, a lista.
    final total = widget.carregando ? widget.totalConhecido : widget.avaliacoes.length;
    final temLista = !widget.carregando && widget.erro == null && total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Avaliações',
          // "Carregando..." só quando de fato não se sabe o número — nas telas
          // que chegam aqui sem a agregação do backend.
          subtitle: widget.carregando && total == 0
              ? 'Carregando...'
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
                      _buildFiltro(context),
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
        title: 'Nada com $_filtroEstrelas estrelas',
        description: 'Toque em "Todas" para ver as demais avaliações.',
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

  Widget _buildFiltro(BuildContext context) {
    // O teto entra nos dois lugares de propósito: na altura da faixa e na
    // escala do texto dentro dela. Limitar só um dos dois é o que produz ou
    // texto cortado (faixa parada, texto crescendo) ou faixa com sobra.
    return MaxTextScale(
      max: _tetoEscalaFiltros,
      child: SizedBox(
        height: escalaComTeto(context, 38.0, teto: _tetoEscalaFiltros),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            AppChoiceChip(
              label: 'Todas',
              selected: _filtroEstrelas == null,
              onTap: () => setState(() => _filtroEstrelas = null),
            ),
            for (var estrelas = 5; estrelas >= 1; estrelas--) ...[
              const SizedBox(width: Spacing.sm),
              AppChoiceChip(
                label: '$estrelas',
                icon: AppIcons.starFill,
                iconColor: MfColor.rating,
                selected: _filtroEstrelas == estrelas,
                onTap: () => setState(() => _filtroEstrelas = estrelas),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
