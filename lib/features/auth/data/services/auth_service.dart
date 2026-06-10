import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';

class AuthService {
  Future<AuthResponse> login(String email, String senha, String tipo) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.login}',
        data: {'email': email, 'senha': senha, 'tipo': tipo},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        final Map<String, dynamic> json =
            raw is String ? jsonDecode(raw) as Map<String, dynamic> : raw as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(json);
        await AuthStorage.saveSession(authResponse);
        return authResponse;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException('Credenciais inválidas.');
      } else {
        throw AppException(
          'Erro ao fazer login.',
          statusCode: response.statusCode ?? 0,
        );
      }
    } on UnauthorizedException {
      rethrow;
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Credenciais inválidas.');
      }
      throw AppException('Erro de conexão: ${e.type.name} — ${e.message}');
    } catch (e) {
      throw AppException('Erro: ${e.runtimeType} — $e');
    }
  }

  Future<void> logout() => AuthStorage.clear();
}