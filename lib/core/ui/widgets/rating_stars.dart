import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// Fileira de estrelas de leitura (não é seletor — para avaliar, ver a tela
/// de avaliação).
///
/// Existe porque cada tela desenhava a própria fileira com
/// `Icons.star_rounded`/`Icons.star_border_rounded` do Material: dentro de um
/// card cheio de ícones Phosphor, a estrela do Material entrega outro peso de
/// traço e outro raio de canto — o tipo de mistura que o app acabou de
/// eliminar em todo o resto da iconografia.
///
/// A estrela cheia usa a variante **Fill** e a vazia a **Regular**: o
/// contorno vazado marca a posição sem competir com as preenchidas, que é
/// justamente o que a versão anterior perdia ao usar dois ícones de peso
/// parecido.
class RatingStars extends StatelessWidget {
  /// Nota de 0 a [max]. Frações são arredondadas para baixo — meia estrela
  /// só entra quando o backend passar a devolver meia nota por avaliação
  /// individual (hoje `nota` é inteiro).
  final num nota;

  final double size;
  final int max;

  /// Rótulo lido por leitores de tela no lugar das cinco estrelas soltas.
  /// `null` usa "Nota X de Y".
  final String? semanticsLabel;

  const RatingStars({
    super.key,
    required this.nota,
    this.size = AppIconSize.sm,
    this.max = 5,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? 'Nota ${nota.toStringAsFixed(0)} de $max',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < max; i++)
            Icon(
              i < nota ? AppIcons.starFill : AppIcons.star,
              size: size,
              color: i < nota
                  ? MfColor.rating
                  // Estrela vazia em amarelo cheio parecia "meio preenchida";
                  // o contorno translúcido lê como trilho, não como nota.
                  : MfColor.rating.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }
}

/// Selo com a nota média (`4,8`) sobre fundo amarelo suave.
///
/// [nota] nula é loja sem avaliação: mostra "Novo" em vez de `0,0` — zero é
/// uma nota ruim, ausência de nota não é.
class RatingScorePill extends StatelessWidget {
  final double? nota;

  /// Compacta para caber em cabeçalho de card.
  final bool dense;

  const RatingScorePill({super.key, required this.nota, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final semNota = nota == null;
    final texto = semNota ? 'Novo' : nota!.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? Spacing.sm : Spacing.md,
        vertical: dense ? Spacing.xs : 6.0,
      ),
      decoration: BoxDecoration(
        color: MfColor.rating.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            semNota ? AppIcons.star : AppIcons.starFill,
            size: dense ? 13.0 : AppIconSize.md,
            color: MfColor.rating,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            texto,
            // ratingText (não `rating` puro): amarelo sobre amarelo a 15%
            // não passa em contraste.
            style: AppText.numeric(context, size: dense ? 12.0 : 15.0)
                .copyWith(color: MfColor.ratingText, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
