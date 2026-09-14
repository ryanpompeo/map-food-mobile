import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/widgets/nearby_stores_section.dart';

import '../../support/map_test_tiles.dart';

Widget _palco(Widget filho) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: filho));

void main() {
  setUp(usarTilesOffline);

  testWidgets('a posição do usuário é publicada no controlador do mapa, sem callback no build',
      (tester) async {
    final controlador = StoreMapController();
    addTearDown(controlador.dispose);

    await tester.pumpWidget(_palco(NearbyStoresSection(
      stores: const [],
      initialLatitude: -22.9068,
      initialLongitude: -43.1729,
      mapController: controlador,
      showFloatingControls: false,
    )));
    await tester.pump();

    expect(controlador.posicaoUsuario.value, const LatLng(-22.9068, -43.1729));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('sem controlador externo, a seção cuida e descarta a sua própria posição',
      (tester) async {
    await tester.pumpWidget(_palco(const NearbyStoresSection(
      stores: [],
      initialLatitude: -22.9068,
      initialLongitude: -43.1729,
      showFloatingControls: false,
    )));
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));

    expect(tester.takeException(), isNull);
  });

  testWidgets('o controlador externo sobrevive à saída da seção', (tester) async {
    final controlador = StoreMapController();
    addTearDown(controlador.dispose);

    await tester.pumpWidget(_palco(NearbyStoresSection(
      stores: const [],
      initialLatitude: -22.9068,
      initialLongitude: -43.1729,
      mapController: controlador,
      showFloatingControls: false,
    )));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));

    controlador.posicaoUsuario.value = const LatLng(-22.91, -43.18);
    expect(controlador.posicaoUsuario.value, const LatLng(-22.91, -43.18));
  });
}
