import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/search/data/store_search.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

StoreDto _loja(
  int id,
  String nome, {
  List<String> categorias = const [],
  String? cidade,
  String? descricao,
}) =>
    StoreDto(
      id: id,
      nome: nome,
      statusLoja: 'ATIVA',
      categoria: categorias.isEmpty ? '' : categorias.first,
      categoriaNomes: categorias,
      cidade: cidade,
      descricao: descricao,
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
      // O caso que motivou tudo: teclado de celular, ninguém digita "Açaí".
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
      // Com distância 1 sobre 3 letras, "bar" acharia "mar", "lar" e "par":
      // devolver qualquer coisa é pior do que não devolver nada.
      final lojas = [_loja(1, 'Mar Azul'), _loja(2, 'Lar Doce Lar')];

      expect(buscarLojas(lojas, 'bar'), isEmpty);
    });

    test('ordena por relevância: começo do nome antes de descrição', () {
      final lojas = [
        _loja(1, 'Tenda do Zé', descricao: 'a melhor pizza da região'),
        _loja(2, 'Pizza Boa'),
        _loja(3, 'Forno de Pizza'),
      ];

      // 2 começa com o termo; 3 tem uma palavra que começa com ele;
      // 1 só menciona na descrição.
      expect(buscarLojas(lojas, 'pizza').map((l) => l.id), [2, 3, 1]);
    });

    test('acerto exato vence acerto aproximado', () {
      final lojas = [_loja(1, 'Padria Torta'), _loja(2, 'Padaria Real')];

      expect(buscarLojas(lojas, 'padaria').map((l) => l.id), [2, 1]);
    });

    test('mantém a ordem original entre lojas de mesma relevância', () {
      // `List.sort` do Dart não é estável: sem o desempate por posição, a lista
      // trocaria de ordem a cada tecla digitada.
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
}
