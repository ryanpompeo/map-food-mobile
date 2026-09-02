import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

class _AdapterContador implements HttpClientAdapter {
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    chamadas++;
    return ResponseBody.fromString(
      '[{"id": 1, "nome": "Padaria", "statusLoja": "ATIVA"}]',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _aguardarAte(bool Function() condicao) async {
  final limite = DateTime.now().add(const Duration(seconds: 5));
  while (!condicao() && DateTime.now().isBefore(limite)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<void> _aguardarSossego() =>
    Future<void>.delayed(const Duration(milliseconds: 120));

void main() {
  late _AdapterContador adapter;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    adapter = _AdapterContador();
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ErrorInterceptor());
    final client = ApiClient(dio: dio);
    ApiClient.overrideInstance(client);
    ActiveStoresManager.instance.service = StoreService(client: client);
  });

  tearDownAll(ApiClient.resetInstance);

  test('primeiro listener inicia a busca; último listener a encerra', () async {
    void ouvinte() {}

    ActiveStoresManager.instance.addListener(ouvinte);
    await _aguardarAte(() => ActiveStoresManager.instance.stores.isNotEmpty);

    expect(adapter.chamadas, 1);
    expect(ActiveStoresManager.instance.stores, hasLength(1));

    ActiveStoresManager.instance.removeListener(ouvinte);
  });

  test('app em segundo plano para de consultar a API', () async {
    void ouvinte() {}
    ActiveStoresManager.instance.addListener(ouvinte);
    addTearDown(() => ActiveStoresManager.instance.removeListener(ouvinte));
    await _aguardarAte(() => adapter.chamadas >= 1);
    await _aguardarSossego();

    final antes = adapter.chamadas;

    ActiveStoresManager.instance.didChangeAppLifecycleState(AppLifecycleState.paused);
    await _aguardarSossego();

    expect(adapter.chamadas, antes, reason: 'não deve consultar em background');
  });

  test('voltar ao primeiro plano refaz a busca imediatamente', () async {
    void ouvinte() {}
    ActiveStoresManager.instance.addListener(ouvinte);
    addTearDown(() => ActiveStoresManager.instance.removeListener(ouvinte));
    await _aguardarAte(() => adapter.chamadas >= 1);
    await _aguardarSossego();

    ActiveStoresManager.instance.didChangeAppLifecycleState(AppLifecycleState.paused);
    final antes = adapter.chamadas;

    ActiveStoresManager.instance.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await _aguardarAte(() => adapter.chamadas > antes);

    expect(adapter.chamadas, greaterThan(antes),
        reason: 'o que estava na tela pode estar minutos desatualizado');

    await _aguardarSossego();
  });

  test('sem listeners, voltar ao primeiro plano não dispara busca', () async {
    final antes = adapter.chamadas;

    ActiveStoresManager.instance.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await _aguardarSossego();

    expect(adapter.chamadas, antes);
  });

  test('falha de rede preserva a última lista boa', () async {
    void ouvinte() {}
    ActiveStoresManager.instance.addListener(ouvinte);
    addTearDown(() => ActiveStoresManager.instance.removeListener(ouvinte));
    await _aguardarAte(() => ActiveStoresManager.instance.stores.isNotEmpty);
    expect(ActiveStoresManager.instance.stores, hasLength(1));

    final dioQuebrado = Dio(BaseOptions(baseUrl: 'http://test.local'))
      ..httpClientAdapter = _AdapterQueFalha()
      ..interceptors.add(ErrorInterceptor());
    ActiveStoresManager.instance.service = StoreService(client: ApiClient(dio: dioQuebrado));

    await ActiveStoresManager.instance.load();

    expect(ActiveStoresManager.instance.stores, hasLength(1),
        reason: 'mapa vazio seria pior do que mostrar o último estado conhecido');
  });
}

class _AdapterQueFalha implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    return ResponseBody.fromString('{"message":"boom"}', 500, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
