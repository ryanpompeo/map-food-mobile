import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ferramentas para o app acompanhar o tamanho de fonte escolhido no sistema
/// (Dynamic Type no iOS, "Tamanho da fonte" no Android).
///
/// ## O problema que elas resolvem
///
/// O Flutter escala **texto** sozinho, e mais nada. Três consequências, que
/// são exatamente as três formas de um layout quebrar em escala alta:
///
/// 1. `Icon(size: 20)` continua com 20 logo ao lado de um texto que dobrou —
///    o ícone parece ter encolhido. Use [escalaIcone].
/// 2. Uma caixa de altura fixa (`height: 52`) não cresce junto com o texto que
///    ela contém, e o texto vaza. A correção é `minHeight`.
/// 3. Alguns lugares **não podem** crescer — uma faixa horizontal de chips
///    sobre o mapa, a bottom bar. Para esses, [MaxTextScale] limita a escala
///    só ali dentro, em vez de limitar o app inteiro.
///
/// O ponto do item 3 é esse: o app hoje trava a escala em 1,5× globalmente
/// (`main.dart`), o que impede quem precisa de 2× de chegar lá em **qualquer**
/// tela. Trocar esse teto global por tetos locais nos poucos pontos que
/// realmente não esticam é o que permite liberar o resto.

/// Fator de escala de texto atualmente em vigor.
double fatorDeEscala(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(100.0) / 100.0;

/// Escala [base] junto com o texto, sem passar de `base * teto`.
///
/// Serve para qualquer dimensão que precise acompanhar o texto **sem** poder
/// crescer indefinidamente — altura de faixa horizontal, diâmetro de círculo
/// de ilustração, lado de um cartão numa lista horizontal.
double escalaComTeto(BuildContext context, double base, {double teto = 1.6}) {
  return math.min(MediaQuery.textScalerOf(context).scale(base), base * teto);
}

/// Tamanho de ícone que acompanha a escala do texto, com teto.
///
/// O teto existe porque ícone não é texto: dobrar um ícone de 24 numa linha
/// com ícone + rótulo + caret come a largura que o rótulo precisa, e o
/// resultado é pior do que o ícone ficar um pouco menor que o texto. 1,6× é o
/// ponto em que o ícone ainda acompanha visualmente sem dominar a linha.
///
/// Use apenas em ícones que **acompanham texto**. Ícone solto dentro de um
/// botão circular (controles do mapa, bottom bar) não deve escalar: ele não
/// tem texto ao lado para acompanhar, e crescer só quebraria o círculo.
double escalaIcone(BuildContext context, double base, {double teto = 1.6}) =>
    escalaComTeto(context, base, teto: teto);

/// Número de linhas para um rótulo curto que hoje cabe em uma.
///
/// Em escala alta, manter `maxLines: 1` só troca o vazamento por um "…" —
/// a informação some do mesmo jeito. Soltar uma segunda linha preserva o
/// rótulo, e a caixa acompanha porque passou a usar `minHeight`.
int linhasParaRotulo(BuildContext context, {int base = 1, int maximo = 2}) {
  return fatorDeEscala(context) > 1.3 ? maximo : base;
}

/// Limita a escala de texto **dentro** desta subárvore.
///
/// Para superfícies que genuinamente não podem crescer: faixas horizontais de
/// altura fixa, barras de navegação, sobreposições ancoradas ao mapa. É o
/// substituto cirúrgico do teto global — em vez de negar 2× ao app inteiro,
/// nega só onde crescer quebraria de verdade.
///
/// Não use para fugir de um layout que dá para consertar. Todo uso deste
/// widget é uma dívida assumida, e merece um comentário dizendo por quê.
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
