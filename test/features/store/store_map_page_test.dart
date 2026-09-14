import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/route_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/pages/store_map_page.dart';

import '../../support/fonte_posicao_falsa.dart';
import '../../support/map_test_tiles.dart';

const _pontoInicial = LatLng(-22.9100, -43.1760);
const _pontoAdiante = LatLng(-22.9108, -43.1760);

class _ApiDeLojas implements HttpClientAdapter {
  List<Map<String, dynamic>> lojas = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    return ResponseBody.fromString(jsonEncode(lojas), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _truckEm(LatLng ponto) => {
      'id': 7,
      'nome': 'Carrinho do Zé',
      'statusLoja': 'ATIVA',
      'latitude': ponto.latitude,
      'longitude': ponto.longitude,
      'segundosSemSinal': 10,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FontePosicaoFalsa fonte;
  late _ApiDeLojas api;
  late List<(LatLng, LatLng)> pedidosDeRota;

  final truck = StoreDto(
    id: 7,
    nome: 'Carrinho do Zé',
    statusLoja: 'ATIVA',
    categoria: 'Lanches',
    latitude: _pontoInicial.latitude,
    longitude: _pontoInicial.longitude,
  );

  Future<RouteResult?> calcular(LatLng origem, LatLng destino) async {
    pedidosDeRota.add((origem, destino));
    return RouteResult(pontos: [origem, destino], distanciaMetros: 420);
  }

  LatLng pontoDoTruck(WidgetTester tester) => tester
      .widget<MarkerLayer>(find.byType(MarkerLayer).first)
      .markers
      .firstWhere((m) => m.key == const ValueKey<int>(7))
      .point;

  Future<void> assentar(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: StoreMapPage(store: truck, calcularRota: calcular),
    ));
    await assentar(tester);
  }

  Future<void> fechar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 31));
  }

  setUp(() {
    usarTilesOffline();
    fonte = FontePosicaoFalsa()..ultimaConhecidaDevolvida = posicaoDeTeste();
    LocationService.substituirFonte(fonte);
    api = _ApiDeLojas()..lojas = [_truckEm(_pontoInicial)];
    ActiveStoresManager.instance
      ..limparParaTeste()
      ..service = StoreService(
        client: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
            ..httpClientAdapter = api
            ..interceptors.add(ErrorInterceptor()),
        ),
      );
    pedidosDeRota = [];
  });

  tearDown(() async {
    ActiveStoresManager.instance.limparParaTeste();
    LocationService.restaurarFonte();
    await fonte.fechar();
  });

  testWidgets('a rota é traçada a partir de onde o usuário está', (tester) async {
    await abrir(tester);

    expect(pedidosDeRota, hasLength(1));
    expect(pedidosDeRota.single.$2, _pontoInicial);
    expect(find.text('≈ 420 m'), findsOneWidget);
    expect(find.text('Visto agora'), findsOneWidget);

    await fechar(tester);
  });

  testWidgets('o marcador acompanha o food truck e a rota é refeita depois da janela de 30 s',
      (tester) async {
    await abrir(tester);

    api.lojas = [_truckEm(_pontoAdiante)];
    unawaited(ActiveStoresManager.instance.load());
    await assentar(tester);

    expect(pontoDoTruck(tester), _pontoAdiante);
    expect(pedidosDeRota, hasLength(1), reason: 'ainda dentro da janela mínima');

    await tester.pump(const Duration(seconds: 31));
    await assentar(tester);

    expect(pedidosDeRota, hasLength(2));
    expect(pedidosDeRota.last.$2, _pontoAdiante);

    await fechar(tester);
  });

  testWidgets('loja que sai do mapa mostra o aviso sem fechar a tela', (tester) async {
    await abrir(tester);

    api.lojas = [];
    unawaited(ActiveStoresManager.instance.load());
    await assentar(tester);

    expect(find.text('A loja saiu do mapa — fechou ou ficou sem sinal'), findsOneWidget);
    expect(find.byType(StoreMapPage), findsOneWidget);

    await fechar(tester);
  });

  testWidgets('sem permissão de localização, explica e não chama o serviço de rotas',
      (tester) async {
    fonte.acesso = AcessoLocalizacao.negado;

    await abrir(tester);

    expect(find.text('Ative a localização para traçar a rota até a loja'), findsOneWidget);
    expect(pedidosDeRota, isEmpty);

    await fechar(tester);
  });
}
