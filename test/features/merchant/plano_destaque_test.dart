import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/merchant/presentation/pages/plano_destaque_page.dart';
import 'package:map_food/features/store/presentation/widgets/selo_destaque.dart';

Future<void> _abrir(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const PlanoDestaquePage()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra os dois planos, com o preço do Destaque', (tester) async {
    await _abrir(tester);

    expect(find.text('Plano Gratuito'), findsOneWidget);
    expect(find.text('Sem custo'), findsOneWidget);
    expect(find.text('Plano Destaque'), findsWidgets);
    expect(find.text('$precoPlanoDestaque / mês'), findsOneWidget);
    expect(find.byType(SeloDestaque), findsOneWidget);
  });

  testWidgets('só promete o que o app entrega hoje', (tester) async {
    await _abrir(tester);

    for (final vantagem in vantagensDoPlanoDestaque) {
      expect(find.text(vantagem), findsOneWidget);
    }

    expect(find.textContaining('marcador dourado'), findsNothing);
    expect(find.textContaining('inteligência artificial'), findsNothing);
    expect(find.textContaining('galeria expandida'), findsNothing);
  });

  testWidgets('diz que o aplicativo não cobra e como se contrata', (tester) async {
    await _abrir(tester);

    await tester.scrollUntilVisible(find.text('Falar com a equipe'), 300.0);
    await tester.pumpAndSettle();

    expect(find.textContaining('não cobra nem processa pagamento'), findsOneWidget);
    expect(find.text('Falar com a equipe'), findsOneWidget);
  });

  testWidgets('deixa claro que o uso segue gratuito', (tester) async {
    await _abrir(tester);

    expect(find.textContaining('O MapFood continua gratuito'), findsOneWidget);
  });
}
