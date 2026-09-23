import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/features/merchant/presentation/controllers/modo_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/situacao_loja.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_status_card.dart';

void main() {
  Widget montar(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  StoreStatusCard card({
    required SituacaoLoja situacao,
    bool ocupado = false,
    bool ligandoAcompanhamento = false,
    DateTime? ultimaPosicaoEm,
    double? precisaoMetros,
    Duration? semSinalHa,
    Duration? fechaEm,
    String? avisoPosicao,
    VoidCallback? onToggle,
    VoidCallback? onAcompanhar,
    ModoRonda modo = ModoRonda.emMovimento,
    DateTime? prazo,
    bool fimProximo = false,
    VoidCallback? onProrrogar,
    VoidCallback? onTrocarModo,
  }) =>
      StoreStatusCard(
        modo: modo,
        prazo: prazo,
        fimProximo: fimProximo,
        onProrrogar: onProrrogar,
        onTrocarModo: onTrocarModo,
        situacao: situacao,
        ocupado: ocupado,
        ligandoAcompanhamento: ligandoAcompanhamento,
        ultimaPosicaoEm: ultimaPosicaoEm,
        precisaoMetros: precisaoMetros,
        semSinalHa: semSinalHa,
        fechaEm: fechaEm,
        avisoPosicao: avisoPosicao,
        onToggle: onToggle ?? () {},
        onAcompanhar: onAcompanhar ?? () {},
      );

  Future<void> mostrar(WidgetTester tester, StoreStatusCard cartao) async {
    await tester.pumpWidget(montar(cartao));
    await tester.pump();
  }

  group('estado fechado', () {
    testWidgets('anuncia que não aparece no mapa e oferece abrir', (tester) async {
      await mostrar(tester, card(situacao: SituacaoLoja.fechada));

      expect(find.text('Loja fechada'), findsOneWidget);
      expect(find.text('Abrir loja'), findsOneWidget);
      expect(find.text('Fechar loja'), findsNothing);
    });

    testWidgets('não mostra selo ao vivo nem dados da ronda', (tester) async {
      await mostrar(tester, card(situacao: SituacaoLoja.fechada, ultimaPosicaoEm: DateTime.now()));

      expect(find.text('AO VIVO'), findsNothing);
      expect(find.text('Posição enviada'), findsNothing);
      expect(find.text('Acompanhar minha posição'), findsNothing);
    });
  });

  group('estado suspenso', () {
    testWidgets('explica a suspensão e não oferece nenhum botão', (tester) async {
      await mostrar(tester, card(situacao: SituacaoLoja.suspensa));

      expect(find.text('Loja suspensa'), findsOneWidget);
      expect(find.textContaining('moderação'), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
    });
  });

  group('transmitindo', () {
    testWidgets('oferece fechar e mostra o selo ao vivo', (tester) async {
      await mostrar(tester, card(situacao: SituacaoLoja.transmitindo));

      expect(find.text('Loja aberta'), findsOneWidget);
      expect(find.text('Fechar loja'), findsOneWidget);
      expect(find.text('AO VIVO'), findsOneWidget);
      expect(find.text('Acompanhar minha posição'), findsNothing);
    });

    testWidgets('mostra precisão e o tempo da última posição', (tester) async {
      await mostrar(tester, card(
        situacao: SituacaoLoja.transmitindo,
        ultimaPosicaoEm: DateTime.now(),
        precisaoMetros: 12.4,
      ));

      expect(find.text('agora'), findsOneWidget);
      expect(find.text('±12 m'), findsOneWidget);
    });

    testWidgets('posição de minutos atrás é datada, não "agora"', (tester) async {
      await mostrar(tester, card(
        situacao: SituacaoLoja.transmitindo,
        ultimaPosicaoEm: DateTime.now().subtract(const Duration(minutes: 3)),
      ));

      expect(find.text('há 3 min'), findsOneWidget);
      expect(find.text('agora'), findsNothing);
    });

    testWidgets('sem precisão conhecida mostra travessão, não zero', (tester) async {
      await mostrar(tester, card(situacao: SituacaoLoja.transmitindo));

      expect(find.text('—'), findsOneWidget);
    });
  });

  group('loja fixa', () {
    testWidgets('diz que a posição é a do cadastro e oferece acompanhar', (tester) async {
      await mostrar(tester, card(situacao: SituacaoLoja.fixa));

      expect(find.text('Loja aberta'), findsOneWidget);
      expect(find.textContaining('Posição fixa'), findsOneWidget);
      expect(find.text('Acompanhar minha posição'), findsOneWidget);
      expect(find.text('Fechar loja'), findsOneWidget);
      expect(find.text('AO VIVO'), findsNothing);
    });

    testWidgets('tocar em acompanhar dispara a ação, não o toggle', (tester) async {
      var acompanhar = 0;
      var toggle = 0;
      await mostrar(tester, card(
        situacao: SituacaoLoja.fixa,
        onAcompanhar: () => acompanhar++,
        onToggle: () => toggle++,
      ));

      await tester.tap(find.text('Acompanhar minha posição'));
      await tester.pump();

      expect(acompanhar, 1);
      expect(toggle, 0);
    });

    testWidgets('enquanto liga o acompanhamento, fechar a loja não aceita toque', (tester) async {
      var toggle = 0;
      await mostrar(tester, card(
        situacao: SituacaoLoja.fixa,
        ligandoAcompanhamento: true,
        onToggle: () => toggle++,
      ));

      await tester.tap(find.text('Fechar loja'));
      await tester.pump();

      expect(toggle, 0);
    });
  });

  group('sem sinal', () {
    testWidgets('diz há quanto tempo está sem sinal e quando a loja fecha sozinha', (tester) async {
      await mostrar(tester, card(
        situacao: SituacaoLoja.semSinal,
        semSinalHa: const Duration(minutes: 4, seconds: 10),
        fechaEm: const Duration(minutes: 10, seconds: 50),
      ));

      expect(
        find.text('Sem sinal há 4 min — se não voltar, a loja fecha sozinha em 11 min'),
        findsOneWidget,
      );
      expect(find.text('AO VIVO'), findsNothing);
    });

    testWidgets('prazo vencido não mostra minutos negativos', (tester) async {
      await mostrar(tester, card(
        situacao: SituacaoLoja.semSinal,
        semSinalHa: const Duration(minutes: 16),
        fechaEm: Duration.zero,
      ));

      expect(find.textContaining('a loja fecha sozinha a qualquer momento'), findsOneWidget);
    });

    testWidgets('sem nenhum envio ainda, não promete prazo', (tester) async {
      await mostrar(tester, card(situacao: SituacaoLoja.semSinal));

      expect(find.text('Sem sinal — os clientes veem o último ponto enviado'), findsOneWidget);
    });
  });

  testWidgets('iniciando mostra que está obtendo a posição', (tester) async {
    await mostrar(tester, card(situacao: SituacaoLoja.iniciando));

    expect(find.text('Obtendo sua posição…'), findsOneWidget);
  });

  testWidgets('falha de envio de posição fica visível no card', (tester) async {
    await mostrar(tester, card(
      situacao: SituacaoLoja.transmitindo,
      avisoPosicao: 'Sua posição não está subindo.',
    ));

    expect(find.text('Sua posição não está subindo.'), findsOneWidget);
  });

  testWidgets('tocar no botão dispara o toggle', (tester) async {
    var toques = 0;
    await mostrar(tester, card(situacao: SituacaoLoja.fechada, onToggle: () => toques++));

    await tester.tap(find.text('Abrir loja'));
    await tester.pump();

    expect(toques, 1);
  });

  testWidgets('durante a chamada o botão não aceita um segundo toque', (tester) async {
    var toques = 0;
    await mostrar(tester, card(
      situacao: SituacaoLoja.fechada,
      ocupado: true,
      onToggle: () => toques++,
    ));

    await tester.tap(find.byType(StoreStatusCard), warnIfMissed: false);
    await tester.pump();

    expect(toques, 0);
  });

  group('estou aqui', () {
    final prazo = DateTime(2026, 9, 21, 18, 30);

    testWidgets('modo parado troca o título e não mostra o selo ao vivo', (tester) async {
      await mostrar(
        tester,
        card(situacao: SituacaoLoja.transmitindo, modo: ModoRonda.parado),
      );

      expect(find.text('Loja aberta neste ponto'), findsOneWidget);
      expect(find.text('AO VIVO'), findsNothing);
    });

    testWidgets('com prazo, mostra até que horas a loja fica aberta', (tester) async {
      await mostrar(
        tester,
        card(situacao: SituacaoLoja.transmitindo, modo: ModoRonda.parado, prazo: prazo),
      );

      expect(find.text('Aberta até as 18:30'), findsOneWidget);
      expect(find.text('Ficar mais 2 horas'), findsNothing);
    });

    testWidgets('perto do fim, oferece ficar mais 2 horas', (tester) async {
      var prorrogou = false;
      await mostrar(
        tester,
        card(
          situacao: SituacaoLoja.transmitindo,
          modo: ModoRonda.parado,
          prazo: prazo,
          fimProximo: true,
          onProrrogar: () => prorrogou = true,
        ),
      );

      expect(find.text('Ela fecha sozinha às 18:30'), findsOneWidget);
      await tester.tap(find.text('Ficar mais 2 horas'));

      expect(prorrogou, isTrue);
    });

    testWidgets('loja aberta oferece trocar de modo', (tester) async {
      var trocou = false;
      await mostrar(
        tester,
        card(
          situacao: SituacaoLoja.transmitindo,
          modo: ModoRonda.parado,
          onTrocarModo: () => trocou = true,
        ),
      );

      await tester.tap(find.text('Passar para em movimento'));

      expect(trocou, isTrue);
    });

    testWidgets('loja fechada não mostra prazo nem troca de modo', (tester) async {
      await mostrar(
        tester,
        card(
          situacao: SituacaoLoja.fechada,
          prazo: prazo,
          onTrocarModo: () {},
        ),
      );

      expect(find.textContaining('Aberta até'), findsNothing);
      expect(find.text('Estou parado aqui'), findsNothing);
    });
  });
}
