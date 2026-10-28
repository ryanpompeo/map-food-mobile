import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/auth/data/services/verificacao_email_service.dart';
import 'package:map_food/features/auth/presentation/pages/verificar_email_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../support/cofre_de_teste.dart';

class _ServicoFalso extends VerificacaoEmailService {
  _ServicoFalso({this.erroAoConfirmar, this.erroAoEnviar, this.situacaoDoServidor})
      : super(client: ApiClient(dio: Dio()));

  final AppException? erroAoConfirmar;
  final AppException? erroAoEnviar;
  final SituacaoVerificacao? situacaoDoServidor;

  final List<String> confirmados = [];
  int envios = 0;
  int consultas = 0;

  @override
  Future<SituacaoVerificacao?> situacao() async {
    consultas++;
    return situacaoDoServidor;
  }

  @override
  Future<void> confirmar(String codigo) async {
    confirmados.add(codigo);
    final erro = erroAoConfirmar;
    if (erro != null) throw erro;
    await SessionStore.instance.marcarEmailVerificado(true);
  }

  @override
  Future<int?> enviarCodigo() async {
    envios++;
    final erro = erroAoEnviar;
    if (erro != null) throw erro;
    return null;
  }
}

void main() {
  late _ServicoFalso servico;

  const naoVerificado = AuthResponse(
    token: 't',
    tipo: 'CONSUMIDOR',
    id: 9,
    nome: 'Ana',
    email: 'ana@mapfood.test',
    emailVerificado: false,
  );

  Future<bool?> abrir(WidgetTester tester, {bool codigoJaEnviado = true}) async {
    bool? resultado;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                resultado = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => VerificarEmailPage(
                      servico: servico,
                      codigoJaEnviado: codigoJaEnviado,
                    ),
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return resultado;
  }

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    usarCofreEmMemoria();
    SharedPreferences.setMockInitialValues({});
    servico = _ServicoFalso();
    await SessionStore.instance.signIn(naoVerificado);
  });

  tearDown(() => SessionStore.instance.signOut());

  testWidgets('mostra para qual e-mail o código foi enviado', (tester) async {
    await abrir(tester);

    expect(find.textContaining('ana@mapfood.test'), findsOneWidget);
  });

  testWidgets('código certo confirma, marca a sessão e fecha a tela', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(servico.confirmados, ['123456']);
    expect(SessionStore.instance.emailVerificado, isTrue);
    expect(find.text('Confirmar'), findsNothing);
  });

  testWidgets('código incompleto nem chega a chamar a API', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(servico.confirmados, isEmpty);
    expect(find.textContaining('Digite os 6 números'), findsOneWidget);
  });

  testWidgets('erro da API aparece com a mensagem que veio de lá', (tester) async {
    servico = _ServicoFalso(
      erroAoConfirmar: AppException('Código expirado. Solicite um novo código.', statusCode: 400),
    );
    await abrir(tester);

    await tester.enterText(find.byType(TextFormField), '000000');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Código expirado. Solicite um novo código.'), findsOneWidget);
    expect(SessionStore.instance.emailVerificado, isFalse);
  });

  testWidgets('reenviar fica bloqueado logo depois do código sair', (tester) async {
    await abrir(tester);

    expect(find.textContaining('Reenviar em'), findsOneWidget);

    await tester.tap(find.textContaining('Reenviar em'));
    await tester.pump();

    expect(servico.envios, 0);
  });

  testWidgets('sem código enviado ainda, dá para pedir um na hora', (tester) async {
    await abrir(tester, codigoJaEnviado: false);

    await tester.tap(find.text('Reenviar código'));
    await tester.pumpAndSettle();

    expect(servico.envios, 1);
    expect(find.textContaining('Reenviar em'), findsOneWidget);
  });

  testWidgets('"confirmar depois" fecha a tela sem confirmar nada', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('Confirmar depois'));
    await tester.pumpAndSettle();

    expect(servico.confirmados, isEmpty);
    expect(SessionStore.instance.emailVerificado, isFalse);
  });

  testWidgets('falha ao reenviar aparece na tela e libera nova tentativa', (tester) async {
    servico = _ServicoFalso(
      erroAoEnviar: AppException('Não foi possível enviar o e-mail agora.', statusCode: 500),
    );
    await abrir(tester, codigoJaEnviado: false);

    await tester.tap(find.text('Reenviar código'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível enviar o e-mail agora.'), findsOneWidget);
    expect(find.text('Reenviar código'), findsOneWidget);
  });

  group('situação vinda do servidor', () {
    testWidgets('conta já verificada fecha a tela sozinha', (tester) async {
      servico = _ServicoFalso(
        situacaoDoServidor: const SituacaoVerificacao(jaVerificado: true),
      );

      await abrir(tester);

      expect(find.text('Confirmar'), findsNothing);
      expect(SessionStore.instance.emailVerificado, isTrue);
    });

    testWidgets('a espera é a que o servidor informa, não um palpite do app', (tester) async {
      servico = _ServicoFalso(
        situacaoDoServidor: const SituacaoVerificacao(
          jaVerificado: false,
          email: 'ana@mapfood.test',
          codigoPendente: true,
          aguardeSegundos: 25,
        ),
      );

      await abrir(tester);

      expect(find.text('Reenviar em 25s'), findsOneWidget);
    });

    testWidgets('limite diário bloqueia o reenvio e explica o motivo', (tester) async {
      servico = _ServicoFalso(
        situacaoDoServidor: const SituacaoVerificacao(jaVerificado: false, limiteDiario: true),
      );

      await abrir(tester);
      await tester.tap(find.text('Limite de códigos por hoje'));
      await tester.pump();

      expect(servico.envios, 0);
    });

    testWidgets('servidor fora do ar não trava a tela: volta ao comportamento simples', (tester) async {
      servico = _ServicoFalso();

      await abrir(tester);

      expect(servico.consultas, 1);
      expect(find.textContaining('Reenviar em'), findsOneWidget);
    });

    testWidgets('recusa por excesso reinicia a espera com os segundos do servidor', (tester) async {
      servico = _ServicoFalso(
        erroAoEnviar: AppException(
          'Um código já foi enviado há pouco. Aguarde 42s para solicitar outro.',
          statusCode: 429,
          dados: const {'aguardeSegundos': 42},
        ),
      );

      await abrir(tester, codigoJaEnviado: false);
      await tester.tap(find.text('Reenviar código'));
      await tester.pumpAndSettle();

      expect(find.text('Reenviar em 42s'), findsOneWidget);
    });
  });
}
