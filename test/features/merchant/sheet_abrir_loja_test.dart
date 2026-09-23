import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/merchant/presentation/controllers/modo_ronda.dart';
import 'package:map_food/features/merchant/presentation/widgets/sheet_abrir_loja.dart';

void main() {
  final agora = DateTime(2026, 9, 21, 14, 30);

  late AberturaEscolhida? escolhido;
  late bool fechou;

  Future<void> abrir(WidgetTester tester) async {
    escolhido = null;
    fechou = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                escolhido = await mostrarSheetAbrirLoja(context, agora: () => agora);
                fechou = true;
              },
              child: const Text('chamar'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('chamar'));
    await tester.pumpAndSettle();
  }

  Future<void> confirmar(WidgetTester tester) async {
    await tester.tap(find.text('Abrir loja'));
    await tester.pumpAndSettle();
  }

  testWidgets('abre com "estou parado aqui" escolhido e 4 h por padrão', (tester) async {
    await abrir(tester);

    expect(find.text('Estou parado aqui'), findsOneWidget);
    expect(find.text('Estou em movimento'), findsOneWidget);
    expect(find.text('Fecha sozinha às 18:30'), findsOneWidget);
  });

  testWidgets('confirmar devolve o modo parado com o horário de fechamento', (tester) async {
    await abrir(tester);
    await confirmar(tester);

    expect(fechou, isTrue);
    expect(escolhido!.modo, ModoRonda.parado);
    expect(escolhido!.encerraEm, agora.add(const Duration(hours: 4)));
  });

  testWidgets('escolher 2 h muda o horário mostrado e o prazo devolvido', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('2 h'));
    await tester.pumpAndSettle();
    expect(find.text('Fecha sozinha às 16:30'), findsOneWidget);

    await confirmar(tester);

    expect(escolhido!.encerraEm, agora.add(const Duration(hours: 2)));
  });

  testWidgets('em movimento esconde os horários e não devolve prazo', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('Estou em movimento'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Fecha sozinha'), findsNothing);
    expect(find.text('2 h'), findsNothing);

    await confirmar(tester);

    expect(escolhido!.modo, ModoRonda.emMovimento);
    expect(escolhido!.encerraEm, isNull);
  });
}
