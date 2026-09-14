import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/store_detail_overview.dart';
import 'package:map_food/features/store/presentation/widgets/visto_ha.dart';

import '../../support/api_falsa.dart';

String _lojas({int? segundosSemSinal}) => jsonEncode([
      {
        'id': 7,
        'nome': 'Carrinho do Zé',
        'statusLoja': 'ATIVA',
        'latitude': -22.91,
        'longitude': -43.176,
        'segundosSemSinal': ?segundosSemSinal,
      },
    ]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ApiFalsa api;
  late DateTime agora;

  setUp(() {
    agora = DateTime(2026, 9, 14, 12);
    api = ApiFalsa();
    ActiveStoresManager.instance
      ..limparParaTeste()
      ..service = api.servico
      ..relogio = () => agora;
  });

  tearDown(() => ActiveStoresManager.instance.limparParaTeste());

  Future<void> mostrar(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: child)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Widget rotulo() => VistoHa(lojaId: 7, builder: (_, texto) => Text(texto));

  Future<void> fechar(WidgetTester tester) => tester.pumpWidget(const SizedBox.shrink());

  group('rótulo', () {
    test('menos de um minuto é "agora"; depois conta os minutos', () {
      expect(rotuloVistoHa(const Duration(seconds: 59)), 'Visto agora');
      expect(rotuloVistoHa(const Duration(minutes: 4, seconds: 59)), 'Visto há 4 min');
      expect(rotuloVistoHa(null), isNull);
    });
  });

  testWidgets('loja em movimento mostra há quanto tempo foi vista', (tester) async {
    api.padrao = (200, _lojas(segundosSemSinal: 180));

    await mostrar(tester, rotulo());

    expect(find.text('Visto há 3 min'), findsOneWidget);
    await fechar(tester);
  });

  testWidgets('loja fixa não mostra nada', (tester) async {
    api.padrao = (200, _lojas());

    await mostrar(tester, rotulo());

    expect(find.textContaining('Visto'), findsNothing);
    await fechar(tester);
  });

  testWidgets('o texto avança sozinho, sem esperar uma nova consulta mudar algo', (tester) async {
    api.padrao = (200, _lojas(segundosSemSinal: 180));
    await mostrar(tester, rotulo());

    agora = agora.add(const Duration(minutes: 2));
    api.padrao = (200, _lojas(segundosSemSinal: 300));
    await tester.pump(const Duration(seconds: 30));

    expect(find.text('Visto há 5 min'), findsOneWidget);
    await fechar(tester);
  });

  testWidgets('loja que some da consulta perde o rótulo', (tester) async {
    api.padrao = (200, _lojas(segundosSemSinal: 60));
    await mostrar(tester, rotulo());
    expect(find.text('Visto há 1 min'), findsOneWidget);

    api.padrao = (200, '[]');
    await tester.pump(const Duration(seconds: 21));
    await tester.pump();

    expect(find.textContaining('Visto'), findsNothing);
    await fechar(tester);
  });

  testWidgets('o detalhe da loja mostra o "visto há" junto das ações', (tester) async {
    api.padrao = (200, _lojas(segundosSemSinal: 240));
    final loja = StoreDto(
      id: 7,
      nome: 'Carrinho do Zé',
      statusLoja: 'ATIVA',
      categoria: 'Lanches',
      latitude: -22.91,
      longitude: -43.176,
    );

    await mostrar(tester, StoreActionsRow(store: loja, userRole: 'CONSUMIDOR'));

    expect(find.text('Visto há 4 min'), findsOneWidget);
    await fechar(tester);
  });
}
