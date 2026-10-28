import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/storage/cofre_seguro.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuthResponse _sessao() => AuthResponse(
      token: 'jwt-de-verdade',
      id: 7,
      nome: 'Ryan',
      tipo: 'CONSUMIDOR',
      email: 'ryan@exemplo.com',
      emailVerificado: true,
    );

void main() {
  late CofreEmMemoria cofre;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    cofre = CofreEmMemoria();
    substituirCofre(cofre);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(restaurarCofre);

  test('entrar guarda a chave no cofre, não no armazenamento comum', () async {
    await AuthStorage.saveSession(_sessao());

    expect(cofre.valores['auth_token'], 'jwt-de-verdade');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
    expect(prefs.getString('user_nome'), 'Ryan');
  });

  test('quem já estava logado tem a chave movida para o cofre, sem deslogar', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'jwt-da-versao-antiga',
      'user_id': 7,
      'user_nome': 'Ryan',
      'user_tipo': 'CONSUMIDOR',
      'user_email': 'ryan@exemplo.com',
    });

    final sessao = await AuthStorage.getSession();

    expect(sessao?.token, 'jwt-da-versao-antiga');
    expect(sessao?.nome, 'Ryan');
    expect(cofre.valores['auth_token'], 'jwt-da-versao-antiga');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull,
        reason: 'deixar a chave nos dois lugares anula a mudança');
  });

  test('a sessão junta a chave do cofre com os dados do armazenamento comum', () async {
    await AuthStorage.saveSession(_sessao());

    final sessao = await AuthStorage.getSession();

    expect(sessao?.token, 'jwt-de-verdade');
    expect(sessao?.id, 7);
    expect(sessao?.email, 'ryan@exemplo.com');
    expect(sessao?.emailVerificado, isTrue);
  });

  test('sair apaga a chave do cofre', () async {
    await AuthStorage.saveSession(_sessao());

    await AuthStorage.clear();

    expect(cofre.valores, isEmpty);
    expect(await AuthStorage.getToken(), isNull);
    expect(await AuthStorage.getSession(), isNull);
  });

  test('cofre que não responde deixa o app deslogado, não travado', () async {
    await AuthStorage.saveSession(_sessao());
    cofre.quebrado = true;

    expect(await AuthStorage.getToken(), isNull);
    expect(await AuthStorage.getSession(), isNull);
  });
}
