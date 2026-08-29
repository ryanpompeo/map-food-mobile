import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/core/ui/widgets/menu_list_tile.dart';
import 'package:map_food/features/auth/presentation/widgets/account_type_card.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_switcher_bar.dart';
import 'package:map_food/features/search/presentation/widgets/category_filters.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/review_card.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/section_header.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/store_detail_overview.dart';

/// Rede de segurança do Dynamic Type.
///
/// Um `RenderFlex overflowed` não derruba o app: em produção ele vira uma
/// faixa listrada (ou nada, em release) e o texto simplesmente some. Ou seja,
/// é o tipo de defeito que passa despercebido em revisão e só aparece no
/// aparelho de alguém que aumentou a fonte — normalmente a pessoa que mais
/// precisava do app funcionando.
///
/// ## Duas ferramentas, porque uma não basta
///
/// Foi medido, e o resultado decidiu o desenho deste arquivo:
///
/// | Situação                                    | `takeException()` |
/// |---------------------------------------------|-------------------|
/// | `Row` estourando na horizontal              | detecta           |
/// | `Column` estourando na vertical             | detecta           |
/// | texto cortado por `SizedBox(height:` fixo   | **não detecta**   |
///
/// A terceira linha é justamente a amarra que este lote está removendo: ela
/// não lança nada, o texto só é **clipado em silêncio**. Confiar apenas na
/// exceção daria um teste verde enquanto o rótulo do botão continuasse cortado
/// pela metade.
///
/// Por isso cada componente tem os dois tipos de asserção:
///
/// 1. **`takeException()`** — pega o overflow de `Row`/`Column`;
/// 2. **altura em 1× < altura em 2×** — pega a amarra silenciosa. Se alguém
///    reintroduzir `height:` fixo, esta é a asserção que quebra.
///
/// **Como estender:** ao migrar uma tela, acrescente um caso aqui — e inclua
/// a comparação de altura, não só a checagem de exceção.
void main() {
  /// Monta [child] com o tema real do app e a escala de texto pedida.
  ///
  /// Largura estreita de propósito (360dp, um celular pequeno): o overflow
  /// horizontal aparece primeiro em tela estreita, e é justamente a
  /// combinação "tela pequena + fonte grande" que quebra na vida real.
  /// [rolavel] reproduz o ambiente real destes componentes: todos vivem dentro
  /// de uma lista ou de um `SingleChildScrollView`. Isso importa por dois
  /// motivos — dá ao filho altura irrestrita, que é o que permite **medir** o
  /// tamanho natural dele (numa tela fixa ele é esticado e toda medida vira a
  /// altura da tela), e evita acusar de "overflow" um bloco que na tela real
  /// simplesmente rolaria.
  Widget montar(
    Widget child, {
    required double escala,
    double largura = 360,
    bool rolavel = false,
  }) {
    final conteudo = SizedBox(width: largura, child: child);
    return MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(escala)),
        child: Scaffold(
          body: rolavel
              ? SingleChildScrollView(child: conteudo)
              : Center(child: conteudo),
        ),
      ),
    );
  }

  // 2.0 é o teto do Android; o iOS vai além com as "Larger Accessibility
  // Sizes", por isso o 3.0 entra na checagem de crescimento.
  const escalas = [1.0, 1.5, 2.0];

  /// Mede a altura de [finder] com [child] montado na escala [escala].
  Future<double> alturaEm(
    WidgetTester tester,
    Widget child,
    Finder finder,
    double escala,
  ) async {
    await tester.pumpWidget(montar(child, escala: escala, rolavel: true));
    return tester.getSize(finder).height;
  }

  /// O portão contra a amarra silenciosa: um componente que contém texto
  /// **precisa** ficar mais alto quando a fonte do sistema cresce. Se não
  /// ficar, alguma altura fixa voltou a travar a caixa e o texto está sendo
  /// cortado sem lançar exceção nenhuma.
  void testaQueCresce(String nome, Widget Function() build, Finder finder) {
    testWidgets('$nome cresce com a fonte do sistema', (tester) async {
      final base = await alturaEm(tester, build(), finder, 1.0);
      final grande = await alturaEm(tester, build(), finder, 2.0);
      final gigante = await alturaEm(tester, build(), finder, 3.0);

      expect(grande, greaterThan(base), reason: '$nome não cresceu de 1x para 2x');
      expect(gigante, greaterThan(grande), reason: '$nome parou de crescer em 3x');
    });
  }

  group('AppButton', () {
    for (final escala in escalas) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(
          const AppButton(label: 'Salvar alterações', onPressed: _noop),
          escala: escala,
        ));
        expect(tester.takeException(), isNull);
      });
    }

    // O ponto do lote inteiro: com `height` fixo, as alturas seriam idênticas
    // em toda escala e o rótulo estaria sendo cortado em silêncio.
    testaQueCresce(
      'AppButton',
      () => const AppButton(label: 'Salvar alterações', onPressed: _noop),
      find.byType(AppButton),
    );

    testWidgets('nunca fica abaixo do alvo mínimo de toque', (tester) async {
      await tester.pumpWidget(montar(
        const AppButton(label: 'Ok', onPressed: _noop, size: AppButtonSize.sm),
        escala: 1.0,
      ));
      expect(tester.getSize(find.byType(AppButton)).height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('com ícone e rótulo longo não estoura em 2x', (tester) async {
      await tester.pumpWidget(montar(
        const AppButton(
          label: 'Visualizar no mapa',
          icon: AppIcons.mapTrifold,
          onPressed: _noop,
        ),
        escala: 2.0,
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('em carga não estoura em 2x', (tester) async {
      await tester.pumpWidget(montar(
        const AppButton(label: 'Salvando', onPressed: _noop, loading: true),
        escala: 2.0,
      ));
      expect(tester.takeException(), isNull);
    });
  });

  group('MenuListTile', () {
    for (final escala in escalas) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(
          const MenuListTile(
            icon: AppIcons.userGear,
            title: 'Editar Perfil',
            subtitle: 'Altere seus dados e senha',
            onTap: _noop,
          ),
          escala: escala,
        ));
        expect(tester.takeException(), isNull);
      });
    }

    testaQueCresce(
      'MenuListTile',
      () => const MenuListTile(
        icon: AppIcons.userGear,
        title: 'Editar Perfil',
        subtitle: 'Altere seus dados e senha',
        onTap: _noop,
      ),
      find.byType(MenuListTile),
    );
  });

  group('EmptyState', () {
    for (final escala in escalas) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(
          const EmptyState(
            icon: AppIcons.heart,
            title: 'Nenhum favorito ainda',
            description: 'Toque no coração de um comércio para salvá-lo aqui.',
            actionLabel: 'Explorar comércios',
            onAction: _noop,
          ),
          escala: escala,
        ));
        expect(tester.takeException(), isNull);
      });
    }

    testaQueCresce(
      'EmptyState',
      () => const EmptyState(
        icon: AppIcons.heart,
        title: 'Nenhum favorito ainda',
        description: 'Toque no coração de um comércio para salvá-lo aqui.',
        actionLabel: 'Explorar comércios',
        onAction: _noop,
      ),
      find.byType(EmptyState),
    );
  });

  group('AppChoiceChip', () {
    for (final escala in escalas) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(
          const Row(
            children: [
              AppChoiceChip(label: 'Semana', selected: true, onTap: _noop),
              SizedBox(width: 8),
              AppChoiceChip(label: 'Mês', selected: false, onTap: _noop),
            ],
          ),
          escala: escala,
        ));
        expect(tester.takeException(), isNull);
      });
    }

    testaQueCresce(
      'AppChoiceChip',
      () => const AppChoiceChip(label: 'Semana', selected: true, onTap: _noop),
      find.byType(AppChoiceChip),
    );

    testWidgets('o ✓ do estado selecionado continua presente em 2x', (tester) async {
      await tester.pumpWidget(montar(
        const AppChoiceChip(label: 'Semana', selected: true, onTap: _noop),
        escala: 2.0,
      ));
      // Se o chip apertasse o conteúdo, o ícone seria a primeira coisa a sair
      // — e com ele o único sinal não-cromático de seleção.
      expect(find.byIcon(AppIcons.check), findsOneWidget);
    });
  });

  group('AccountTypeCard', () {
    AccountTypeCard build() => const AccountTypeCard(
          icon: AppIcons.user,
          eyebrow: 'Perfil comum',
          title: 'Quero encontrar comércios',
          description: 'Descubra vendedores perto de você e salve favoritos.',
          benefits: ['Mapa em tempo real', 'Favoritos', 'Avaliações'],
          ctaLabel: 'Criar conta de consumidor',
          onTap: _noop,
        );

    for (final escala in escalas) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(build(), escala: escala, rolavel: true));
        expect(tester.takeException(), isNull);
      });
    }

    testaQueCresce('AccountTypeCard', build, find.byType(AccountTypeCard));
  });

  // ─────────────────── tela de detalhe da loja ───────────────────
  // Estes três nasceram de um defeito real: os cabeçalhos e o card de
  // avaliação da tela de detalhe estouravam a linha **em escala 1x**, num
  // celular comum. A causa era sempre a mesma — um `Row` com o texto sem
  // `Expanded`, ocupando a largura que quisesse e empurrando o resto para
  // fora. A largura reduzida usada abaixo não é hipotética: é a que sobra
  // dentro do card de avaliações, depois de dois paddings de cada lado.

  /// Largura útil dentro do card "Suas avaliações", numa tela de 360dp:
  /// 360 − 2×20 (margem da tela) − 2×16 (padding do card).
  const larguraDentroDoCard = 288.0;

  group('SectionHeader', () {
    SectionHeader build() => const SectionHeader(
          title: 'Suas avaliações',
          subtitle: '3 enviadas para este comércio',
          expanded: true,
          onToggle: _noop,
        );

    for (final escala in [1.0, 1.5, 2.0, 3.0]) {
      testWidgets('não estoura dentro de um card em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(
          build(),
          escala: escala,
          largura: larguraDentroDoCard,
          rolavel: true,
        ));
        expect(tester.takeException(), isNull);
      });
    }

    testaQueCresce('SectionHeader', build, find.byType(SectionHeader));

    testWidgets('título longo encurta em vez de empurrar o caret para fora', (tester) async {
      await tester.pumpWidget(montar(
        const SectionHeader(
          title: 'Um título absurdamente comprido que jamais caberia nesta linha',
          expanded: false,
          onToggle: _noop,
        ),
        escala: 1.0,
        largura: larguraDentroDoCard,
        rolavel: true,
      ));
      expect(tester.takeException(), isNull);
      // O caret é o que sumia primeiro: sem ele, um bloco recolhível deixa de
      // anunciar que dá para expandi-lo.
      expect(find.byIcon(AppIcons.caretDown), findsOneWidget);
    });
  });

  group('ReviewCard', () {
    // Nome longo + data é exatamente o par que estourava na versão anterior.
    const avaliacao = AvaliacaoModel(
      id: 1,
      nota: 4,
      comentario: 'Atendimento ótimo e o espetinho estava muito bem temperado.',
      consumidor: ConsumidorResumido(id: 9, nome: 'Maria Aparecida de Souza Nascimento'),
    );

    for (final escala in [1.0, 1.5, 2.0, 3.0]) {
      testWidgets('não estoura com nome longo em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(
          const ReviewCard(review: avaliacao),
          escala: escala,
          largura: larguraDentroDoCard,
          rolavel: true,
        ));
        expect(tester.takeException(), isNull);
      });

      testWidgets('compacto não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(
          const ReviewCard(review: avaliacao, compact: true),
          escala: escala,
          largura: larguraDentroDoCard,
          rolavel: true,
        ));
        expect(tester.takeException(), isNull);
      });
    }

    testaQueCresce(
      'ReviewCard',
      () => const ReviewCard(review: avaliacao),
      find.byType(ReviewCard),
    );

    testWidgets('a versão compacta omite o autor', (tester) async {
      await tester.pumpWidget(montar(
        const ReviewCard(review: avaliacao, compact: true),
        escala: 1.0,
        largura: larguraDentroDoCard,
        rolavel: true,
      ));
      // No histórico do próprio usuário o nome é sempre o dele, e repeti-lo
      // consumia justamente a largura que faltava.
      expect(find.text('Maria Aparecida de Souza Nascimento'), findsNothing);
    });
  });

  group('StoreStatsRow', () {
    StoreStatsRow build() => const StoreStatsRow(
          store: StoreDto(
            id: 1,
            nome: 'Espetinho do Zé',
            statusLoja: 'ATIVA',
            categoria: 'Espetinhos',
            totalAvaliacoes: 128,
            galeria: ['a.jpg', 'b.jpg'],
          ),
          media: 4.8,
        );

    for (final escala in escalas) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(build(), escala: escala, rolavel: true));
        expect(tester.takeException(), isNull);
      });
    }

    testaQueCresce('StoreStatsRow', build, find.byType(StoreStatsRow));
  });

  // ─────────────────────── superfícies com teto ───────────────────────
  // As faixas horizontais não crescem sem limite de propósito (ver
  // `MaxTextScale`). O que precisa ser garantido aqui é o **oposto** dos
  // grupos acima: que elas cresçam um pouco e depois PAREM. Sem esta
  // asserção, alguém "consertando" o teto deixaria a faixa comer a tela.

  group('CategoryFiltersWidget (faixa com teto)', () {
    // Sem "Todos" na lista: o filtro que limpa o recorte deixou de ser um item
    // da tira — ver `CategoryFiltersWidget`, onde "ver tudo" é o estado sem
    // nenhuma categoria marcada.
    CategoryFiltersWidget build() => CategoryFiltersWidget(
          filtros: const ['Lanches', 'Açaí', 'Bebidas'],
          selecionada: 'Lanches',
          onFilterChanged: (_) {},
        );

    for (final escala in [1.0, 1.5, 2.0, 3.0]) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(build(), escala: escala));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('cresce até o teto e para', (tester) async {
      final base = await alturaEm(tester, build(), find.byType(CategoryFiltersWidget), 1.0);
      final noTeto = await alturaEm(tester, build(), find.byType(CategoryFiltersWidget), 1.5);
      final acimaDoTeto = await alturaEm(tester, build(), find.byType(CategoryFiltersWidget), 3.0);

      expect(noTeto, greaterThan(base), reason: 'a faixa precisa acompanhar até o teto');
      expect(acimaDoTeto, equals(noTeto), reason: 'acima do teto a faixa não pode continuar crescendo');
    });
  });

  group('StoreSwitcherBar (faixa com teto)', () {
    StoreSwitcherBar build() => StoreSwitcherBar(
          stores: const [
            StoreDto(id: 1, nome: 'Espetinho do Zé', statusLoja: 'ATIVA', categoria: 'Lanches'),
            StoreDto(id: 2, nome: 'Açaí da Praça', statusLoja: 'INATIVA', categoria: 'Açaí'),
          ],
          selectedIndex: 0,
          onSelect: (_) {},
        );

    for (final escala in [1.0, 1.5, 2.0, 3.0]) {
      testWidgets('não estoura em ${escala}x', (tester) async {
        await tester.pumpWidget(montar(build(), escala: escala));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('cresce até o teto e para', (tester) async {
      final base = await alturaEm(tester, build(), find.byType(StoreSwitcherBar), 1.0);
      final noTeto = await alturaEm(tester, build(), find.byType(StoreSwitcherBar), 1.5);
      final acimaDoTeto = await alturaEm(tester, build(), find.byType(StoreSwitcherBar), 3.0);

      expect(noTeto, greaterThan(base));
      expect(acimaDoTeto, equals(noTeto));
    });
  });

  group('utilitários de escala', () {
    testWidgets('escalaComTeto respeita o limite', (tester) async {
      late double semTeto;
      late double comTeto;

      await tester.pumpWidget(montar(
        Builder(builder: (context) {
          semTeto = escalaComTeto(context, 100, teto: 10);
          comTeto = escalaComTeto(context, 100, teto: 1.5);
          return const SizedBox.shrink();
        }),
        escala: 3.0,
      ));

      expect(semTeto, 300.0, reason: 'sem teto efetivo, acompanha a escala inteira');
      expect(comTeto, 150.0, reason: 'com teto, para em base * teto');
    });

    testWidgets('linhasParaRotulo solta a segunda linha só em escala alta', (tester) async {
      late int normal;
      late int grande;

      await tester.pumpWidget(montar(
        Builder(builder: (context) {
          normal = linhasParaRotulo(context);
          return const SizedBox.shrink();
        }),
        escala: 1.0,
      ));
      await tester.pumpWidget(montar(
        Builder(builder: (context) {
          grande = linhasParaRotulo(context);
          return const SizedBox.shrink();
        }),
        escala: 2.0,
      ));

      expect(normal, 1);
      expect(grande, 2);
    });
  });
}

void _noop() {}
