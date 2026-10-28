import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/widgets/selo_destaque.dart';

void main() {
  group('plano da loja', () {
    test('o app passou a ler o tipo de loja que a API já mandava', () {
      final loja = StoreDto.fromJson({
        'id': 1,
        'nome': 'Espetinho do Zé',
        'statusLoja': 'ATIVA',
        'tipoLoja': 'DESTAQUE',
      });

      expect(loja.tipoLoja, 'DESTAQUE');
      expect(loja.emDestaque, isTrue);
    });

    test('loja gratuita e loja sem o campo não são destaque', () {
      final gratuita = StoreDto.fromJson({
        'id': 1,
        'nome': 'Padaria',
        'statusLoja': 'ATIVA',
        'tipoLoja': 'GRATUITO',
      });
      final semCampo = StoreDto.fromJson({
        'id': 2,
        'nome': 'Açaí',
        'statusLoja': 'ATIVA',
      });

      expect(gratuita.emDestaque, isFalse);
      expect(semCampo.emDestaque, isFalse);
    });

    test('mudar de status ou de posição não perde o plano', () {
      final loja = StoreDto.fromJson({
        'id': 1,
        'nome': 'Carrinho',
        'statusLoja': 'ATIVA',
        'tipoLoja': 'DESTAQUE',
      });

      expect(loja.comPosicao(-22.9, -43.1).emDestaque, isTrue);
    });
  });

  group('selo', () {
    testWidgets('diz "Destaque" e se anuncia para o leitor de tela', (tester) async {
      final semantica = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SeloDestaque()),
        ),
      );

      expect(find.text('Destaque'), findsOneWidget);
      expect(tester.getSemantics(find.byType(SeloDestaque)).label,
          contains('Loja em destaque'));

      semantica.dispose();
    });

    testWidgets('sobre foto, o selo muda de cor sem mudar o texto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ColoredBox(
              color: Colors.black,
              child: SeloDestaque(sobreFoto: true),
            ),
          ),
        ),
      );

      expect(find.text('Destaque'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
