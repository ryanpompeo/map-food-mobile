import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/favorites/presentation/controllers/aviso_favorita_proxima.dart';

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AuthResponse> login(String email, String senha, String tipo) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'senha': senha, 'tipo': tipo},
      handle401: false,
    );

    final autenticado = AuthResponse.fromJson(json);

    final sessao = autenticado.email.isNotEmpty
        ? autenticado
        : AuthResponse(
            token: autenticado.token,
            tipo: autenticado.tipo,
            id: autenticado.id,
            nome: autenticado.nome,
            email: email,
            emailVerificado: autenticado.emailVerificado,
          );

    await SessionStore.instance.signIn(sessao);
    AvisoFavoritaProxima.instance.ligar();
    return sessao;
  }

  Future<bool?> conferirEmailVerificado() async {
    if (SessionStore.instance.isGuest) return null;
    try {
      final json = await _client.get<Map<String, dynamic>>(ApiConstants.me);
      final valor = json['emailVerificado'];
      if (valor is! bool) return null;
      await SessionStore.instance.marcarEmailVerificado(valor);
      return valor;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() => SessionStore.instance.signOut();
}
