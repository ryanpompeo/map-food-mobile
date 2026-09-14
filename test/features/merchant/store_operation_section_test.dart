import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_operation_section.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

import '../../support/map_test_tiles.dart';

StoreDto _loja(String status) => StoreDto(
      id: 7,
      nome: 'Carrinho do Zé',
      statusLoja: status,
      categoria: 'Lanches',
      latitude: -22.91,
      longitude: -43.176,
    );

void main() {
  setUp(usarTilesOffline);

  Future<void> mostrar(WidgetTester tester, String status) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: StoreOperationSection(store: _loja(status)))),
    ));
    await tester.pump();
  }

  Future<void> fechar(WidgetTester tester) => tester.pumpWidget(const SizedBox.shrink());

  testWidgets('loja suspensa não manda abrir a loja nem mostra a dica da ronda', (tester) async {
    await mostrar(tester, 'SUSPENSA');

    expect(find.textContaining('enquanto a loja estiver suspensa'), findsOneWidget);
    expect(find.textContaining('abra a loja'), findsNothing);
    expect(find.textContaining('Ao abrir a loja'), findsNothing);
    await fechar(tester);
  });

  testWidgets('loja fechada convida a abrir para voltar ao mapa', (tester) async {
    await mostrar(tester, 'INATIVA');

    expect(find.textContaining('abra a loja para voltar ao mapa'), findsOneWidget);
    expect(find.textContaining('Ao abrir a loja'), findsOneWidget);
    await fechar(tester);
  });

  testWidgets('loja aberta avisa que a posição segue mesmo com a tela bloqueada', (tester) async {
    await mostrar(tester, 'ATIVA');

    expect(find.textContaining('mesmo com a tela bloqueada'), findsOneWidget);
    expect(find.textContaining('primeiro plano'), findsNothing);
    await fechar(tester);
  });
}
