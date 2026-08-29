import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';

/// Adapter que conta quantas requisições realmente saíram — é o que estes
/// testes medem, já que o comportamento em questão não é o payload devolvido
/// e sim quantas vezes a rede foi tocada.
class _AdapterContador implements HttpClientAdapter {
  _AdapterContador({this.statusCode = 200, this.body = '[]'});

  final int statusCode;
  final String body;
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    chamadas++;
    // Um tick de atraso: sem ele a resposta chega antes de a segunda chamada
    // concorrente acontecer, e o teste de deduplicação passaria sem exercitar
    // nada.
    await Future<void>.delayed(Duration.zero);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _payload = '[{"id": 1, "nome": "Lanches"}, {"id": 2, "nome": "Doces"}]';

(CategoriaService, _AdapterContador) _servicoComContador({
  int statusCode = 200,
  String body = _payload,
}) {
  final adapter = _AdapterContador(statusCode: statusCode, body: body);
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = adapter
    // Sem AuthInterceptor: ele leria SharedPreferences, que não existe fora de
    // um binding de teste.
    ..interceptors.add(ErrorInterceptor());
  return (CategoriaService(client: ApiClient(dio: dio)), adapter);
}

void main() {
  setUp(CategoriaService.limparCache);
  tearDown(CategoriaService.limparCache);

  test('converte o payload em CategoriaModel', () async {
    final (service, _) = _servicoComContador();

    final categorias = await service.getAll();

    expect(categorias, hasLength(2));
    expect(categorias.first.id, 1);
    expect(categorias.first.nome, 'Lanches');
  });

  test('segunda chamada é servida do cache, sem tocar a rede', () async {
    final (service, adapter) = _servicoComContador();

    await service.getAll();
    await service.getAll();

    expect(adapter.chamadas, 1);
  });

  test('quatro telas pedindo ao mesmo tempo geram uma requisição só', () async {
    // O caso real: busca, cadastro de loja, painel do comerciante e mapa da
    // home montam juntos no IndexedStack e chamam getAll() antes de qualquer
    // resposta chegar. Só o cache não resolveria — quem resolve é a
    // deduplicação da requisição em voo.
    final (service, adapter) = _servicoComContador();

    final resultados = await Future.wait([
      service.getAll(),
      service.getAll(),
      service.getAll(),
      service.getAll(),
    ]);

    expect(adapter.chamadas, 1);
    expect(resultados, everyElement(hasLength(2)));
  });

  test('instâncias diferentes compartilham o mesmo cache', () async {
    // Cada tela constrói o seu próprio CategoriaService — um cache de
    // instância não serviria para nada.
    final (primeiro, adapter) = _servicoComContador();
    await primeiro.getAll();

    final segundo = CategoriaService(client: ApiClient(dio: Dio()));
    final categorias = await segundo.getAll();

    expect(adapter.chamadas, 1);
    expect(categorias, hasLength(2));
  });

  test('forcarAtualizacao ignora o cache', () async {
    final (service, adapter) = _servicoComContador();

    await service.getAll();
    await service.getAll(forcarAtualizacao: true);

    expect(adapter.chamadas, 2);
  });

  test('falha propaga e não fica pendurada — a tentativa seguinte vai à rede', () async {
    // Sem limpar a requisição em voo no caminho de erro, toda chamada posterior
    // receberia a mesma Future já rejeitada e o app nunca se recuperaria de uma
    // falha momentânea de rede.
    final (service, adapter) = _servicoComContador(statusCode: 500, body: '{}');

    await expectLater(service.getAll(), throwsA(isA<AppException>()));
    await expectLater(service.getAll(), throwsA(isA<AppException>()));

    expect(adapter.chamadas, 2);
  });

  test('o cache devolvido não pode ser mutado por uma tela', () async {
    // A mesma lista é entregue a todas as telas: uma ordenação feita no lugar
    // por uma delas mudaria o que as outras veem.
    final (service, _) = _servicoComContador();

    final categorias = await service.getAll();

    expect(() => categorias.sort((a, b) => a.nome.compareTo(b.nome)),
        throwsUnsupportedError);
  });
}
