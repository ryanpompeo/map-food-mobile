import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sessaoConsumidor = AuthResponse(
  token: 'jwt-abc',
  tipo: 'CONSUMIDOR',
  id: 7,
  nome: 'Ana',
  email: 'ana@mapfood.com',
);

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SessionStore.instance.signOut();
  });

  test('sem sessão, o papel é GUEST', () {
    expect(SessionStore.instance.isGuest, isTrue);
    expect(SessionStore.instance.role, 'GUEST');
    expect(SessionStore.instance.userId, isNull);
  });

  test('signIn publica a sessão e persiste no AuthStorage', () async {
    await SessionStore.instance.signIn(_sessaoConsumidor);

    expect(SessionStore.instance.role, 'CONSUMIDOR');
    expect(SessionStore.instance.userId, 7);
    expect(SessionStore.instance.isConsumidor, isTrue);
    expect(await AuthStorage.getToken(), 'jwt-abc');
  });

  test('hydrate recupera a sessão gravada em disco', () async {
    await AuthStorage.saveSession(_sessaoConsumidor);
    SessionStore.instance.value = null;

    await SessionStore.instance.hydrate();

    expect(SessionStore.instance.userId, 7);
    expect(SessionStore.instance.nome, 'Ana');
  });

  test('signOut limpa memória E disco', () async {
    await SessionStore.instance.signIn(_sessaoConsumidor);

    await SessionStore.instance.signOut();

    expect(SessionStore.instance.isGuest, isTrue);
    expect(await AuthStorage.getToken(), isNull);
  });

  test('updateNomeEmail preserva token, id e tipo', () async {
    await SessionStore.instance.signIn(_sessaoConsumidor);

    await SessionStore.instance.updateNomeEmail('Ana Paula', 'anapaula@mapfood.com');

    final sessao = SessionStore.instance.value!;
    expect(sessao.nome, 'Ana Paula');
    expect(sessao.email, 'anapaula@mapfood.com');
    expect(sessao.token, 'jwt-abc');
    expect(sessao.id, 7);
    expect(sessao.tipo, 'CONSUMIDOR');
    expect((await AuthStorage.getSession())?.nome, 'Ana Paula');
  });

  test('notifica ouvintes a cada mudança de sessão', () async {
    var notificacoes = 0;
    void ouvinte() => notificacoes++;
    SessionStore.instance.addListener(ouvinte);
    addTearDown(() => SessionStore.instance.removeListener(ouvinte));

    await SessionStore.instance.signIn(_sessaoConsumidor);
    await SessionStore.instance.updateNomeEmail('Ana P.', 'ana@mapfood.com');
    await SessionStore.instance.signOut();

    expect(notificacoes, 3);
  });
}
