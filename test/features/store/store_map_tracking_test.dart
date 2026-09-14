import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';


import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

import '../../support/map_test_tiles.dart';

class _AdapterRonda implements HttpClientAdapter {
  _AdapterRonda(this.latitude, this.longitude);

  double latitude;
  double longitude;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    return ResponseBody.fromString(
      '[{"id":1,"nome":"Carrinho do Zé","statusLoja":"ATIVA",'
      '"latitude":$latitude,"longitude":$longitude}]',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

StoreDto _loja({int id = 1, double? lat, double? lng}) => StoreDto(
      id: id,
      nome: 'Carrinho $id',
      statusLoja: 'ATIVA',
      categoria: 'Lanches',
      latitude: lat,
      longitude: lng,
    );

class _Palco extends StatefulWidget {
  const _Palco({super.key, required this.inicial});

  final List<StoreDto> inicial;

  @override
  State<_Palco> createState() => _PalcoState();
}

class _PalcoState extends State<_Palco> {
  late List<StoreDto> _stores = widget.inicial;

  void mutar(List<StoreDto> novas) => setState(() => _stores = novas);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: StoreMapView(stores: _stores, showFloatingControls: false)),
    );
  }
}

List<Marker> _marcadoresDeLoja(WidgetTester tester) =>
    tester.widget<MarkerLayer>(find.byType(MarkerLayer).first).markers;

void main() {
  setUp(usarTilesOffline);

  testWidgets('marcador segue a mutação de coordenadas do comerciante', (tester) async {
    final palco = GlobalKey<_PalcoState>();
    await tester.pumpWidget(
      _Palco(key: palco, inicial: [_loja(lat: -22.9068, lng: -43.1729)]),
    );
    await tester.pump();

    expect(_marcadoresDeLoja(tester).single.point, const LatLng(-22.9068, -43.1729));

    palco.currentState!.mutar([_loja(lat: -22.9100, lng: -43.1800)]);
    await tester.pump();

    expect(_marcadoresDeLoja(tester).single.point, const LatLng(-22.9100, -43.1800));
  });

  testWidgets('loja que perde a localização some do mapa', (tester) async {
    final palco = GlobalKey<_PalcoState>();
    await tester.pumpWidget(
      _Palco(key: palco, inicial: [_loja(lat: -22.9068, lng: -43.1729)]),
    );
    await tester.pump();
    expect(_marcadoresDeLoja(tester), hasLength(1));

    palco.currentState!.mutar([_loja()]);
    await tester.pump();

    expect(_marcadoresDeLoja(tester), isEmpty);
  });

  testWidgets('ronda do comerciante na API chega ao marcador do consumidor',
      (tester) async {
    final adapter = _AdapterRonda(-22.9068, -43.1729);
    final service = StoreService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = adapter
          ..interceptors.add(ErrorInterceptor()),
      ),
    );

    final palco = GlobalKey<_PalcoState>();
    final primeiraLeitura = await tester.runAsync(service.getActive);
    await tester.pumpWidget(_Palco(key: palco, inicial: primeiraLeitura!));
    await tester.pump();

    expect(_marcadoresDeLoja(tester).single.point, const LatLng(-22.9068, -43.1729));

    adapter.latitude = -22.9200;
    adapter.longitude = -43.1900;
    final segundaLeitura = await tester.runAsync(service.getActive);
    palco.currentState!.mutar(segundaLeitura!);
    await tester.pump();

    expect(_marcadoresDeLoja(tester).single.point, const LatLng(-22.9200, -43.1900));
  });

  testWidgets('cada loja localizada vira um marcador', (tester) async {
    await tester.pumpWidget(_Palco(inicial: [
      _loja(id: 1, lat: -22.9068, lng: -43.1729),
      _loja(id: 2, lat: -22.9300, lng: -43.2000),
      _loja(id: 3),
    ]));
    await tester.pump();

    expect(_marcadoresDeLoja(tester), hasLength(2));
  });

  testWidgets('lojas coladas viram um único marcador de grupo', (tester) async {
    await tester.pumpWidget(_Palco(inicial: [
      _loja(id: 1, lat: -22.9068, lng: -43.1729),
      _loja(id: 2, lat: -22.9069, lng: -43.1730),
      _loja(id: 3, lat: -22.9070, lng: -43.1731),
    ]));
    await tester.pump();

    expect(_marcadoresDeLoja(tester), hasLength(1));
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('loja fora do viewport não vira marcador', (tester) async {
    await tester.pumpWidget(_Palco(inicial: [
      _loja(id: 1, lat: -22.9068, lng: -43.1729),
      _loja(id: 2, lat: 38.7223, lng: -9.1393),
    ]));
    await tester.pump();

    expect(_marcadoresDeLoja(tester), hasLength(1));
  });

  testWidgets('tocar num grupo de lojas no mesmo ponto aproxima até separá-las', (tester) async {
    await tester.pumpWidget(_Palco(inicial: [
      _loja(id: 1, lat: -22.9068, lng: -43.1729),
      _loja(id: 2, lat: -22.9068, lng: -43.1729),
      _loja(id: 3, lat: -22.9068, lng: -43.1729),
    ]));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pump();

    expect(find.text('3'), findsNothing);
    final marcadoresDeLoja = _marcadoresDeLoja(tester).where((m) => m.key is ValueKey<int>);
    expect(marcadoresDeLoja, hasLength(3));
    expect(marcadoresDeLoja.map((m) => m.point).toSet(), hasLength(3));
  });
}
