import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

class ActivityPoint {
  final String label;
  final int value;

  const ActivityPoint({required this.label, required this.value});
}

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

    final indicePico = points.indexWhere((p) => p.value == maxValor);
    final pico = coords[indicePico];
    canvas.drawCircle(pico, 6.0, Paint()..color = linha);
    canvas.drawCircle(pico, 2.5, Paint()..color = balaoTexto);
    _desenharBalao(canvas, size, pico, '$maxValor');
  }

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
