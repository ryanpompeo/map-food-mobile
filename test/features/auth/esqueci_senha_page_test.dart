import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/features/auth/data/services/auth_service.dart';
import 'package:map_food/features/auth/presentation/pages/esqueci_senha_page.dart';
import 'package:map_food/features/auth/presentation/pages/login_page.dart';

import '../../support/api_falsa.dart';

const _mensagem =
    'Se este e-mail estiver cadastrado, enviaremos um link de redefinição de senha.';

AuthService _servicoCom(ApiFalsa api) => AuthService(
  client: ApiClient(
    dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
      ..httpClientAdapter = api
      ..interceptors.add(ErrorInterceptor()),
  ),
);

void main() {
  late ApiFalsa api;

  setUp(() => api = ApiFalsa());

  Future<void> abrir(
    WidgetTester tester, {
    String email = '',
    String tipo = 'CONSUMIDOR',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EsqueciSenhaPage(
          emailInicial: email,
          tipoInicial: tipo,
          servico: _servicoCom(api),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('manda o e-mail e o tipo para a API e mostra a confirmação', (
    tester,
  ) async {
    api.responder(
      'POST',
      '/auth/esqueci-senha',
      200,
      jsonEncode({'mensagem': _mensagem}),
    );
    await abrir(tester, tipo: 'COMERCIANTE');

    await tester.enterText(find.byType(TextFormField), 'Ze@Exemplo.com');
    await tester.tap(find.text('Enviar link'));
    await tester.pumpAndSettle();

    final pedidos = api.doMetodo('POST');
    expect(pedidos, hasLength(1));
    expect(pedidos.single.path, '/auth/esqueci-senha');
    expect(pedidos.single.data, {
      'email': 'ze@exemplo.com',
      'tipo': 'COMERCIANTE',
    });
    expect(find.text('Confira seu e-mail'), findsOneWidget);
    expect(find.text(_mensagem), findsOneWidget);
    expect(find.textContaining('ze@exemplo.com'), findsOneWidget);
  });

  testWidgets('e-mail inválido não chega a chamar a API', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextFormField), 'isso-nao-e-email');
    await tester.tap(find.text('Enviar link'));
    await tester.pumpAndSettle();

    expect(api.chamadas, isEmpty);
    expect(find.text('Confira seu e-mail'), findsNothing);
  });

  testWidgets('falha do servidor fica no formulário com o aviso de erro', (
    tester,
  ) async {
    api.responder('POST', '/auth/esqueci-senha', 500, '');
    await abrir(tester, email: 'ana@exemplo.com');

    await tester.tap(find.text('Enviar link'));
    await tester.pumpAndSettle();

    expect(find.byType(FormErrorBanner), findsOneWidget);
    expect(find.text('Confira seu e-mail'), findsNothing);
  });

  testWidgets('resposta sem mensagem usa o texto padrão', (tester) async {
    api.responder('POST', '/auth/esqueci-senha', 200, '{}');
    await abrir(tester, email: 'ana@exemplo.com');

    await tester.tap(find.text('Enviar link'));
    await tester.pumpAndSettle();

    expect(find.text(_mensagem), findsOneWidget);
  });

  testWidgets('"Enviar de novo" repete o pedido para o mesmo e-mail', (
    tester,
  ) async {
    api.responder(
      'POST',
      '/auth/esqueci-senha',
      200,
      jsonEncode({'mensagem': _mensagem}),
    );
    await abrir(tester, email: 'ana@exemplo.com');

    await tester.tap(find.text('Enviar link'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enviar de novo'));
    await tester.tap(find.text('Enviar de novo'));
    await tester.pumpAndSettle();

    final pedidos = api.doMetodo('POST');
    expect(pedidos, hasLength(2));
    expect(pedidos.last.data, {
      'email': 'ana@exemplo.com',
      'tipo': 'CONSUMIDOR',
    });
    expect(find.text('Enviamos de novo'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets(
    'o link do login abre a tela com o e-mail e o tipo já preenchidos',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const LoginPage()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Comerciante'));
      await tester.enterText(
        find.byType(TextFormField).first,
        'ze@exemplo.com',
      );
      await tester.ensureVisible(find.text('Esqueceu sua senha?'));
      await tester.tap(find.text('Esqueceu sua senha?'));
      await tester.pumpAndSettle();

      final tela = tester.widget<EsqueciSenhaPage>(
        find.byType(EsqueciSenhaPage),
      );
      expect(tela.emailInicial, 'ze@exemplo.com');
      expect(tela.tipoInicial, 'COMERCIANTE');
      expect(
        find.widgetWithText(TextFormField, 'ze@exemplo.com'),
        findsOneWidget,
      );
    },
  );
}
