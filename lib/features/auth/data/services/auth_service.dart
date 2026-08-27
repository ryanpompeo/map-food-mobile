import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// Autentica e persiste a sessão.
  ///
  /// Passa pelo [ApiClient] como todo o resto do app: o `ErrorInterceptor` já
  /// traduz 401 em `UnauthorizedException`, 5xx em `ServerException` e timeout
  /// em `NetworkException`. Antes, este método criava um `Dio` avulso por
  /// chamada — sem interceptors, com `validateStatus` próprio e um mapeamento
  /// de erro reimplementado à mão que chegava a expor o tipo interno da
  /// exceção Dart na tela ("Erro: DioException — ...").
  ///
  /// `handle401: false` é essencial: aqui um 401 significa "credenciais
  /// inválidas", não "sessão expirada". Sem isso, errar a senha ao trocar de
  /// conta derrubaria a sessão ainda válida no aparelho.
  Future<AuthResponse> login(String email, String senha, String tipo) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'senha': senha, 'tipo': tipo},
      handle401: false,
    );

    final autenticado = AuthResponse.fromJson(json);

    // A API nem sempre devolve o e-mail no corpo do login; preserva o que foi
    // digitado para a sessão não nascer sem esse campo.
    final sessao = autenticado.email.isNotEmpty
        ? autenticado
        : AuthResponse(
            token: autenticado.token,
            tipo: autenticado.tipo,
            id: autenticado.id,
            nome: autenticado.nome,
            email: email,
          );

    // signIn persiste E publica: nenhuma tela precisa reler o disco depois do
    // login para saber quem entrou.
    await SessionStore.instance.signIn(sessao);
    return sessao;
  }

  Future<void> logout() => SessionStore.instance.signOut();
}
