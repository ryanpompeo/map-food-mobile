import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/onboarding/presentation/pages/onboarding_page.dart';

Future<void> _abrir(WidgetTester tester, Size tela, double escala) async {
  tester.view.physicalSize = tela * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: tela, textScaler: TextScaler.linear(escala)),
        child: const OnboardingPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('celular pequeno com fonte normal não estoura', (tester) async {
    await _abrir(tester, const Size(320, 568), 1.0);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fonte 2x não estoura e o botão Começar é alcançável rolando',
      (tester) async {
    await _abrir(tester, const Size(360, 640), 2.0);

    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Começar'));
    await tester.pumpAndSettle();
    final botao = tester.getRect(find.text('Começar'));
    expect(botao.top, greaterThanOrEqualTo(0));
    expect(botao.bottom, lessThanOrEqualTo(640));
  });

  testWidgets('em tela grande os botões continuam colados no rodapé', (tester) async {
    await _abrir(tester, const Size(412, 915), 1.0);

    expect(tester.takeException(), isNull);
    final rodape = tester.getBottomLeft(find.text('Continuar sem conta')).dy;
    expect(rodape, greaterThan(915 - 120),
        reason: 'os espaços elásticos ainda empurram os botões para baixo');
  });
}
