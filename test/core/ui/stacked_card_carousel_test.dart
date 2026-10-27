import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/widgets/stacked_card_carousel.dart';

const _itens = [
  StackedCardItem(id: 1, title: 'Espetinho do Zé', subtitle: 'Espetinhos', rating: 4.8),
  StackedCardItem(id: 2, title: 'Açaí da Praça', subtitle: 'Açaí'),
  StackedCardItem(id: 3, title: 'Tapioca da Ana', subtitle: 'Tapiocas'),
];

Future<void> _montar(
  WidgetTester tester, {
  bool leitorDeTela = false,
  bool animacoesReduzidas = false,
  ValueChanged<StackedCardItem>? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          accessibleNavigation: leitorDeTela,
          disableAnimations: animacoesReduzidas,
        ),
        child: Scaffold(
          body: StackedCardCarousel(
            items: _itens,
            onTap: onTap ?? (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('sozinho, o carrossel troca de cartão', (tester) async {
    await _montar(tester);
    expect(find.text('Espetinho do Zé'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Espetinho do Zé'), findsNothing);
    expect(find.text('Açaí da Praça'), findsOneWidget);
  });

  testWidgets('com leitor de tela ligado, o cartão não muda sozinho', (tester) async {
    await _montar(tester, leitorDeTela: true);

    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();

    expect(find.text('Espetinho do Zé'), findsOneWidget,
        reason: 'trocar o cartão no meio da leitura perde quem está ouvindo');
  });

  testWidgets('com animações reduzidas no aparelho, o cartão não muda sozinho', (tester) async {
    await _montar(tester, animacoesReduzidas: true);

    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();

    expect(find.text('Espetinho do Zé'), findsOneWidget);
  });

  testWidgets('enquanto o dedo está no cartão, ele espera', (tester) async {
    await _montar(tester);

    final toque = await tester.startGesture(tester.getCenter(find.text('Espetinho do Zé')));
    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();

    expect(find.text('Espetinho do Zé'), findsOneWidget,
        reason: 'quem está lendo com o dedo na tela não deve perder o cartão');

    await toque.up();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Açaí da Praça'), findsOneWidget,
        reason: 'soltando o dedo, o carrossel volta a andar');
  });

  testWidgets('o cartão da frente diz o que é e em que posição está', (tester) async {
    final semantica = tester.ensureSemantics();
    await _montar(tester);

    expect(
      find.bySemanticsLabel('Espetinho do Zé, Espetinhos, nota 4.8, cartão 1 de 3'),
      findsOneWidget,
    );

    semantica.dispose();
  });

  testWidgets('o leitor de tela consegue abrir a loja do cartão', (tester) async {
    final semantica = tester.ensureSemantics();
    StackedCardItem? aberto;
    await _montar(tester, onTap: (item) => aberto = item);

    tester.semantics.performAction(
      find.semantics.byLabel('Espetinho do Zé, Espetinhos, nota 4.8, cartão 1 de 3'),
      SemanticsAction.tap,
    );
    await tester.pumpAndSettle();

    expect(aberto?.id, 1);

    semantica.dispose();
  });
}
