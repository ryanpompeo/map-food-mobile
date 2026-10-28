import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/auth/presentation/widgets/aviso_email_nao_verificado.dart';
import 'package:map_food/features/auth/presentation/widgets/faixa_email_nao_verificado.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/cofre_de_teste.dart';

Future<void> _entrar(String tipo) => SessionStore.instance.signIn(AuthResponse(
      token: 't',
      id: 5,
      nome: 'Zé',
      tipo: tipo,
      email: 'ze@exemplo.com',
      emailVerificado: false,
    ));

Future<void> _abrir(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: FaixaEmailNaoVerificado()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    usarCofreEmMemoria();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() => SessionStore.instance.signOut());

  group('motivo por tipo de conta', () {
    test('ao consumidor, a confirmação destrava avaliar e denunciar', () {
      final texto = motivoParaConfirmarEmail(comerciante: false);

      expect(texto, contains('avaliar'));
      expect(texto, contains('denunciar'));
    });

    test('ao comerciante, não promete destravar o que ele não faz', () {
      final texto = motivoParaConfirmarEmail(comerciante: true);

      expect(texto, isNot(contains('avaliar')));
      expect(texto, contains('e-mail é seu'));
      expect(texto, contains('denúncias que sua loja receber'));
    });

    test('a frase curta da tela de confirmação segue a mesma regra', () {
      expect(motivoCurtoParaConfirmarEmail(comerciante: false),
          contains('não dá para avaliar'));
      expect(motivoCurtoParaConfirmarEmail(comerciante: true),
          isNot(contains('avaliar')));
    });
  });

  group('faixa no perfil', () {
    testWidgets('consumidor vê a frase das funções bloqueadas', (tester) async {
      await _entrar('CONSUMIDOR');

      await _abrir(tester);

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      expect(find.textContaining('não consegue avaliar nem denunciar'), findsOneWidget);
    });

    testWidgets('comerciante vê a frase da conta, sem falar de avaliar', (tester) async {
      await _entrar('COMERCIANTE');

      await _abrir(tester);

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      expect(find.textContaining('avaliar'), findsNothing);
      expect(find.textContaining('denúncias que sua loja receber'), findsOneWidget);
    });

    testWidgets('com o e-mail já confirmado, a faixa não aparece', (tester) async {
      await SessionStore.instance.signIn(AuthResponse(
        token: 't',
        id: 5,
        nome: 'Zé',
        tipo: 'COMERCIANTE',
        email: 'ze@exemplo.com',
        emailVerificado: true,
      ));

      await _abrir(tester);

      expect(find.text('Confirme seu e-mail'), findsNothing);
    });
  });
}
