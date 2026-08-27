import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/core/network/interceptors/auth_interceptor.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_manager.dart';

class ApiClient {
  /// Construtor público com [dio] opcional: é a **única** costura que permite
  /// testar a camada de dados sem uma API real em `localhost:8080`.
  ///
  /// Em produção nada muda — todos os services continuam usando [instance].
  /// O parâmetro existe para que um teste possa passar um `Dio` com
  /// `HttpClientAdapter` falso e exercitar service + model de ponta a ponta.
  ApiClient({Dio? dio}) : _dio = dio ?? _buildDefault();

  final Dio _dio;

  static Dio _buildDefault() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);
    return dio;
  }

  /// Instância de produção. Continua sendo o caminho padrão de todo o app.
  static ApiClient instance = ApiClient();

  /// Substitui a instância de produção num teste. Chame
  /// `addTearDown(ApiClient.resetInstance)` para não vazar entre casos.
  @visibleForTesting
  static void overrideInstance(ApiClient client) => instance = client;

  @visibleForTesting
  static void resetInstance() => instance = ApiClient();

  /// Teto de tempo para envio de imagem (capa, galeria, foto de perfil).
  /// Fica aqui, e não repetido em cada service, porque é uma característica do
  /// transporte — os três services de upload compartilham exatamente o mesmo.
  static final Options uploadOptions = Options(
    sendTimeout: ApiConstants.uploadTimeout,
    receiveTimeout: ApiConstants.uploadTimeout,
  );

  /// Converte o corpo da resposta em [T], ou lança [ParseException].
  ///
  /// A versão anterior terminava em `data as T` (e `null as T` no corpo vazio):
  /// um `200 OK` sem corpo numa rota de lista, ou um payload em formato
  /// divergente, viravam `TypeError`. Como `TypeError` não é [AppException],
  /// escapava de todo `on AppException catch` do app e caía nos `catch (_)`
  /// genéricos das telas — o erro sumia ou aparecia como falha de rede.
  T _parseResponse<T>(dynamic data) {
    if (data == null || (data is String && data.trim().isEmpty)) {
      // Corpo vazio só é resposta válida quando quem chamou espera algo
      // anulável (`T?`) ou `dynamic` — o caso dos DELETE e dos POST de upload.
      if (null is T) return null as T;
      throw const ParseException('O servidor devolveu uma resposta vazia.');
    }
    if (data is T) return data;
    if (data is String) {
      final Object? decoded;
      try {
        decoded = jsonDecode(data);
      } on FormatException {
        // Antes este catch era mudo e o fluxo caía no `as T` abaixo, que
        // estourava escondendo a causa real (ex: página HTML de um proxy).
        throw const ParseException(
          'O servidor devolveu um conteúdo que não é JSON.',
        );
      }
      if (decoded is T) return decoded;
      throw ParseException(
        'Formato inesperado: esperava $T, recebeu ${decoded.runtimeType}.',
      );
    }
    throw ParseException(
      'Formato inesperado: esperava $T, recebeu ${data.runtimeType}.',
    );
  }

  /// Converte o DioException em AppException e, se for 401, dispara a
  /// limpeza de sessão global antes de relançar.
  ///
  /// [handle401] existe para as rotas em que 401 é **resposta de negócio**, e
  /// não sessão expirada: no login, "senha incorreta" é um 401 legítimo, e
  /// tratá-lo como expiração desconectaria à força quem está apenas trocando
  /// de conta com uma sessão ainda válida no aparelho.
  Never _throwFrom(DioException e, {bool handle401 = true}) {
    final exception = (e.error is AppException) ? e.error as AppException : const NetworkException();
    if (handle401 && exception is UnauthorizedException) {
      unawaited(SessionManager.handleUnauthorized(exception.message));
    }
    throw exception;
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parseResponse<T>(response.data);
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  /// [options] existe para as rotas de upload, que precisam de um teto de
  /// tempo próprio (ver [ApiConstants.uploadTimeout]); [handle401] para as
  /// rotas em que 401 é resposta de negócio (ver [_throwFrom]).
  Future<T> post<T>(
    String path, {
    dynamic data,
    Options? options,
    bool handle401 = true,
  }) async {
    try {
      final response = await _dio.post(path, data: data, options: options);
      return _parseResponse<T>(response.data);
    } on DioException catch (e) {
      _throwFrom(e, handle401: handle401);
    }
  }

  Future<T> put<T>(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.put(path, data: data, options: options);
      return _parseResponse<T>(response.data);
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<T> patch<T>(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.patch(path, data: data, options: options);
      return _parseResponse<T>(response.data);
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }

  Future<void> delete(String path, {Options? options}) async {
    try {
      await _dio.delete(path, options: options);
    } on DioException catch (e) {
      _throwFrom(e);
    }
  }
}