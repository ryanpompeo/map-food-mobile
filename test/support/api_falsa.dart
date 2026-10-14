import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/favorites/data/services/favorito_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class ApiFalsa implements HttpClientAdapter {
  final List<RequestOptions> chamadas = [];
  final Map<String, (int, String)> respostas = {};
  (int, String) padrao = (204, '');

  List<String> get patches =>
      chamadas.where((c) => c.method == 'PATCH').map((c) => c.path).toList();

  List<RequestOptions> doMetodo(String metodo) =>
      chamadas.where((c) => c.method == metodo).toList();

  void responder(String metodo, String caminho, int status, [String corpo = '']) =>
      respostas['$metodo $caminho'] = (status, corpo);

  FavoritoService get servicoFavoritos => FavoritoService(client: _apiClient);

  ApiClient get _apiClient => ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = this
          ..interceptors.add(ErrorInterceptor()),
      );

  StoreService get servico => StoreService(client: _apiClient);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    chamadas.add(options);
    final (status, corpo) = respostas['${options.method} ${options.path}'] ?? padrao;
    return ResponseBody.fromString(corpo, status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
