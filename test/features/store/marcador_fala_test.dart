import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';
import 'package:map_food/features/store/presentation/widgets/store_markers_layer.dart';

import '../../support/map_test_tiles.dart';

StoreDto _loja() => StoreDto(
      id: 1,
      nome: 'Espetinho do Zé',
      statusLoja: 'ATIVA',
      categoria: 'Espetinhos',
      latitude: -22.9068,
      longitude: -43.1729,
    );

Future<void> _abrirMapa(WidgetTester tester, {LatLng? usuario}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StoreMapView(
          stores: [_loja()],
          userPosition: usuario == null ? null : ValueNotifier<LatLng?>(usuario),
          showFloatingControls: false,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(usarTilesOffline);

  group('distância falada', () {
    test('perto, fala em metros', () {
      expect(distanciaFalada(348.7), 'a 349 m de você');
    });

    test('longe, fala em quilômetros', () {
      expect(distanciaFalada(2430.0), 'a 2.4 km de você');
    });
  });

  group('o pino do mapa', () {
    testWidgets('diz o nome e a distância até quem está olhando', (tester) async {
      final semantica = tester.ensureSemantics();

      await _abrirMapa(tester, usuario: LatLng(-22.9100, -43.1729));

      expect(find.bySemanticsLabel(RegExp(r'^Espetinho do Zé, a \d+ m de você$')), findsOneWidget);

      semantica.dispose();
    });

    testWidgets('sem localização do usuário, diz só o nome', (tester) async {
      final semantica = tester.ensureSemantics();

      await _abrirMapa(tester);

      expect(find.bySemanticsLabel('Espetinho do Zé'), findsOneWidget);

      semantica.dispose();
    });
  });
}
