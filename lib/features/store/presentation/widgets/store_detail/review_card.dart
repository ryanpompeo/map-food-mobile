import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/rating_stars.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';

class ReviewCard extends StatelessWidget {
  final AvaliacaoModel review;

  final bool compact;

  const ReviewCard({super.key, required this.review, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final data = _formatarData(review.dataAvaliacao);
    final comentario = review.comentario?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: AppCard(
        radius: Radii.lg,
        elevation: compact ? AppCardElevation.flat : AppCardElevation.raised,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              Row(
                children: [
                  RatingStars(nota: review.nota),
                  const Spacer(),
                  Text(data, style: AppText.caption(context)),
                ],
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _Avatar(
                          nome: review.consumidor?.nome,
                          imagemUrl: review.consumidor?.imagemUrl,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            review.consumidor?.nome ?? 'Usuário',
                            style: AppText.bodyStrong(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(data, style: AppText.caption(context)),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              RatingStars(nota: review.nota),
            ],
            if (comentario != null && comentario.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                comentario,
                style: AppText.body(context).copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? nome;
  final String? imagemUrl;

  const _Avatar({required this.nome, this.imagemUrl});

  static const double _raio = 16.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _raio * 2,
      height: _raio * 2,
      child: ClipOval(
        child: AppNetworkImage(
          path: imagemUrl,
          displayWidth: _raio * 2,
          fallback: _Inicial(nome: nome),
        ),
      ),
    );
  }
}

class _Inicial extends StatelessWidget {
  final String? nome;

  const _Inicial({required this.nome});

  @override
  Widget build(BuildContext context) {
    final inicial = (nome != null && nome!.isNotEmpty) ? nome![0].toUpperCase() : '?';

    return ColoredBox(
      color: MfColor.brand.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          inicial,
          style: AppText.bodyStrong(context).copyWith(
            color: context.mapColors.brandContent,
          ),
        ),
      ),
    );
  }
}

String _formatarData(String? bruta) {
  if (bruta == null) return '';
  try {
    final dt = DateTime.parse(bruta).toLocal();
    final dias = DateTime.now().difference(dt).inDays;
    if (dias <= 0) return 'Hoje';
    if (dias == 1) return 'Ontem';
    if (dias < 7) return 'Há $dias dias';
    if (dias < 30) return 'Há ${(dias / 7).floor()} semanas';
    if (dias < 365) return 'Há ${(dias / 30).floor()} meses';
    return 'Há ${(dias / 365).floor()} anos';
  } catch (_) {
    return '';
  }
}
