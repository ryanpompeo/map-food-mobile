import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/rating_stars.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';

/// Uma avaliação, na lista pública da loja ou no histórico do próprio usuário.
///
/// O mesmo card serve aos dois lugares, em larguras diferentes — e era daí que
/// vinha o estouro de linha: dentro do card "Suas avaliações anteriores" ele
/// perde dois paddings de cada lado, e o par nome + data, que cabia na lista
/// pública, não cabia mais. Duas correções, uma de layout e uma de conteúdo:
///
/// - o nome é `Expanded` com reticências, então nome longo encurta em vez de
///   empurrar a data para fora;
/// - no histórico próprio ([compact]), autor e avatar **saem**. O nome ali é
///   sempre o de quem está lendo, e a seção já diz isso no título — repetir
///   consumia justamente a largura que faltava.
class ReviewCard extends StatelessWidget {
  final AvaliacaoModel review;

  /// Versão sem autor, para o histórico do próprio usuário.
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
        // Dentro de uma seção que já rola, o card não precisa levantar do
        // papel — a superfície rebaixada agrupa sem virar um objeto solto.
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

/// Foto de quem avaliou, com a inicial do nome como fallback.
///
/// A inicial deixou de ser o único estado possível: a foto do consumidor vem
/// no mesmo JSON da avaliação (ver `ConsumidorResumido.imagemUrl`) e agora é
/// desenhada quando existe. O fallback continua valendo para quem nunca
/// enviou foto, para a foto que falhou em carregar e para o histórico próprio,
/// onde o autor é sempre quem lê.
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
          // O nome do autor é lido pelo Text ao lado; anunciar a foto de novo
          // repetiria a mesma informação no leitor de tela.
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
          // brandContent e não brand puro: sobre o vermelho a 12% (que é quase
          // a superfície do card) o vermelho cheio reprova em contraste no
          // tema escuro.
          style: AppText.bodyStrong(context).copyWith(
            color: context.mapColors.brandContent,
          ),
        ),
      ),
    );
  }
}

/// Data relativa ("Ontem", "Há 3 semanas"). Data absoluta numa avaliação diz
/// pouco: o que interessa é se a experiência é recente.
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
