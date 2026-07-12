import 'package:flutter/foundation.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/consumer/data/models/consumer_model.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';

/// Estado do usuário logado, reativo — fonte de verdade em memória durante
/// a sessão. Sincroniza com `AuthStorage` (SharedPreferences) apenas nas
/// bordas (login, logout, edição de perfil), não a cada leitura.
///
/// Qualquer tela que precise refletir nome/e-mail atualizados na hora (sem
/// um novo GET nem reiniciar o app) deve ouvir este singleton, igual ao
/// padrão já usado por `FavoritesManager`/`AppThemeController`.
class AuthController extends ChangeNotifier {
  AuthController._();
  static final AuthController instance = AuthController._();

  AuthResponse? _session;
  AuthResponse? get session => _session;

  /// Carrega a sessão persistida. Chamado uma vez ao entrar na área logada.
  Future<void> load() async {
    _session = await AuthStorage.getSession();
    notifyListeners();
  }

  void setSession(AuthResponse session) {
    _session = session;
    notifyListeners();
  }

  Future<void> clear() async {
    _session = null;
    await AuthStorage.clear();
    notifyListeners();
  }

  /// Chama o PUT /consumidores/{id} e, assim que a resposta chega com
  /// sucesso, atualiza a sessão em memória e notifica os listeners — é
  /// esse `notifyListeners()` que faz a ProfilePage mostrar o novo
  /// nome/e-mail imediatamente, sem um novo GET nem reiniciar o app.
  Future<void> updateConsumerProfile(ConsumerModel dadosAtualizados, {String? novaSenha}) async {
    final salvo = await ConsumerService().update(dadosAtualizados, novaSenha: novaSenha);

    _session = AuthResponse(
      token: _session!.token,
      tipo: _session!.tipo,
      id: salvo.id,
      nome: salvo.nome,
      email: salvo.email,
    );
    notifyListeners();

    await AuthStorage.saveSession(_session!);
  }
}
