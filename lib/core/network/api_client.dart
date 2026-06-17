import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/core/network/interceptors/auth_interceptor.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/errors/exception.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);
  }

  static ApiClient get instance => _instance ??= ApiClient._();

  T _parseResponse<T>(dynamic data) {
    if (data == null || (data is String && data.trim().isEmpty)) {
      return null as T;
    }
    if (data is T) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is T) return decoded;
      } catch (_) {}
    }
    return data as T;
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parseResponse<T>(response.data);
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : const NetworkException();
    }
  }

  Future<T> post<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _parseResponse<T>(response.data);
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : const NetworkException();
    }
  }

  Future<T> put<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _parseResponse<T>(response.data);
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : const NetworkException();
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : const NetworkException();
    }
  }
}