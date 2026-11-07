import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/presentation/widgets/filtro_de_estrelas.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_reviews_section.dart';

AvaliacaoModel _avaliacao(int id, int nota, String comentario) =>
    AvaliacaoModel(id: id, nota: nota, comentario: comentario);

Future<void> _abrirExpandida(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: StoreReviewsSection(
            avaliacoes: [
              _avaliacao(1, 5, 'Atendimento excelente'),
              _avaliacao(2, 4, 'Bom, mas demorou'),
              _avaliacao(3, 5, 'Voltarei sempre'),
            ],
            carregando: false,
            media: 4.7,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Ver as 3 avaliações'));
  await tester.pumpAndSettle();
}

void main() {
  test('uma estrela no singular, as demais no plural', () {
    expect(rotuloEstrelas(1), '1 estrela');
    expect(rotuloEstrelas(2), '2 estrelas');
    expect(rotuloEstrelas(5), '5 estrelas');
  });

  testWidgets('o comerciante abre a lista e vê o filtro de estrelas', (tester) async {
    await _abrirExpandida(tester);

    expect(find.byType(FiltroDeEstrelas), findsOneWidget);
    expect(find.text('Atendimento excelente'), findsOneWidget);
    expect(find.text('Bom, mas demorou'), findsOneWidget);
  });

  testWidgets('filtrar por 4 estrelas deixa só a avaliação de 4', (tester) async {
    await _abrirExpandida(tester);

    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    expect(find.text('Bom, mas demorou'), findsOneWidget);
    expect(find.text('Atendimento excelente'), findsNothing);
    expect(find.text('Voltarei sempre'), findsNothing);
  });

  testWidgets('estrela sem avaliação explica e oferece voltar para todas',
      (tester) async {
    await _abrirExpandida(tester);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(find.text('Nada com 1 estrela'), findsOneWidget);

    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();

    expect(find.text('Atendimento excelente'), findsOneWidget);
  });
}
