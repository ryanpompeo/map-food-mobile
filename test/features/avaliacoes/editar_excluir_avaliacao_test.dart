import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/avaliacoes/presentation/controllers/acoes_da_avaliacao.dart';
import 'package:map_food/features/avaliacoes/presentation/widgets/folha_editar_avaliacao.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/review_card.dart';

import '../../support/api_falsa.dart';

AvaliacaoModel _minha() => AvaliacaoModel(
      id: 42,
      nota: 3,
      comentario: 'Estava morno',
      lojaId: 7,
      lojaNome: 'Espetinho do Zé',
    );

AvaliacaoService _servicoCom(ApiFalsa api) => AvaliacaoService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = api
          ..interceptors.add(ErrorInterceptor()),
      ),
    );

void main() {
  late ApiFalsa api;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    api = ApiFalsa();
  });

  group('serviço', () {
    test('editar manda nota e comentário para a própria avaliação', () async {
      api.responder('PUT', '/avaliacoes/42', 200, '{"id":42,"nota":5}');

      await _servicoCom(api).editarAvaliacao(id: 42, nota: 5, comentario: '  melhorou  ');

      final chamada = api.doMetodo('PUT').single;
      expect(chamada.path, '/avaliacoes/42');
      expect(chamada.data, {'nota': 5, 'comentario': 'melhorou'});
    });

    test('comentário em branco vira nulo, não string vazia', () async {
      api.responder('PUT', '/avaliacoes/42', 200, '{"id":42,"nota":4}');

      await _servicoCom(api).editarAvaliacao(id: 42, nota: 4, comentario: '   ');

      expect(api.doMetodo('PUT').single.data, {'nota': 4, 'comentario': null});
    });

    test('excluir chama o endereço da avaliação', () async {
      api.responder('DELETE', '/avaliacoes/42', 204);

      await _servicoCom(api).excluirAvaliacao(42);

      expect(api.doMetodo('DELETE').single.path, '/avaliacoes/42');
    });
  });

  group('folha de edição', () {
    testWidgets('abre com a nota e o comentário atuais', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: FolhaEditarAvaliacao(nota: 3, comentario: 'Estava morno'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Estava morno'), findsOneWidget);
      expect(find.text('Regular'), findsOneWidget);
    });

    testWidgets('salvar devolve a nota nova e o texto novo', (tester) async {
      AvaliacaoEditada? resultado;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  resultado = await mostrarFolhaEditarAvaliacao(
                    context,
                    nota: 3,
                    comentario: 'Estava morno',
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

      await tester.tap(find.bySemanticsLabel('5 estrelas'));
      await tester.enterText(find.byType(TextFormField), 'Voltei e melhorou');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(resultado?.nota, 5);
      expect(resultado?.comentario, 'Voltei e melhorou');
    });

    testWidgets('cancelar não devolve nada', (tester) async {
      var chamou = false;
      AvaliacaoEditada? resultado;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  resultado = await mostrarFolhaEditarAvaliacao(context, nota: 3);
                  chamou = true;
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(chamou, isTrue);
      expect(resultado, isNull);
    });
  });

  group('cartão da avaliação', () {
    testWidgets('sem as ações, não mostra menu nenhum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: ReviewCard(review: _minha())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MenuDaAvaliacao), findsNothing);
    });

    testWidgets('na própria avaliação, o menu oferece editar e excluir', (tester) async {
      var editou = false;
      var excluiu = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ReviewCard(
              review: _minha(),
              compact: true,
              onEditar: () => editou = true,
              onExcluir: () => excluiu = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MenuDaAvaliacao));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);

      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(excluiu, isTrue);
      expect(editou, isFalse);
    });
  });

  group('excluir com confirmação', () {
    Future<bool?> rodar(WidgetTester tester, ApiFalsa api) async {
      bool? resultado;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  resultado = await excluirAvaliacaoComUi(
                    context,
                    _minha(),
                    servico: _servicoCom(api),
                  );
                },
                child: const Text('excluir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('excluir'));
      await tester.pumpAndSettle();
      return resultado;
    }

    testWidgets('manter desiste sem chamar o servidor', (tester) async {
      await rodar(tester, api);

      expect(find.text('Excluir avaliação?'), findsOneWidget);
      await tester.tap(find.text('Manter'));
      await tester.pumpAndSettle();

      expect(api.doMetodo('DELETE'), isEmpty);
    });

    testWidgets('confirmar apaga e avisa', (tester) async {
      api.responder('DELETE', '/avaliacoes/42', 204);

      await rodar(tester, api);
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(api.doMetodo('DELETE').single.path, '/avaliacoes/42');
      expect(find.text('Avaliação excluída'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('erro do servidor é explicado, sem sumir em silêncio', (tester) async {
      api.responder('DELETE', '/avaliacoes/42', 403, '{"message":"Acesso negado"}');

      await rodar(tester, api);
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Erro ao excluir avaliação'), findsOneWidget);
    });
  });
}
