import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/search/data/store_search.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

StoreDto _loja(
  int id,
  String nome, {
  List<String> categorias = const [],
  String? cidade,
  String? descricao,
  bool destaque = false,
}) =>
    StoreDto(
      id: id,
      nome: nome,
      statusLoja: 'ATIVA',
      categoria: categorias.isEmpty ? '' : categorias.first,
      categoriaNomes: categorias,
      cidade: cidade,
      descricao: descricao,
      tipoLoja: destaque ? 'DESTAQUE' : 'GRATUITO',
    );

void main() {
  group('normalizarTexto', () {
    test('remove acento e caixa', () {
      expect(normalizarTexto('Açaí da Praça'), 'acai da praca');
      expect(normalizarTexto('PÃO & Cia'), 'pao & cia');
    });

    test('texto sem acento passa intacto', () {
      expect(normalizarTexto('Padaria'), 'padaria');
    });
  });

  group('buscarLojas', () {
    test('termo vazio devolve a lista inteira', () {
      final lojas = [_loja(1, 'Padaria'), _loja(2, 'Açaí')];
      expect(buscarLojas(lojas, '   '), lojas);
    });

    test('acha loja acentuada com termo sem acento', () {
      final lojas = [_loja(1, 'Açaí da Praça'), _loja(2, 'Padaria')];

      final resultado = buscarLojas(lojas, 'acai');

      expect(resultado.map((l) => l.id), [1]);
    });

    test('acha por categoria, não só por nome', () {
      final lojas = [
        _loja(1, 'Dona Maria', categorias: ['Salgados']),
        _loja(2, 'Bar do Zé', categorias: ['Bebidas']),
      ];

      expect(buscarLojas(lojas, 'salgado').map((l) => l.id), [1]);
    });

    test('acha por cidade e por descrição', () {
      final lojas = [
        _loja(1, 'Tenda A', cidade: 'Campinas'),
        _loja(2, 'Tenda B', descricao: 'Especialista em coxinha frita'),
      ];

      expect(buscarLojas(lojas, 'campinas').map((l) => l.id), [1]);
      expect(buscarLojas(lojas, 'coxinha').map((l) => l.id), [2]);
    });

    test('tolera um dedo errado em termo longo', () {
      final lojas = [_loja(1, 'Padaria Central'), _loja(2, 'Sorveteria')];

      expect(buscarLojas(lojas, 'padria').map((l) => l.id), [1]);
    });

    test('não faz aproximação em termo curto', () {
      final lojas = [_loja(1, 'Mar Azul'), _loja(2, 'Lar Doce Lar')];

      expect(buscarLojas(lojas, 'bar'), isEmpty);
    });

    test('ordena por relevância: começo do nome antes de descrição', () {
      final lojas = [
        _loja(1, 'Tenda do Zé', descricao: 'a melhor pizza da região'),
        _loja(2, 'Pizza Boa'),
        _loja(3, 'Forno de Pizza'),
      ];

      expect(buscarLojas(lojas, 'pizza').map((l) => l.id), [2, 3, 1]);
    });

    test('acerto exato vence acerto aproximado', () {
      final lojas = [_loja(1, 'Padria Torta'), _loja(2, 'Padaria Real')];

      expect(buscarLojas(lojas, 'padaria').map((l) => l.id), [2, 1]);
    });

    test('mantém a ordem original entre lojas de mesma relevância', () {
      final lojas = [
        _loja(10, 'Pastel A'),
        _loja(20, 'Pastel B'),
        _loja(30, 'Pastel C'),
      ];

      expect(buscarLojas(lojas, 'pastel').map((l) => l.id), [10, 20, 30]);
    });

    test('sem acerto nenhum devolve lista vazia', () {
      final lojas = [_loja(1, 'Padaria'), _loja(2, 'Açaí')];

      expect(buscarLojas(lojas, 'sushi'), isEmpty);
    });
  });

  group('plano Destaque na busca', () {
    test('sem termo, as lojas em destaque vêm primeiro', () {
      final lojas = [
        _loja(1, 'Padaria'),
        _loja(2, 'Espetinho', destaque: true),
        _loja(3, 'Açaí'),
        _loja(4, 'Tapioca', destaque: true),
      ];

      expect(buscarLojas(lojas, '').map((l) => l.id), [2, 4, 1, 3]);
    });

    test('a relevância ganha do plano: quem casa pelo nome vem antes', () {
      final lojas = [
        _loja(1, 'Açaí da Praça', descricao: 'o melhor açaí', destaque: true),
        _loja(2, 'Tapioca da Ana', descricao: 'também temos açaí'),
      ];

      final porNome = buscarLojas([lojas[1], lojas[0]], 'tapioca');

      expect(porNome.first.id, 2,
          reason: 'plano não compra o primeiro lugar de quem o cliente procurou');
    });

    test('empate de relevância é desempatado pelo plano', () {
      final lojas = [
        _loja(1, 'Açaí do Centro'),
        _loja(2, 'Açaí da Praça', destaque: true),
      ];

      expect(buscarLojas(lojas, 'acai').map((l) => l.id), [2, 1]);
    });

    test('sem nenhuma loja em destaque, a ordem original se mantém', () {
      final lojas = [_loja(1, 'Padaria'), _loja(2, 'Açaí'), _loja(3, 'Tapioca')];

      expect(buscarLojas(lojas, '').map((l) => l.id), [1, 2, 3]);
    });
  });

  group('filtro e vitrine de destaques', () {
    test('o filtro deixa só as lojas do plano', () {
      final lojas = [
        _loja(1, 'Padaria'),
        _loja(2, 'Espetinho', destaque: true),
        _loja(3, 'Açaí', destaque: true),
      ];

      expect(somenteEmDestaque(lojas).map((l) => l.id), [2, 3]);
    });

    test('sem nenhuma loja do plano, o filtro não tem o que mostrar', () {
      final lojas = [_loja(1, 'Padaria'), _loja(2, 'Açaí')];

      expect(somenteEmDestaque(lojas), isEmpty);
      expect(existeLojaEmDestaque(lojas), isFalse);
    });

    test('a vitrine respeita o limite de itens da seção', () {
      final lojas = [
        for (var i = 1; i <= 8; i++) _loja(i, 'Loja $i', destaque: true),
      ];

      expect(vitrineDeDestaques(lojas, limite: 5), hasLength(5));
      expect(vitrineDeDestaques(lojas, limite: 5).first.id, 1);
    });

    test('vitrine vazia quando ninguém assinou: a seção não aparece', () {
      final lojas = [_loja(1, 'Padaria'), _loja(2, 'Açaí')];

      expect(vitrineDeDestaques(lojas), isEmpty);
    });
  });
}
