import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/report_store_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/api_falsa.dart';
import '../../support/cofre_de_teste.dart';

final DateTime _hoje = DateTime(2026, 10, 28, 10, 0);

XFile _fotoFalsa() => XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      path: 'prova.jpg',
      name: 'prova.jpg',
      mimeType: 'image/jpeg',
    );

DenunciaService _servicoCom(ApiFalsa api) => DenunciaService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = api
          ..interceptors.add(ErrorInterceptor()),
      ),
    );

Future<void> _abrirDenuncia(
  WidgetTester tester,
  ApiFalsa api, {
  Future<XFile?> Function(BuildContext)? escolherFoto,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showReportStoreDialog(
              context,
              lojaId: 7,
              servico: _servicoCom(api),
              escolherFoto: escolherFoto ?? (_) async => _fotoFalsa(),
              agora: () => _hoje,
            ),
            child: const Text('denunciar'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('denunciar'));
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Future<void> _escolherMotivoSanitario(WidgetTester tester) async {
  await tester.tap(find.text('Outro'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(motivoRiscoSanitario).last);
  await tester.pumpAndSettle();
}

void main() {
  late ApiFalsa api;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    usarCofreEmMemoria();
    SharedPreferences.setMockInitialValues({});
    await SessionStore.instance.signIn(AuthResponse(
      token: 't',
      id: 3,
      nome: 'Ryan',
      tipo: 'CONSUMIDOR',
      email: 'ryan@exemplo.com',
      emailVerificado: true,
    ));
    api = ApiFalsa();
  });

  tearDown(() => SessionStore.instance.signOut());

  group('serviço', () {
    test('a foto sobe no campo que o servidor espera e devolve o caminho', () async {
      api.responder('POST', '/denuncias/foto', 200,
          jsonEncode({'fotoUrl': '/uploads/denuncias/abc.jpg'}));

      final url = await _servicoCom(api).enviarFoto(_fotoFalsa());

      expect(url, '/uploads/denuncias/abc.jpg');
      final chamada = api.doMetodo('POST').single;
      expect(chamada.path, '/denuncias/foto');
      expect(chamada.data, isA<FormData>());
      expect((chamada.data as FormData).files.single.key, 'file');
    });

    test('a denúncia sanitária leva data, item e foto', () async {
      api.responder('POST', '/denuncias', 200,
          jsonEncode({'id': 1, 'motivo': 'RISCO_SANITARIO', 'statusDenuncia': 'PENDENTE'}));

      await _servicoCom(api).create(
        lojaId: 7,
        consumidorId: 3,
        motivo: motivoRiscoSanitario,
        descricao: 'Passei mal',
        dataConsumo: DateTime(2026, 10, 7),
        itemConsumido: '  Espetinho  ',
        fotoUrl: '/uploads/denuncias/abc.jpg',
      );

      final corpo = api.doMetodo('POST').single.data as Map<String, dynamic>;
      expect(corpo['motivo'], 'RISCO_SANITARIO');
      expect(corpo['dataConsumo'], '2026-10-07');
      expect(corpo['itemConsumido'], 'Espetinho');
      expect(corpo['fotoUrl'], '/uploads/denuncias/abc.jpg');
    });

    test('motivo comum não manda campos sanitários', () async {
      api.responder('POST', '/denuncias', 200,
          jsonEncode({'id': 1, 'motivo': 'SPAM', 'statusDenuncia': 'PENDENTE'}));

      await _servicoCom(api).create(
        lojaId: 7,
        consumidorId: 3,
        motivo: 'Spam',
        descricao: 'Anúncio repetido',
      );

      final corpo = api.doMetodo('POST').single.data as Map<String, dynamic>;
      expect(corpo.containsKey('dataConsumo'), isFalse);
      expect(corpo.containsKey('fotoUrl'), isFalse);
    });

    test('risco sanitário agora existe na tradução de motivos', () {
      expect(MotivosDenuncia.toApi(motivoRiscoSanitario), 'RISCO_SANITARIO');
      expect(MotivosDenuncia.fromApi('RISCO_SANITARIO'), motivoRiscoSanitario);
    });
  });

  group('formulário', () {
    testWidgets('risco sanitário passou a ser oferecido', (tester) async {
      await _abrirDenuncia(tester, api);

      await tester.tap(find.text('Outro'));
      await tester.pumpAndSettle();

      expect(find.text(motivoRiscoSanitario), findsWidgets);
    });

    testWidgets('o motivo sanitário abre os três campos de prova', (tester) async {
      await _abrirDenuncia(tester, api);
      await _escolherMotivoSanitario(tester);

      expect(find.text('Data do consumo'), findsOneWidget);
      expect(find.text('Item consumido'), findsOneWidget);
      expect(find.text('Adicionar foto'), findsOneWidget);
    });

    testWidgets('sem a prova, o app avisa e não chama o servidor', (tester) async {
      await _abrirDenuncia(tester, api);
      await _escolherMotivoSanitario(tester);

      await tester.ensureVisible(find.text('Enviar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Informe a data em que você consumiu'), findsOneWidget);
      expect(api.doMetodo('POST'), isEmpty);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('com a prova completa, sobe a foto e então registra a denúncia',
        (tester) async {
      api.responder('POST', '/denuncias/foto', 200,
          jsonEncode({'fotoUrl': '/uploads/denuncias/abc.jpg'}));
      api.responder('POST', '/denuncias', 200,
          jsonEncode({'id': 1, 'motivo': 'RISCO_SANITARIO', 'statusDenuncia': 'PENDENTE'}));

      await _abrirDenuncia(tester, api);
      await _escolherMotivoSanitario(tester);

      await _tocar(tester, find.text('Data do consumo'));
      await _tocar(tester, find.text('OK'));

      await tester.enterText(find.byType(TextFormField).first, 'Espetinho');
      await tester.pumpAndSettle();
      await _tocar(tester, find.text('Adicionar foto'));

      expect(find.text('prova.jpg'), findsOneWidget);

      await _tocar(tester, find.text('Enviar'));

      final caminhos = api.doMetodo('POST').map((c) => c.path).toList();
      expect(caminhos, ['/denuncias/foto', '/denuncias']);

      final corpo = api.doMetodo('POST').last.data as Map<String, dynamic>;
      expect(corpo['fotoUrl'], '/uploads/denuncias/abc.jpg');
      expect(corpo['itemConsumido'], 'Espetinho');
      expect(corpo['dataConsumo'], '2026-10-28');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('a recusa do servidor é mostrada com a frase dele', (tester) async {
      api.responder('POST', '/denuncias', 429,
          jsonEncode({'message': 'Você já denunciou esta loja nos últimos 30 dias.'}));

      await _abrirDenuncia(tester, api);

      await _tocar(tester, find.text('Enviar'));

      expect(
        find.text('Você já denunciou esta loja nos últimos 30 dias.'),
        findsOneWidget,
      );
    });
  });
}
