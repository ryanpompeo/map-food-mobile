import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/json_reader.dart';

void main() {
  group('requireInt', () {
    test('lê número', () {
      expect({'id': 7}.requireInt('id'), 7);
    });

    test('lê número decimal truncando', () {
      expect({'id': 7.9}.requireInt('id'), 7);
    });

    test('lê string numérica', () {
      expect({'id': '7'}.requireInt('id'), 7);
    });

    test('campo ausente vira ParseException com o nome do campo', () {
      expect(
        () => <String, dynamic>{}.requireInt('id'),
        throwsA(isA<ParseException>().having((e) => e.message, 'message', contains('id'))),
      );
    });

    test('campo null vira ParseException, não TypeError', () {
      expect(
        () => <String, dynamic>{'id': null}.requireInt('id'),
        throwsA(isA<ParseException>()),
      );
    });

    test('tipo incompatível vira ParseException', () {
      expect(
        () => <String, dynamic>{'id': 'abc'}.requireInt('id'),
        throwsA(isA<ParseException>()),
      );
    });

    test('ParseException é AppException — o app inteiro já sabe tratá-la', () {
      expect(
        () => <String, dynamic>{}.requireInt('id'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('requireString', () {
    test('lê texto', () {
      expect({'nome': 'Padaria'}.requireString('nome'), 'Padaria');
    });

    test('converte número para texto', () {
      expect({'nome': 42}.requireString('nome'), '42');
    });

    test('string vazia é tratada como ausente', () {
      expect(
        () => <String, dynamic>{'nome': ''}.requireString('nome'),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('campos opcionais', () {
    test('optDouble aceita num, string e devolve null no resto', () {
      expect({'lat': -22.9}.optDouble('lat'), -22.9);
      expect({'lat': -22}.optDouble('lat'), -22.0);
      expect({'lat': '-22.9'}.optDouble('lat'), -22.9);
      expect({'lat': 'x'}.optDouble('lat'), isNull);
      expect(<String, dynamic>{}.optDouble('lat'), isNull);
      expect({'lat': null}.optDouble('lat'), isNull);
    });

    test('optString trata string vazia como ausente', () {
      expect({'descricao': 'oi'}.optString('descricao'), 'oi');
      expect({'descricao': ''}.optString('descricao'), isNull);
      expect({'descricao': null}.optString('descricao'), isNull);
    });

    test('stringOr aplica o padrão quando o campo falta', () {
      expect(<String, dynamic>{}.stringOr('statusLoja', 'INATIVA'), 'INATIVA');
      expect({'statusLoja': 'ATIVA'}.stringOr('statusLoja', 'INATIVA'), 'ATIVA');
    });

    test('optList devolve lista vazia quando o campo não é lista', () {
      expect({'galeria': ['a']}.optList('galeria'), ['a']);
      expect({'galeria': 'nao-e-lista'}.optList('galeria'), isEmpty);
      expect(<String, dynamic>{}.optList('galeria'), isEmpty);
    });

    test('optStringList descarta entradas vazias e nulas', () {
      expect(
        {'galeria': ['/a.jpg', '', null, '/b.jpg']}.optStringList('galeria'),
        ['/a.jpg', '/b.jpg'],
      );
    });
  });
}
