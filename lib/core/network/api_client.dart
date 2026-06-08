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
      ),
    );
    _dio.interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);
  }

  static ApiClient get instance => _instance ??= ApiClient._();

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : const NetworkException();
    }
  }

  Future<T> post<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as T;
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : const NetworkException();
    }
  }

  Future<T> put<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as T;
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