import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/core/ui/widgets/rating_stars.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';

/// O que os clientes disseram sobre a loja, do ponto de vista de quem recebe.
///
/// A nota média vem do backend (`GET /lojas/{id}/resumo`), não de uma conta
/// feita sobre a lista carregada aqui — a lista é paginável no futuro e a
/// média calculada no cliente passaria a divergir da que o consumidor vê.
class StoreReviewsSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            if (!carregando) RatingScorePill(nota: media),
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
          )
        else
          for (final avaliacao in avaliacoes)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: _CardAvaliacao(avaliacao: avaliacao),
            ),
      ],
    );
  }

  static String _resumo(int total) => switch (total) {
        0 => 'O que dizem sobre você',
        1 => '1 avaliação recebida',
        _ => '$total avaliações recebidas',
      };
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
