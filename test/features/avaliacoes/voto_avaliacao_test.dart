import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/avaliacoes/presentation/widgets/voto_avaliacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/api_falsa.dart';
import '../../support/cofre_de_teste.dart';

AvaliacaoModel _avaliacao({
  int autorId = 9,
  int likes = 3,
  int deslikes = 1,
  String? meuVoto,
}) =>
    AvaliacaoModel.fromJson({
      'id': 42,
      'nota': 5,
      'comentario': 'Muito bom',
      'consumidor': {'id': autorId, 'nome': 'Ana'},
      'totalLikes': likes,
      'totalDeslikes': deslikes,
      if (meuVoto != null) 'meuVoto': meuVoto,
    });

AvaliacaoService _servicoCom(ApiFalsa api) => AvaliacaoService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = api
          ..interceptors.add(ErrorInterceptor()),
      ),
    );

Future<void> _entrarComoConsumidor(int id) => SessionStore.instance.signIn(AuthResponse(
      token: 't',
      id: id,
      nome: 'Ryan',
      tipo: 'CONSUMIDOR',
      email: 'ryan@exemplo.com',
      emailVerificado: true,
    ));

Future<void> _abrir(WidgetTester tester, ApiFalsa api, AvaliacaoModel avaliacao) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: VotoAvaliacao(avaliacao: avaliacao, servico: _servicoCom(api)),
      ),
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
    await SessionStore.instance.signOut();
    api = ApiFalsa();
  });

  tearDown(() => SessionStore.instance.signOut());

  group('modelo', () {
    test('lê os votos que já vinham na listagem e eram ignorados', () {
      final avaliacao = _avaliacao(meuVoto: 'LIKE');

      expect(avaliacao.totalLikes, 3);
      expect(avaliacao.totalDeslikes, 1);
      expect(avaliacao.curti, isTrue);
      expect(avaliacao.naoCurti, isFalse);
    });

    test('avaliação sem votos não quebra nem inventa número', () {
      final avaliacao = AvaliacaoModel.fromJson({'id': 1, 'nota': 4});

      expect(avaliacao.totalLikes, 0);
      expect(avaliacao.meuVoto, isNull);
      expect(avaliacao.curti, isFalse);
    });
  });

  group('serviço', () {
    test('votar manda o tipo e devolve a contagem nova', () async {
      api.responder('POST', '/avaliacoes/42/votos', 200,
          jsonEncode({'totalLikes': 4, 'totalDeslikes': 1, 'meuVoto': 'LIKE'}));

      final votos = await _servicoCom(api).votar(42, votoLike);

      expect(api.doMetodo('POST').single.data, {'tipo': 'LIKE'});
      expect(votos.totalLikes, 4);
      expect(votos.meuVoto, 'LIKE');
    });
  });

  group('na tela', () {
    testWidgets('mostra as contagens que vieram do servidor', (tester) async {
      await _entrarComoConsumidor(1);

      await _abrir(tester, api, _avaliacao());

      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('marcar como útil atualiza a contagem com a resposta do servidor',
        (tester) async {
      await _entrarComoConsumidor(1);
      api.responder('POST', '/avaliacoes/42/votos', 200,
          jsonEncode({'totalLikes': 4, 'totalDeslikes': 1, 'meuVoto': 'LIKE'}));

      await _abrir(tester, api, _avaliacao());

      final semantica = tester.ensureSemantics();

      await tester.tap(find.byIcon(AppIcons.thumbsUp));
      await tester.pumpAndSettle();

      expect(find.text('4'), findsOneWidget);
      expect(find.byIcon(AppIcons.thumbsUpFill), findsOneWidget);
      final no = tester.getSemantics(find.byIcon(AppIcons.thumbsUpFill));
      expect(no.label, contains('toque para desmarcar'));

      semantica.dispose();
    });

    testWidgets('o autor vê a contagem e não os botões', (tester) async {
      await _entrarComoConsumidor(9);

      await _abrir(tester, api, _avaliacao(autorId: 9));

      expect(find.byType(SemanticTapArea), findsNothing);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('visitante não vota: o app pede para entrar', (tester) async {
      await _abrir(tester, api, _avaliacao());

      await tester.tap(find.byIcon(AppIcons.thumbsUp));
      await tester.pumpAndSettle();

      expect(api.doMetodo('POST'), isEmpty);
      expect(find.textContaining('Crie uma conta'), findsWidgets);
    });

    testWidgets('recusa do servidor aparece com a frase dele', (tester) async {
      await _entrarComoConsumidor(1);
      api.responder('POST', '/avaliacoes/42/votos', 403,
          jsonEncode({'message': 'Voce nao pode votar na propria avaliacao'}));

      await _abrir(tester, api, _avaliacao());

      await tester.tap(find.byIcon(AppIcons.thumbsUp));
      await tester.pumpAndSettle();

      expect(find.text('Voce nao pode votar na propria avaliacao'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });
}
