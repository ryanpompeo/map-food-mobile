import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/presentation/widgets/category_picker.dart';

/// Escolher categoria é obrigatório para concluir o cadastro da loja, então
/// cada estado de falha aqui tem uma consequência concreta: se a seção some
/// silenciosamente, o comerciante fica preso num botão que nunca funciona.
/// Foi um bug real — estes testes existem para ele não voltar.
void main() {
  const categorias = [
    CategoriaModel(id: 1, nome: 'Lanches'),
    CategoriaModel(id: 2, nome: 'Doces'),
    CategoriaModel(id: 3, nome: 'Bebidas'),
    CategoriaModel(id: 4, nome: 'Salgados'),
  ];

  Widget montar(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  CategoryPicker picker({
    List<CategoriaModel> lista = categorias,
    List<int> selecionadas = const [],
    bool carregando = false,
    String? erro,
    VoidCallback? onRetry,
    ValueChanged<CategoriaModel>? onToggle,
    VoidCallback? onLimiteExcedido,
    int maxSelecao = 3,
  }) =>
      CategoryPicker(
        categorias: lista,
        selecionadas: selecionadas,
        carregando: carregando,
        erro: erro,
        onRetry: onRetry ?? () {},
        onToggle: onToggle,
        onLimiteExcedido: onLimiteExcedido,
        maxSelecao: maxSelecao,
      );

  testWidgets('carregando não mostra categoria nenhuma', (tester) async {
    await tester.pumpWidget(montar(picker(carregando: true)));

    expect(find.text('Lanches'), findsNothing);
  });

  group('falha de rede', () {
    testWidgets('mostra a mensagem e oferece tentar de novo', (tester) async {
      await tester.pumpWidget(montar(picker(erro: 'Sem conexão com o servidor.')));

      expect(find.text('Sem conexão com o servidor.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('o botão de retry chama de volta quem carrega', (tester) async {
      var tentativas = 0;
      await tester.pumpWidget(montar(picker(
        erro: 'Sem conexão.',
        onRetry: () => tentativas++,
      )));

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(tentativas, 1);
    });
  });

  testWidgets('lista vazia explica sem oferecer retry', (tester) async {
    // 200 com lista vazia não é falha: repetir a chamada devolveria o mesmo.
    await tester.pumpWidget(montar(picker(lista: const [])));

    expect(find.textContaining('Fale com o suporte'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
  });

  group('somente leitura', () {
    testWidgets('mostra apenas as categorias escolhidas', (tester) async {
      await tester.pumpWidget(montar(picker(selecionadas: const [2])));

      expect(find.text('Doces'), findsOneWidget);
      expect(find.text('Lanches'), findsNothing);
    });

    testWidgets('sem nenhuma escolhida, diz isso em vez de ficar em branco', (tester) async {
      await tester.pumpWidget(montar(picker()));

      expect(find.text('Nenhuma categoria selecionada.'), findsOneWidget);
    });
  });

  group('edição', () {
    testWidgets('mostra todas as categorias disponíveis', (tester) async {
      await tester.pumpWidget(montar(picker(onToggle: (_) {})));

      expect(find.text('Lanches'), findsOneWidget);
      expect(find.text('Salgados'), findsOneWidget);
    });

    testWidgets('tocar numa categoria devolve qual foi', (tester) async {
      CategoriaModel? escolhida;
      await tester.pumpWidget(montar(picker(onToggle: (cat) => escolhida = cat)));

      await tester.tap(find.text('Bebidas'));
      await tester.pump();

      expect(escolhida?.id, 3);
    });

    testWidgets('desmarcar uma já escolhida também passa pelo toggle', (tester) async {
      CategoriaModel? tocada;
      await tester.pumpWidget(montar(picker(
        selecionadas: const [1],
        onToggle: (cat) => tocada = cat,
      )));

      await tester.tap(find.text('Lanches'));
      await tester.pump();

      expect(tocada?.id, 1);
    });

    testWidgets('com o limite cheio, uma nova escolha avisa em vez de trocar', (tester) async {
      CategoriaModel? escolhida;
      var avisos = 0;
      await tester.pumpWidget(montar(picker(
        selecionadas: const [1, 2, 3],
        maxSelecao: 3,
        onToggle: (cat) => escolhida = cat,
        onLimiteExcedido: () => avisos++,
      )));

      await tester.tap(find.text('Salgados'));
      await tester.pump();

      expect(avisos, 1);
      expect(escolhida, isNull);
    });

    testWidgets('com o limite cheio ainda dá para desmarcar', (tester) async {
      // Sem isto a pessoa fica travada: não pode marcar nem desmarcar.
      CategoriaModel? tocada;
      var avisos = 0;
      await tester.pumpWidget(montar(picker(
        selecionadas: const [1, 2, 3],
        maxSelecao: 3,
        onToggle: (cat) => tocada = cat,
        onLimiteExcedido: () => avisos++,
      )));

      await tester.tap(find.text('Doces'));
      await tester.pump();

      expect(tocada?.id, 2);
      expect(avisos, 0);
    });
  });
}
