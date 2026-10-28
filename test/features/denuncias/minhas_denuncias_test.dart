import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/denuncias/presentation/pages/consumer_complaints_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/api_falsa.dart';
import '../../support/cofre_de_teste.dart';

final DateTime _agora = DateTime(2026, 10, 28, 10, 0);

String _json({String? resposta, String? prazo}) => jsonEncode([
      {
        'id': 1,
        'motivo': 'RISCO_SANITARIO',
        'descricao': 'Passei mal depois de comer',
        'statusDenuncia': resposta == null ? 'PENDENTE' : 'EM_ANALISE',
        'dataDenuncia': '2026-10-27T18:00:00',
        'loja': {'id': 7, 'nome': 'Espetinho do Zé'},
        if (resposta != null) 'respostaComerciante': resposta,
        if (resposta != null) 'dataResposta': '2026-10-28T09:00:00',
        if (prazo != null) 'prazoResposta': prazo,
      }
    ]);

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
      home: ConsumerComplaintsPage(servico: _servicoCom(api), agora: () => _agora),
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
      id: 3,
      nome: 'Ryan',
      tipo: 'CONSUMIDOR',
      email: 'ryan@exemplo.com',
      emailVerificado: true,
    ));
    api = ApiFalsa();
  });

  tearDown(() => SessionStore.instance.signOut());

  testWidgets('a resposta do comerciante aparece na denúncia', (tester) async {
    api.responder('GET', '/denuncias/consumidor/3', 200,
        _json(resposta: 'A loja estava fechada nesse dia', prazo: '2026-10-29T14:30:00'));

    await _abrir(tester, api);

    expect(find.text('Resposta do comerciante'), findsOneWidget);
    expect(find.text('A loja estava fechada nesse dia'), findsOneWidget);
  });

  testWidgets('enquanto o prazo corre, diz até quando o comerciante pode responder',
      (tester) async {
    api.responder('GET', '/denuncias/consumidor/3', 200, _json(prazo: '2026-10-29T14:30:00'));

    await _abrir(tester, api);

    expect(find.textContaining('tem até 29/10/2026 para responder'), findsOneWidget);
    expect(find.text('Resposta do comerciante'), findsNothing);
  });

  testWidgets('denúncia sem direito de resposta não promete resposta nenhuma', (tester) async {
    api.responder('GET', '/denuncias/consumidor/3', 200, _json());

    await _abrir(tester, api);

    expect(find.textContaining('para responder'), findsNothing);
    expect(find.text('Resposta do comerciante'), findsNothing);
  });

  testWidgets('motivo sanitário aparece com o nome certo, não como "Outro"', (tester) async {
    api.responder('GET', '/denuncias/consumidor/3', 200, _json());

    await _abrir(tester, api);

    expect(find.text('Risco sanitário'), findsOneWidget);
  });
}
