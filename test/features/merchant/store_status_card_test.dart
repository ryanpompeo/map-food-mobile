import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_status_card.dart';

void main() {
  Widget montar(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  StoreStatusCard card({
    required bool aberta,
    bool rastreioAtivo = false,
    bool ocupado = false,
    DateTime? ultimaPosicaoEm,
    double? precisaoMetros,
    String? avisoPosicao,
    VoidCallback? onToggle,
  }) =>
      StoreStatusCard(
        aberta: aberta,
        rastreioAtivo: rastreioAtivo,
        ocupado: ocupado,
        ultimaPosicaoEm: ultimaPosicaoEm,
        precisaoMetros: precisaoMetros,
        avisoPosicao: avisoPosicao,
        onToggle: onToggle ?? () {},
      );

  group('estado fechado', () {
    testWidgets('anuncia que não aparece no mapa e oferece abrir', (tester) async {
      await tester.pumpWidget(montar(card(aberta: false)));
      await tester.pump();

      expect(find.text('Loja fechada'), findsOneWidget);
      expect(find.text('Abrir loja'), findsOneWidget);
      expect(find.text('Fechar loja'), findsNothing);
    });

    testWidgets('não mostra selo ao vivo nem dados da ronda', (tester) async {
      await tester.pumpWidget(montar(card(aberta: false, rastreioAtivo: true)));
      await tester.pump();

      expect(find.text('AO VIVO'), findsNothing);
      expect(find.text('Posição enviada'), findsNothing);
    });
  });

  group('estado aberto', () {
    testWidgets('oferece fechar e mostra o selo ao vivo com a ronda ligada', (tester) async {
      await tester.pumpWidget(montar(card(aberta: true, rastreioAtivo: true)));
      await tester.pump();

      expect(find.text('Loja aberta'), findsOneWidget);
      expect(find.text('Fechar loja'), findsOneWidget);
      expect(find.text('AO VIVO'), findsOneWidget);
    });

    testWidgets('mostra precisão e o tempo da última posição', (tester) async {
      await tester.pumpWidget(montar(card(
        aberta: true,
        rastreioAtivo: true,
        ultimaPosicaoEm: DateTime.now(),
        precisaoMetros: 12.4,
      )));
      await tester.pump();

      expect(find.text('agora'), findsOneWidget);
      expect(find.text('±12 m'), findsOneWidget);
    });

    testWidgets('posição de minutos atrás é datada, não "agora"', (tester) async {
      await tester.pumpWidget(montar(card(
        aberta: true,
        rastreioAtivo: true,
        ultimaPosicaoEm: DateTime.now().subtract(const Duration(minutes: 3)),
      )));
      await tester.pump();

      expect(find.text('há 3 min'), findsOneWidget);
      expect(find.text('agora'), findsNothing);
    });

    testWidgets('sem precisão conhecida mostra travessão, não zero', (tester) async {
      await tester.pumpWidget(montar(card(aberta: true, rastreioAtivo: true)));
      await tester.pump();

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('aberta com GPS desligado avisa que a posição está parada', (tester) async {
      await tester.pumpWidget(montar(card(aberta: true, rastreioAtivo: false)));
      await tester.pump();

      expect(find.textContaining('GPS desligado'), findsOneWidget);
      expect(find.text('AO VIVO'), findsNothing);
    });
  });

  testWidgets('falha de envio de posição fica visível no card', (tester) async {
    await tester.pumpWidget(montar(card(
      aberta: true,
      rastreioAtivo: true,
      avisoPosicao: 'Sua posição não está subindo.',
    )));
    await tester.pump();

    expect(find.text('Sua posição não está subindo.'), findsOneWidget);
  });

  testWidgets('tocar no botão dispara o toggle', (tester) async {
    var toques = 0;
    await tester.pumpWidget(montar(card(aberta: false, onToggle: () => toques++)));
    await tester.pump();

    await tester.tap(find.text('Abrir loja'));
    await tester.pump();

    expect(toques, 1);
  });

  testWidgets('durante a chamada o botão não aceita um segundo toque', (tester) async {
    var toques = 0;
    await tester.pumpWidget(montar(card(
      aberta: false,
      ocupado: true,
      onToggle: () => toques++,
    )));
    await tester.pump();

    await tester.tap(find.byType(StoreStatusCard), warnIfMissed: false);
    await tester.pump();

    expect(toques, 0);
  });
}
