import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

/// Conta quantas vezes a API foi consultada — é o que distingue "polling
/// rodando" de "polling parado" sem precisar esperar os 20s do intervalo real.
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

/// Espera **até** [condicao] valer, com teto de segurança.
///
/// O polling é disparado sem await (`unawaited(load())`) e o pipeline do Dio
/// atravessa vários microtasks antes de chegar ao adapter, então `Duration.zero`
/// não observa o efeito. Um `delayed` fixo também não serve: 50 ms bastam com a
/// máquina parada e falham quando a suíte inteira roda em paralelo e este
/// isolate não é escalonado a tempo — era exatamente esse o flake.
Future<void> _aguardarAte(bool Function() condicao) async {
  final limite = DateTime.now().add(const Duration(seconds: 5));
  while (!condicao() && DateTime.now().isBefore(limite)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

/// Dá tempo para uma requisição indevida acontecer, quando o que se afirma é
/// que ela **não** acontece. Aqui a espera fixa é a semântica certa: não há
/// condição para aguardar, e sim um intervalo em que nada pode ocorrer.
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
    // Espera a carga TERMINAR, não só sair: `chamadas` incrementa na entrada
    // do adapter, e nesse instante a resposta ainda não percorreu o pipeline
    // do Dio nem chegou ao manager — `stores` ainda estaria vazia.
    await _aguardarAte(() => ActiveStoresManager.instance.stores.isNotEmpty);

    expect(adapter.chamadas, 1);
    expect(ActiveStoresManager.instance.stores, hasLength(1));

    ActiveStoresManager.instance.removeListener(ouvinte);
  });

  test('app em segundo plano para de consultar a API', () async {
    void ouvinte() {}
    ActiveStoresManager.instance.addListener(ouvinte);
    addTearDown(() => ActiveStoresManager.instance.removeListener(ouvinte));
    // Duas esperas, e não uma: `chamadas` incrementa na ENTRADA do adapter, e
    // nesse instante a resposta ainda não percorreu o pipeline do Dio. Sem o
    // sossego depois, a carga de abertura seguia em voo e aterrissava depois
    // do `antes` — subindo o contador sem que o app tivesse consultado nada em
    // segundo plano. (Esperar por `stores.isNotEmpty` também não serve aqui: o
    // manager é singleton e a lista já vem preenchida do teste anterior.)
    await _aguardarAte(() => adapter.chamadas >= 1);
    await _aguardarSossego();

    final antes = adapter.chamadas;

    // Minimizou: o timer precisa morrer, senão o app segue consultando de
    // 20 em 20 segundos com a tela desligada.
    ActiveStoresManager.instance.didChangeAppLifecycleState(AppLifecycleState.paused);
    await _aguardarSossego();

    expect(adapter.chamadas, antes, reason: 'não deve consultar em background');
  });

  test('voltar ao primeiro plano refaz a busca imediatamente', () async {
    void ouvinte() {}
    ActiveStoresManager.instance.addListener(ouvinte);
    addTearDown(() => ActiveStoresManager.instance.removeListener(ouvinte));
    // Mesmo par de esperas do teste acima, pelo mesmo motivo: `antes` só vale
    // depois que a carga de abertura assentou.
    await _aguardarAte(() => adapter.chamadas >= 1);
    await _aguardarSossego();

    ActiveStoresManager.instance.didChangeAppLifecycleState(AppLifecycleState.paused);
    final antes = adapter.chamadas;

    ActiveStoresManager.instance.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await _aguardarAte(() => adapter.chamadas > antes);

    expect(adapter.chamadas, greaterThan(antes),
        reason: 'o que estava na tela pode estar minutos desatualizado');

    // Deixa a requisição disparada acima terminar antes de sair. Sem isso ela
    // aterrissa no meio do teste seguinte — que afirma justamente que NENHUMA
    // requisição acontece — e o contador sobe por conta deste teste, não do
    // comportamento sob análise.
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

    // API cai no meio da sessão.
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
