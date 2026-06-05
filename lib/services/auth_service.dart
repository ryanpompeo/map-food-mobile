import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/models/auth/login_request.dart';
import 'package:map_food/models/auth/auth_response.dart';

class AuthService {
  final _client = ApiClient.instance;

  Future<AuthResponse> login(String email, String senha, String tipo) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: LoginRequest(email: email, senha: senha, tipo: tipo).toJson(),
    );
    final response = AuthResponse.fromJson(data);
    await AuthStorage.saveSession(response);
    return response;
  }

  Future<void> logout() => AuthStorage.clear();
}