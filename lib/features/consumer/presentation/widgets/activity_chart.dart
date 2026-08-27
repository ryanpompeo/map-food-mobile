import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Um ponto da série de atividade: quantas avaliações o consumidor fez no
/// intervalo rotulado por [label].
class ActivityPoint {
  final String label;
  final int value;

  const ActivityPoint({required this.label, required this.value});
}

/// Gráfico de linha da atividade do consumidor. `CustomPainter` em vez de
/// um pacote de charts de propósito: é uma série só, sem eixos, zoom ou
/// tooltip — não justifica uma dependência nova no `pubspec.yaml`.
///
/// O ponto de maior valor ganha um marcador e um balão com o número, que é
/// o que dá leitura imediata ao gráfico sem eixo Y desenhado.
class ActivityChart extends StatelessWidget {
  final List<ActivityPoint> points;

  const ActivityChart({super.key, required this.points});

  static const double _height = 132.0;

  @override
  Widget build(BuildContext context) {
    final vazio = points.every((p) => p.value == 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _height,
          child: vazio
              ? Center(
                  child: Text(
                    'Nenhuma avaliação neste período',
                    style: AppText.legenda(context),
                  ),
                )
              : RepaintBoundary(
                  child: CustomPaint(
                    painter: _ActivityChartPainter(
                      points: points,
                      linha: ColorsPalette.redComponents,
                      balaoTexto: ColorsPalette.white,
                      textDirection: Directionality.of(context),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            for (final point in points)
              Expanded(
                child: Text(
                  point.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: AppText.legenda(context).copyWith(fontSize: 10.0, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActivityChartPainter extends CustomPainter {
  final List<ActivityPoint> points;
  final Color linha;
  final Color balaoTexto;
  final TextDirection textDirection;

  _ActivityChartPainter({
    required this.points,
    required this.linha,
    required this.balaoTexto,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Topo reservado pro balão do valor máximo — sem essa margem ele sairia
    // cortado quando o pico está na primeira linha do gráfico.
    const topoReservado = 26.0;
    final alturaUtil = size.height - topoReservado;
    final maxValor = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final divisor = maxValor == 0 ? 1 : maxValor;
    final passo = size.width / (points.length - 1);

    final coords = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(
          i * passo,
          topoReservado + alturaUtil - (points[i].value / divisor) * alturaUtil,
        ),
    ];

    final caminho = _linhaSuave(coords);

    // Área sob a curva, esvaindo pra transparente — mesma leitura de
    // "volume" da referência sem precisar de grade de fundo.
    final area = Path.from(caminho)
      ..lineTo(coords.last.dx, size.height)
      ..lineTo(coords.first.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [linha.withValues(alpha: 0.18), linha.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      caminho,
      Paint()
        ..color = linha
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Marcador + balão no pico da série.
    final indicePico = points.indexWhere((p) => p.value == maxValor);
    final pico = coords[indicePico];
    canvas.drawCircle(pico, 6.0, Paint()..color = linha);
    canvas.drawCircle(pico, 2.5, Paint()..color = balaoTexto);
    _desenharBalao(canvas, size, pico, '$maxValor');
  }

  /// Curva por Bézier cúbica com pontos de controle no meio horizontal de
  /// cada par — dá a linha arredondada da referência sem "estourar" acima do
  /// pico, que é o que acontece com interpolação Catmull-Rom ingênua.
  Path _linhaSuave(List<Offset> coords) {
    final path = Path()..moveTo(coords.first.dx, coords.first.dy);
    for (var i = 0; i < coords.length - 1; i++) {
      final atual = coords[i];
      final proximo = coords[i + 1];
      final meio = (atual.dx + proximo.dx) / 2;
      path.cubicTo(meio, atual.dy, meio, proximo.dy, proximo.dx, proximo.dy);
    }
    return path;
  }

  void _desenharBalao(Canvas canvas, Size size, Offset pico, String texto) {
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(color: balaoTexto, fontSize: 11.0, fontWeight: FontWeight.w800),
      ),
      textDirection: textDirection,
    )..layout();

    final largura = tp.width + 16.0;
    const altura = 20.0;
    // Trava nas bordas pra o balão nunca vazar do card quando o pico é o
    // primeiro ou o último ponto da série.
    final left = (pico.dx - largura / 2).clamp(0.0, size.width - largura);
    final rect = Rect.fromLTWH(left, pico.dy - altura - 10.0, largura, altura);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10.0)),
      Paint()..color = linha,
    );
    tp.paint(canvas, Offset(rect.left + 8.0, rect.top + (altura - tp.height) / 2));
  }

  @override
  bool shouldRepaint(_ActivityChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.linha != linha;
}

/// Pílula de variação percentual entre o período atual e o anterior — o
/// "+15%" que fica ao lado do número grande na referência.
class DeltaBadge extends StatelessWidget {
  final int percentual;

  const DeltaBadge({super.key, required this.percentual});

  @override
  Widget build(BuildContext context) {
    final positivo = percentual >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: positivo
            ? ColorsPalette.redComponents.withValues(alpha: 0.12)
            : context.mapColors.border,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Text(
        '${positivo ? '+' : ''}$percentual%',
        style: AppText.legenda(context).copyWith(
          fontSize: 11.0,
          fontWeight: FontWeight.w800,
          color: positivo ? ColorsPalette.redComponents : context.mapColors.secondaryText,
        ),
      ),
    );
  }
}
