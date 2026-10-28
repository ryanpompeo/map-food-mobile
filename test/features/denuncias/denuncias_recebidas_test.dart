import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/denuncias/presentation/pages/merchant_complaints_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/api_falsa.dart';
import '../../support/cofre_de_teste.dart';

final DateTime _agora = DateTime(2026, 10, 28, 10, 0);

String _json({
  int id = 1,
  String motivo = 'RISCO_SANITARIO',
  String status = 'PENDENTE',
  String? prazo = '2026-10-29T14:30:00',
  String? resposta,
  String? foto,
}) {
  final mapa = <String, dynamic>{
    'id': id,
    'motivo': motivo,
    'descricao': 'Passei mal depois de comer',
    'dataDenuncia': '2026-10-27T18:00:00',
    'statusDenuncia': status,
    'lojaId': 7,
    'lojaNome': 'Espetinho do Zé',
    'dataConsumo': '2026-10-27',
    'itemConsumido': 'Espetinho de frango',
    if (foto != null) 'fotoUrl': foto,
    if (resposta != null) 'respostaComerciante': resposta,
    if (resposta != null) 'dataResposta': '2026-10-28T09:00:00',
    if (prazo != null) 'prazoResposta': prazo,
  };
  return jsonEncode(mapa);
}

DenunciaService _servicoCom(ApiFalsa api) => DenunciaService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = api
          ..interceptors.add(ErrorInterceptor()),
      ),
    );

Future<void> _abrir(WidgetTester tester, ApiFalsa api) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MerchantComplaintsPage(servico: _servicoCom(api), agora: () => _agora),
    ),
  );
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
      id: 5,
      nome: 'Zé',
      tipo: 'COMERCIANTE',
      email: 'ze@exemplo.com',
      emailVerificado: true,
    ));
    api = ApiFalsa();
  });

  tearDown(() => SessionStore.instance.signOut());

  group('modelo', () {
    test('lê os campos que o app ignorava: foto, prazo, item e resposta', () {
      final denuncia = DenunciaRecebidaModel.fromJson({
        'id': 1,
        'motivo': 'RISCO_SANITARIO',
        'statusDenuncia': 'PENDENTE',
        'lojaId': 7,
        'lojaNome': 'Espetinho do Zé',
        'dataConsumo': '2026-10-27',
        'itemConsumido': 'Espetinho de frango',
        'fotoUrl': '/uploads/denuncias/abc.jpg',
        'prazoResposta': '2026-10-29T14:30:00',
      });

      expect(denuncia.itemConsumido, 'Espetinho de frango');
      expect(denuncia.fotoUrl, '/uploads/denuncias/abc.jpg');
      expect(denuncia.dataConsumo, DateTime(2026, 10, 27));
      expect(denuncia.abreDireitoDeResposta, isTrue);
      expect(denuncia.podeResponder(_agora), isTrue);
    });

    test('motivo sanitário deixou de ser mostrado como "Outro"', () {
      final denuncia = DenunciaRecebidaModel.fromJson({
        'id': 1,
        'motivo': 'RISCO_SANITARIO',
        'statusDenuncia': 'PENDENTE',
        'lojaId': 7,
        'lojaNome': 'Loja',
      });

      expect(denuncia.motivoLabel, 'Risco sanitário');
    });

    test('sem prazo, não há direito de resposta', () {
      final denuncia = DenunciaRecebidaModel.fromJson({
        'id': 1,
        'motivo': 'SPAM',
        'statusDenuncia': 'PENDENTE',
        'lojaId': 7,
        'lojaNome': 'Loja',
      });

      expect(denuncia.abreDireitoDeResposta, isFalse);
      expect(denuncia.podeResponder(_agora), isFalse);
    });

    test('prazo vencido ou já respondida fecham o campo de resposta', () {
      final vencida = DenunciaRecebidaModel.fromJson({
        'id': 1,
        'motivo': 'FRAUDE_OU_GOLPE',
        'statusDenuncia': 'PENDENTE',
        'lojaId': 7,
        'lojaNome': 'Loja',
        'prazoResposta': '2026-10-27T09:00:00',
      });
      final respondida = DenunciaRecebidaModel.fromJson({
        'id': 2,
        'motivo': 'FRAUDE_OU_GOLPE',
        'statusDenuncia': 'EM_ANALISE',
        'lojaId': 7,
        'lojaNome': 'Loja',
        'prazoResposta': '2026-10-29T09:00:00',
        'respostaComerciante': 'Não foi na minha loja',
      });

      expect(vencida.podeResponder(_agora), isFalse);
      expect(respondida.podeResponder(_agora), isFalse);
    });

    test('as que dão para responder vêm primeiro na lista', () {
      final semPrazo = DenunciaRecebidaModel.fromJson({
        'id': 1,
        'motivo': 'SPAM',
        'statusDenuncia': 'PENDENTE',
        'lojaId': 7,
        'lojaNome': 'Loja',
        'dataDenuncia': '2026-10-28T09:00:00',
      });
      final comPrazo = DenunciaRecebidaModel.fromJson({
        'id': 2,
        'motivo': 'RISCO_SANITARIO',
        'statusDenuncia': 'PENDENTE',
        'lojaId': 7,
        'lojaNome': 'Loja',
        'dataDenuncia': '2026-10-20T09:00:00',
        'prazoResposta': '2026-10-29T09:00:00',
      });

      final ordenadas = ordenarParaResponder([semPrazo, comPrazo], _agora);

      expect(ordenadas.first.id, 2);
    });
  });

  group('serviço', () {
    test('responder manda o texto para o endereço da denúncia', () async {
      api.responder('POST', '/denuncias/9/resposta', 200, _json(id: 9, resposta: 'Meu lado'));

      final atualizada = await _servicoCom(api).responder(9, '  Meu lado  ');

      final chamada = api.doMetodo('POST').single;
      expect(chamada.path, '/denuncias/9/resposta');
      expect(chamada.data, {'texto': 'Meu lado'});
      expect(atualizada.respostaComerciante, 'Meu lado');
    });
  });

  group('tela', () {
    testWidgets('mostra a acusação, o prazo e o campo de resposta', (tester) async {
      api.responder('GET', '/denuncias/loja/comerciante/5', 200, '[${_json()}]');

      await _abrir(tester, api);

      expect(find.text('Risco sanitário'), findsOneWidget);
      expect(find.text('Passei mal depois de comer'), findsOneWidget);
      expect(find.textContaining('Item: Espetinho de frango'), findsOneWidget);
      expect(find.textContaining('Você tem até 29/10 às 14:30'), findsOneWidget);
      expect(find.text('Enviar resposta'), findsOneWidget);
    });

    testWidgets('denúncia sem prazo explica que não há direito de resposta', (tester) async {
      api.responder('GET', '/denuncias/loja/comerciante/5', 200,
          '[${_json(motivo: 'SPAM', prazo: null)}]');

      await _abrir(tester, api);

      expect(find.textContaining('não abre direito de resposta'), findsOneWidget);
      expect(find.text('Enviar resposta'), findsNothing);
    });

    testWidgets('prazo vencido não oferece o campo', (tester) async {
      api.responder('GET', '/denuncias/loja/comerciante/5', 200,
          '[${_json(prazo: '2026-10-27T09:00:00')}]');

      await _abrir(tester, api);

      expect(find.textContaining('prazo de resposta terminou'), findsOneWidget);
      expect(find.text('Enviar resposta'), findsNothing);
    });

    testWidgets('já respondida mostra a resposta, não o campo', (tester) async {
      api.responder('GET', '/denuncias/loja/comerciante/5', 200,
          '[${_json(status: 'EM_ANALISE', resposta: 'Não foi na minha loja')}]');

      await _abrir(tester, api);

      expect(find.text('Sua resposta'), findsOneWidget);
      expect(find.text('Não foi na minha loja'), findsOneWidget);
      expect(find.text('Enviar resposta'), findsNothing);
    });

    testWidgets('enviar a resposta troca o campo pelo texto enviado', (tester) async {
      api.responder('GET', '/denuncias/loja/comerciante/5', 200, '[${_json()}]');
      api.responder('POST', '/denuncias/1/resposta', 200,
          _json(status: 'EM_ANALISE', resposta: 'Meu lado da história'));

      await _abrir(tester, api);

      await tester.enterText(find.byType(TextFormField), 'Meu lado da história');
      await tester.tap(find.text('Enviar resposta'));
      await tester.pumpAndSettle();

      expect(find.text('Sua resposta'), findsOneWidget);
      expect(find.text('Meu lado da história'), findsOneWidget);
      expect(find.text('Enviar resposta'), findsNothing);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('recusa do servidor aparece com a frase dele', (tester) async {
      api.responder('GET', '/denuncias/loja/comerciante/5', 200, '[${_json()}]');
      api.responder('POST', '/denuncias/1/resposta', 409,
          '{"message":"Esta denúncia já foi respondida"}');

      await _abrir(tester, api);

      await tester.enterText(find.byType(TextFormField), 'Tentando de novo');
      await tester.tap(find.text('Enviar resposta'));
      await tester.pumpAndSettle();

      expect(find.text('Esta denúncia já foi respondida'), findsOneWidget);
      expect(find.text('Enviar resposta'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('sem denúncias, diz que está tudo tranquilo', (tester) async {
      api.responder('GET', '/denuncias/loja/comerciante/5', 200, '[]');

      await _abrir(tester, api);

      expect(find.text('Nenhuma denúncia recebida'), findsOneWidget);
    });
  });
}
