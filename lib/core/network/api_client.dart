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

  static ApiClient instance = ApiClient();

  @visibleForTesting
  static void overrideInstance(ApiClient client) => instance = client;

  @visibleForTesting
  static void resetInstance() => instance = ApiClient();

  static final Options uploadOptions = Options(
    sendTimeout: ApiConstants.uploadTimeout,
    receiveTimeout: ApiConstants.uploadTimeout,
  );

  T _parseResponse<T>(dynamic data) {
    if (data == null || (data is String && data.trim().isEmpty)) {
      if (null is T) return null as T;
      throw const ParseException('O servidor devolveu uma resposta vazia.');
    }
    if (data is T) return data;
    if (data is String) {
      final Object? decoded;
      try {
        decoded = jsonDecode(data);
      } on FormatException {
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
