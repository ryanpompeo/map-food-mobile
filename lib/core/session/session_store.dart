import 'package:flutter/foundation.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';

/// Sessão do usuário em memória — fonte única e **síncrona** de quem está
/// logado e com que papel.
///
/// Existe porque o papel do usuário era descoberto de duas formas ruins ao
/// mesmo tempo:
///
/// 1. `AuthStorage.getSession()` chamado em 19 lugares diferentes — I/O
///    assíncrono em `SharedPreferences` seguido de um `setState` que
///    reconstruía a tela inteira só para escrever uma string; e
/// 2. `userRole` empurrado por construtor através de até 4 níveis de widget
///    (`SearchPage` → carrossel → card → botão de favorito).
///
/// [AuthStorage] continua sendo a camada de **persistência**; esta classe é o
/// espelho em memória, hidratado uma vez no `main()` e atualizado nos três
/// pontos que realmente mudam sessão: login, logout e edição de perfil.
class SessionStore extends ValueNotifier<AuthResponse?> {
  SessionStore._() : super(null);

  static final SessionStore instance = SessionStore._();

  /// Papel do usuário no vocabulário que a UI já usa: 'CONSUMIDOR',
  /// 'COMERCIANTE' ou 'GUEST' quando não há sessão.
  String get role => value?.tipo ?? 'GUEST';

  bool get isGuest => value == null;
  bool get isConsumidor => role == 'CONSUMIDOR';
  bool get isComerciante => role == 'COMERCIANTE';

  /// Id do usuário logado, ou `null` para visitante. Substitui o
  /// `(await AuthStorage.getSession())?.id` espalhado pelas telas.
  int? get userId => value?.id;

  String get nome => value?.nome ?? '';
  String get email => value?.email ?? '';

  /// Carrega a sessão persistida. Chamado uma vez no `main()`, antes do
  /// `runApp` — a partir daí toda leitura é síncrona.
  Future<void> hydrate() async {
    value = await AuthStorage.getSession();
  }

  /// Persiste e publica a nova sessão (login / cadastro com login automático).
  Future<void> signIn(AuthResponse sessao) async {
    await AuthStorage.saveSession(sessao);
    value = sessao;
  }

  /// Limpa persistência e memória (logout, exclusão de conta, 401).
  Future<void> signOut() async {
    await AuthStorage.clear();
    value = null;
  }

  /// Reflete uma edição de perfil já salva no backend. Mantém token, id e tipo.
  Future<void> updateNomeEmail(String nome, String email) async {
    final atual = value;
    if (atual == null) return;
    await AuthStorage.updateNomeEmail(nome, email);
    value = AuthResponse(
      token: atual.token,
      tipo: atual.tipo,
      id: atual.id,
      nome: nome,
      email: email,
    );
  }
}
