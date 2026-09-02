import 'package:flutter/foundation.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';

class SessionStore extends ValueNotifier<AuthResponse?> {
  SessionStore._() : super(null);

  static final SessionStore instance = SessionStore._();

  String get role => value?.tipo ?? 'GUEST';

  bool get isGuest => value == null;
  bool get isConsumidor => role == 'CONSUMIDOR';
  bool get isComerciante => role == 'COMERCIANTE';

  int? get userId => value?.id;

  String get nome => value?.nome ?? '';
  String get email => value?.email ?? '';

  Future<void> hydrate() async {
    value = await AuthStorage.getSession();
  }

  Future<void> signIn(AuthResponse sessao) async {
    await AuthStorage.saveSession(sessao);
    value = sessao;
  }

  Future<void> signOut() async {
    await AuthStorage.clear();
    value = null;
  }

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
