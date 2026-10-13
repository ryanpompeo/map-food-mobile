import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/auth/presentation/widgets/aviso_email_nao_verificado.dart';
import 'package:map_food/features/auth/presentation/widgets/faixa_email_nao_verificado.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pendente = AuthResponse(
  token: 't',
  tipo: 'CONSUMIDOR',
  id: 9,
  nome: 'Ana',
  email: 'ana@mapfood.test',
  emailVerificado: false,
);

const _verificado = AuthResponse(
  token: 't',
  tipo: 'CONSUMIDOR',
  id: 9,
  nome: 'Ana',
  email: 'ana@mapfood.test',
);

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() => SessionStore.instance.signOut());

  group('reconhecer o bloqueio', () {
    test('403 com a mensagem do servidor é bloqueio de e-mail', () {
      final erro = AppException('Confirme seu e-mail para poder avaliar lojas.', statusCode: 403);

      expect(ehBloqueioPorEmailNaoVerificado(erro), isTrue);
    });

    test('403 de outro motivo não vira pedido de confirmação', () async {
      await SessionStore.instance.signIn(_verificado);
      final erro = AppException('Acesso negado', statusCode: 403);

      expect(ehBloqueioPorEmailNaoVerificado(erro), isFalse);
    });

    test('403 genérico conta quando a própria sessão sabe que está pendente', () async {
      await SessionStore.instance.signIn(_pendente);
      final erro = AppException('Acesso negado', statusCode: 403);

      expect(ehBloqueioPorEmailNaoVerificado(erro), isTrue);
    });

    test('erro que não é 403 nunca conta', () {
      expect(
        ehBloqueioPorEmailNaoVerificado(AppException('Erro no servidor', statusCode: 500)),
        isFalse,
      );
      expect(ehBloqueioPorEmailNaoVerificado(Exception('qualquer coisa')), isFalse);
    });
  });

  group('faixa no perfil', () {
    Future<void> montar(WidgetTester tester) => tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: FaixaEmailNaoVerificado()),
          ),
        );

    testWidgets('aparece enquanto o e-mail está pendente', (tester) async {
      await SessionStore.instance.signIn(_pendente);

      await montar(tester);

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
    });

    testWidgets('some assim que a pessoa confirma, sem recarregar a tela', (tester) async {
      await SessionStore.instance.signIn(_pendente);
      await montar(tester);
      expect(find.text('Confirme seu e-mail'), findsOneWidget);

      await SessionStore.instance.marcarEmailVerificado(true);
      await tester.pump();

      expect(find.text('Confirme seu e-mail'), findsNothing);
    });

    testWidgets('visitante não vê faixa nenhuma', (tester) async {
      await SessionStore.instance.signOut();

      await montar(tester);

      expect(find.text('Confirme seu e-mail'), findsNothing);
    });
  });
}
