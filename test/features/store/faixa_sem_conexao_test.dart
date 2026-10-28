import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/presentation/widgets/faixa_sem_conexao.dart';

void main() {
  group('texto da faixa', () {
    test('menos de um minuto nao vira "0 min"', () {
      expect(textoDeDadosAntigos(const Duration(seconds: 40)),
          'Sem conexão · mapa de agora há pouco');
    });

    test('minutos e horas sao escritos por extenso', () {
      expect(textoDeDadosAntigos(const Duration(minutes: 7)),
          'Sem conexão · mapa de 7 min atrás');
      expect(textoDeDadosAntigos(const Duration(hours: 3)),
          'Sem conexão · mapa de 3 h atrás');
    });

    test('sem idade conhecida, nao inventa numero', () {
      expect(textoDeDadosAntigos(null),
          'Sem conexão · o mapa pode estar desatualizado');
    });
  });

  group('faixa na tela', () {
    testWidgets('mostra o texto e se anuncia para o leitor de tela', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: FaixaDeDadosAntigos(texto: 'Sem conexão · mapa de 5 min atrás'),
          ),
        ),
      );

      expect(find.text('Sem conexão · mapa de 5 min atrás'), findsOneWidget);

      final semantica = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(FaixaDeDadosAntigos),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantica.properties.liveRegion ?? false, isTrue);
    });
  });
}
