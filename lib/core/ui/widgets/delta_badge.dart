import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Como a pílula pinta a variação.
enum DeltaTone {
  /// Cor da marca no positivo, neutro no negativo. É o tratamento do painel de
  /// atividade do consumidor, onde o número mede o **próprio** uso do app:
  /// avaliar menos que no mês passado não é um resultado ruim, é só um número
  /// menor — pintá-lo de vermelho repreenderia quem está usando o app.
  marca,

  /// Verde sobe, vermelho desce. Para métrica de negócio, onde a direção tem
  /// valor de verdade: menos gente vendo a loja é uma má notícia, e a cor é o
  /// que faz isso ser lido num relance.
  semantico,

  /// O inverso: **verde desce, vermelho sobe**. Para o que é melhor quando
  /// diminui — denúncias, reclamações. Sem esta variante, "+40% de denúncias"
  /// apareceria em verde, com cara de conquista.
  semanticoInvertido,
}

/// Pílula de variação percentual entre o período atual e o anterior — o
/// "+15%" ao lado do número grande.
class DeltaBadge extends StatelessWidget {
  final int percentual;
  final DeltaTone tone;

  const DeltaBadge({
    super.key,
    required this.percentual,
    this.tone = DeltaTone.marca,
  });

  static (Color, Color) _bom(MapFoodColors colors) =>
      (colors.successContent, MfColor.success.withValues(alpha: 0.12));

  static (Color, Color) _ruim(MapFoodColors colors) =>
      (colors.brandContent, MfColor.danger.withValues(alpha: 0.12));

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final positivo = percentual >= 0;

    final (Color conteudo, Color fundo) = switch (tone) {
      DeltaTone.marca => positivo
          ? (MfColor.brand, MfColor.brand.withValues(alpha: 0.12))
          : (colors.textSecondary, colors.border),
      // `successContent`/`brandContent` e não os tons puros: são as versões
      // que passam em contraste como **texto** nos dois temas (ver
      // map_food_colors.dart).
      DeltaTone.semantico => positivo ? _bom(colors) : _ruim(colors),
      DeltaTone.semanticoInvertido => positivo ? _ruim(colors) : _bom(colors),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Text(
        '${positivo ? '+' : ''}$percentual%',
        style: AppText.legenda(context).copyWith(
          fontSize: 11.0,
          fontWeight: FontWeight.w800,
          color: conteudo,
        ),
      ),
    );
  }
}
