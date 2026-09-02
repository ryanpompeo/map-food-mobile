import 'dart:math' as math;

import 'package:flutter/material.dart';

double fatorDeEscala(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(100.0) / 100.0;

double escalaComTeto(BuildContext context, double base, {double teto = 1.6}) {
  return math.min(MediaQuery.textScalerOf(context).scale(base), base * teto);
}

double escalaIcone(BuildContext context, double base, {double teto = 1.6}) =>
    escalaComTeto(context, base, teto: teto);

int linhasParaRotulo(BuildContext context, {int base = 1, int maximo = 2}) {
  return fatorDeEscala(context) > 1.3 ? maximo : base;
}

class MaxTextScale extends StatelessWidget {
  final double max;
  final Widget child;

  const MaxTextScale({super.key, required this.max, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(maxScaleFactor: max),
      ),
      child: child,
    );
  }
}
