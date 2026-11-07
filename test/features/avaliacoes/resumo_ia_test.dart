import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/avaliacoes/presentation/widgets/card_resumo_ia.dart';

import '../../support/api_falsa.dart';

AvaliacaoService _servicoCom(ApiFalsa api) => AvaliacaoService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = api
          ..interceptors.add(ErrorInterceptor()),
      ),
    );

Widget _cartao(
  AvaliacaoService servico, {
  int comentarios = 5,
  bool modoComerciante = true,
  bool automatico = false,
}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: CardResumoIA(
          lojaId: 7,
          totalComentarios: comentarios,
          modoComerciante: modoComerciante,
          automatico: automatico,
          servico: servico,
        ),
      ),
    );

Future<void> _abrir(
  WidgetTester tester,
  ApiFalsa api, {
  int comentarios = 5,
  bool modoComerciante = true,
  bool automatico = false,
}) async {
  await tester.pumpWidget(_cartao(
    _servicoCom(api),
    comentarios: comentarios,
    modoComerciante: modoComerciante,
    automatico: automatico,
  ));
  await tester.pumpAndSettle();
}

void main() {
  late ApiFalsa api;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    api = ApiFalsa();
  });

  testWidgets('com poucos comentários, o cartão não aparece', (tester) async {
    await _abrir(tester, api, comentarios: 2);

    expect(find.text('Insights com IA'), findsNothing);
    expect(api.chamadas, isEmpty, reason: 'a IA custa chamada: nem tenta');
  });

  testWidgets('o comerciante pede os insights, não ganha sozinho', (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({
          'resumo': 'Clientes elogiam o atendimento e reclamam da espera.',
          'totalAvaliacoes': 5,
          'alertas': ['Três comentários citam demora acima de 40 minutos'],
        }));

    await _abrir(tester, api);

    expect(find.text('Insights com IA'), findsOneWidget);
    expect(api.doMetodo('GET'), isEmpty, reason: 'sem toque, sem chamada à IA');

    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    final chamada = api.doMetodo('GET').single;
    expect(chamada.path, '/avaliacoes/loja/7/resumo');
    expect(chamada.queryParameters['modo'], 'comerciante');
    expect(find.textContaining('elogiam o atendimento'), findsOneWidget);
    expect(find.textContaining('demora acima de 40 minutos'), findsOneWidget);
    expect(find.textContaining('gerado por inteligência artificial'), findsOneWidget);
  });

  testWidgets('na visão pública o resumo vem sozinho e sem modo comerciante',
      (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({'resumo': 'Comida boa e fila curta.', 'totalAvaliacoes': 4}));

    await _abrir(tester, api, modoComerciante: false, automatico: true);

    expect(find.text('Resumo com IA'), findsOneWidget);
    expect(api.doMetodo('GET').single.queryParameters['modo'], 'publico');
    expect(find.text('Comida boa e fila curta.'), findsOneWidget);
  });

  testWidgets('falha da IA oferece tentar de novo, sem derrubar a tela',
      (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 500, '{"message":"boom"}');

    await _abrir(tester, api);
    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível gerar agora'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('resumo sem alerta não desenha aviso nenhum', (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({
          'resumo': 'Nenhum padrão preocupante.',
          'totalAvaliacoes': 6,
          'alertas': [],
        }));

    await _abrir(tester, api);
    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum padrão preocupante.'), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsNothing);
  });

  testWidgets('depois de gerar, o comerciante pode gerar de novo', (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({'resumo': 'Primeiro resumo.', 'totalAvaliacoes': 5}));

    await _abrir(tester, api);
    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    expect(find.text('Gerar de novo'), findsOneWidget);

    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({'resumo': 'Resumo atualizado.', 'totalAvaliacoes': 6}));

    await tester.tap(find.text('Gerar de novo'));
    await tester.pumpAndSettle();

    expect(api.doMetodo('GET'), hasLength(2));
    expect(find.text('Resumo atualizado.'), findsOneWidget);
    expect(find.text('Primeiro resumo.'), findsNothing);
  });

  testWidgets('comentários que chegam depois do resumo são avisados', (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({'resumo': 'Resumo de agora há pouco.', 'totalAvaliacoes': 5}));
    final servico = _servicoCom(api);

    await tester.pumpWidget(_cartao(servico, comentarios: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    expect(find.textContaining('depois deste resumo'), findsNothing);

    await tester.pumpWidget(_cartao(servico, comentarios: 7));
    await tester.pumpAndSettle();

    expect(find.text('Resumo de agora há pouco.'), findsOneWidget,
        reason: 'o resumo continua na tela, só ganha o aviso');
    expect(find.text('Chegaram 2 comentários novos depois deste resumo'), findsOneWidget);
  });

  testWidgets('comentário descartado pela moderação não vira aviso falso de novidade',
      (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({'resumo': 'Resumo sem o comentário ofensivo.', 'totalAvaliacoes': 9}));

    await _abrir(tester, api, comentarios: 10);
    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    expect(find.text('Resumo sem o comentário ofensivo.'), findsOneWidget);
    expect(find.textContaining('depois deste resumo'), findsNothing);
    expect(find.textContaining('a partir de 9 comentários'), findsOneWidget);
  });

  testWidgets('servidor sem comentários suficientes não vira texto de IA', (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({
          'resumo': 'Ainda não há avaliações com comentários suficientes para gerar insights.',
          'totalAvaliacoes': 2,
          'alertas': [],
        }));

    await _abrir(tester, api, comentarios: 3);
    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    expect(find.textContaining('comentários suficientes'), findsOneWidget);
    expect(find.textContaining('gerado por inteligência artificial'), findsNothing);
    expect(find.text('Gerar de novo'), findsNothing);
    expect(find.textContaining('depois deste resumo'), findsNothing);
  });

  testWidgets('resumo em dia não avisa de comentário novo', (tester) async {
    api.responder('GET', '/avaliacoes/loja/7/resumo', 200,
        jsonEncode({'resumo': 'Resumo em dia.', 'totalAvaliacoes': 5}));

    await _abrir(tester, api, comentarios: 5);
    await tester.tap(find.text('Gerar insights'));
    await tester.pumpAndSettle();

    expect(find.textContaining('comentário'), findsOneWidget,
        reason: 'só a linha do rodapé, sem aviso de novidade');
    expect(find.textContaining('depois deste resumo'), findsNothing);
  });
}
