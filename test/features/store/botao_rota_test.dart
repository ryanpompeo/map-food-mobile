import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/location/rota_externa.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/store_detail_overview.dart';

StoreDto _loja({double? latitude, double? longitude}) => StoreDto(
      id: 1,
      nome: 'Espetinho do Zé',
      statusLoja: 'ATIVA',
      categoria: 'Espetinhos',
      latitude: latitude,
      longitude: longitude,
    );

Future<void> _abrirTela(WidgetTester tester, StoreDto loja) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StoreActionsRow(store: loja, userRole: 'CONSUMIDOR'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(RotaExterna.restaurarAbridor);

  testWidgets('a loja com localização oferece a rota no app de mapas', (tester) async {
    final tentados = <Uri>[];
    RotaExterna.abridor = (destino) async {
      tentados.add(destino);
      return true;
    };

    await _abrirTela(tester, _loja(latitude: -22.9068, longitude: -43.1729));

    expect(find.text('Traçar rota'), findsOneWidget);

    await tester.tap(find.text('Traçar rota'));
    await tester.pumpAndSettle();

    expect(tentados.single.scheme, 'geo');
    expect(tentados.single.queryParameters['q'], contains('Espetinho do Zé'));
  });

  testWidgets('sem localização, não promete uma rota que não existe', (tester) async {
    await _abrirTela(tester, _loja());

    expect(find.text('Traçar rota'), findsNothing);
    expect(find.text('Este comércio ainda não informou a localização'), findsOneWidget);
  });

  testWidgets('aparelho sem app de mapas recebe um aviso, não um toque sem efeito', (tester) async {
    RotaExterna.abridor = (_) async => false;

    await _abrirTela(tester, _loja(latitude: -22.9068, longitude: -43.1729));

    await tester.tap(find.text('Traçar rota'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Nenhum aplicativo de mapas encontrado neste celular'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
