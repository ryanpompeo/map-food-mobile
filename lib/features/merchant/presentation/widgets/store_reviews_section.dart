import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/core/ui/widgets/rating_stars.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';

/// O que os clientes disseram sobre a loja, do ponto de vista de quem recebe.
///
/// A nota média vem do backend (`GET /lojas/{id}/resumo`), não de uma conta
/// feita sobre a lista carregada aqui — a lista é paginável no futuro e a
/// média calculada no cliente passaria a divergir da que o consumidor vê.
///
/// **Chega recolhida.** O painel é a tela de operação da loja, e a lista
/// inteira de avaliações empurrava "Configurações avançadas" para fora do
/// alcance de qualquer loja com histórico — quem abre o painel quer saber
/// *como está* a nota, não reler cada comentário. O resumo (média + total)
/// fica sempre visível; a lista é um toque.
class StoreReviewsSection extends StatefulWidget {
  final List<AvaliacaoModel> avaliacoes;
  final bool carregando;

  /// Média agregada. `null` quando a loja ainda não tem nota.
  final double? media;

  const StoreReviewsSection({
    super.key,
    required this.avaliacoes,
    required this.carregando,
    required this.media,
  });

  @override
  State<StoreReviewsSection> createState() => _StoreReviewsSectionState();
}

class _StoreReviewsSectionState extends State<StoreReviewsSection> {
  bool _expandida = false;

  @override
  Widget build(BuildContext context) {
    final avaliacoes = widget.avaliacoes;
    final carregando = widget.carregando;
    // Vazio não tem o que expandir: o estado vazio é curto e vale mais visível
    // do que escondido atrás de um toque que revelaria "nada aqui".
    final temListaParaExpandir = !carregando && avaliacoes.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Avaliações', style: AppText.h2(context)),
                  const SizedBox(height: 2),
                  Text(
                    carregando
                        ? 'Carregando o que dizem sobre você...'
                        : _resumo(avaliacoes.length),
                    style: AppText.secondary(context),
                  ),
                ],
              ),
            ),
            if (!carregando) RatingScorePill(nota: widget.media),
          ],
        ),
        const SizedBox(height: Spacing.base),

        if (carregando)
          const _SkeletonAvaliacoes()
        else if (avaliacoes.isEmpty)
          EmptyState(
            dense: true,
            icon: AppIcons.chatCircle,
            title: 'Nenhuma avaliação ainda',
            description: 'Assim que um cliente avaliar sua loja, o comentário '
                'aparece aqui.',
          ),

        if (temListaParaExpandir) ...[
          _BotaoExpandir(
            expandida: _expandida,
            total: avaliacoes.length,
            onTap: () => setState(() => _expandida = !_expandida),
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_expandida
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      const SizedBox(height: Spacing.base),
                      for (final avaliacao in avaliacoes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.md),
                          child: _CardAvaliacao(avaliacao: avaliacao),
                        ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  static String _resumo(int total) => switch (total) {
        0 => 'O que dizem sobre você',
        1 => '1 avaliação recebida',
        _ => '$total avaliações recebidas',
      };
}

/// Linha de "ver/ocultar" com a contagem no rótulo.
///
/// O número no botão é o que faz a seção recolhida não parecer vazia: sem ele,
/// "Ver avaliações" some no meio da página como um link qualquer.
class _BotaoExpandir extends StatelessWidget {
  final bool expandida;
  final int total;
  final VoidCallback onTap;

  const _BotaoExpandir({
    required this.expandida,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final rotulo = expandida
        ? 'Ocultar avaliações'
        : (total == 1 ? 'Ver a avaliação' : 'Ver as $total avaliações');

    return SemanticTapArea(
      label: rotulo,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // 48 de altura mínima: é um alvo de toque de largura inteira, e o
        // conteúdo é uma linha de texto só.
        constraints: const BoxConstraints(minHeight: 48.0),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyStrong(context).copyWith(color: colors.brandContent),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            // Roda com a expansão: a mesma seta serve para os dois estados e
            // marca o sentido do movimento.
            AnimatedRotation(
              turns: expandida ? 0.5 : 0.0,
              duration: Motion.medium,
              curve: Curves.easeInOut,
              child: Icon(AppIcons.caretDown, size: AppIconSize.sm, color: colors.brandContent),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAvaliacao extends StatelessWidget {
  final AvaliacaoModel avaliacao;

  const _CardAvaliacao({required this.avaliacao});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final nome = avaliacao.consumidor?.nome ?? 'Usuário';
    final comentario = avaliacao.comentario?.trim();

    return AppCard(
      elevation: AppCardElevation.flat,
      bordered: false,
      radius: Radii.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                // Um degrau acima do `surfaceAlt` do card que envolve este
                // avatar — superfície aninhada precisa se destacar do pai.
                backgroundColor: colors.surface,
                child: Text(
                  nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                  style: AppText.bodyStrong(context),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title(context),
                    ),
                    const SizedBox(height: 3),
                    RatingStars(nota: avaliacao.nota, size: 14),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                _tempoRelativo(avaliacao.dataAvaliacao),
                style: AppText.caption(context),
              ),
            ],
          ),
          if (comentario != null && comentario.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text(
              comentario,
              style: AppText.body(context).copyWith(
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _tempoRelativo(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final dias = DateTime.now().difference(dt).inDays;
      return switch (dias) {
        0 => 'Hoje',
        1 => 'Ontem',
        < 7 => 'Há $dias dias',
        < 30 => 'Há ${dias ~/ 7} sem',
        < 365 => 'Há ${dias ~/ 30} meses',
        _ => 'Há ${dias ~/ 365} anos',
      };
    } catch (_) {
      return '';
    }
  }
}

/// Dois cards fantasma com a forma real do conteúdo. Um spinner centralizado
/// não diz o que está vindo e faz a página saltar de altura quando os cards
/// finalmente chegam.
class _SkeletonAvaliacoes extends StatelessWidget {
  const _SkeletonAvaliacoes();

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    Widget barra(double largura, double altura) => Container(
          width: largura,
          height: altura,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
        );

    return Column(
      children: [
        for (int i = 0; i < 2; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: AppCard(
              elevation: AppCardElevation.flat,
              bordered: false,
              radius: Radii.lg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 16, backgroundColor: colors.surface),
                  const SizedBox(width: Spacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      barra(120, 12),
                      const SizedBox(height: Spacing.sm),
                      barra(72, 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
