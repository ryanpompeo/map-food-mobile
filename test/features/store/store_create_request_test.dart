import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

const _loja = StoreDto(
  id: 42,
  nome: 'Carrinho do João',
  descricao: 'Lanches na hora',
  statusLoja: 'INATIVA',
  categoria: 'Lanches',
  categoriaIds: [3, 5],
  endereco: 'Rua das Flores, 123',
  cidade: 'Campinas',
  estado: 'SP',
  cep: '13000-000',
  latitude: -22.9,
  longitude: -47.06,
);

void main() {
  group('fromStore sem overrides', () {
    test('reproduz o cadastro inteiro da loja', () {
      final json = StoreCreateRequest.fromStore(_loja).toJson();

      expect(json['nome'], 'Carrinho do João');
      expect(json['descricao'], 'Lanches na hora');
      expect(json['statusLoja'], 'INATIVA');
      expect(json['categorias'], [
        {'id': 3},
        {'id': 5},
      ]);
      expect(json['endereco'], 'Rua das Flores, 123');
      expect(json['cidade'], 'Campinas');
      expect(json['estado'], 'SP');
      expect(json['cep'], '13000-000');
      expect(json['latitude'], -22.9);
      expect(json['longitude'], -47.06);
    });
  });

  group('atualização de posição (ronda de GPS)', () {
    test('troca só as coordenadas e PRESERVA o endereço', () {
      final json = StoreCreateRequest.fromStore(
        _loja,
        latitude: -23.0,
        longitude: -47.1,
      ).toJson();

      expect(json['latitude'], -23.0);
      expect(json['longitude'], -47.1);
      expect(json['endereco'], 'Rua das Flores, 123');
      expect(json['cidade'], 'Campinas');
      expect(json['estado'], 'SP');
      expect(json['cep'], '13000-000');
      expect(json['statusLoja'], 'INATIVA');
    });
  });

  group('troca de status', () {
    test('abrir a loja preserva o resto do cadastro', () {
      final json = StoreCreateRequest.fromStore(_loja, statusLoja: 'ATIVA').toJson();

      expect(json['statusLoja'], 'ATIVA');
      expect(json['nome'], 'Carrinho do João');
      expect(json['categorias'], hasLength(2));
      expect(json['latitude'], -22.9);
    });

    test('abrir com posição nova aplica status e coordenadas juntos', () {
      final json = StoreCreateRequest.fromStore(
        _loja,
        statusLoja: 'ATIVA',
        latitude: -23.5,
        longitude: -46.6,
      ).toJson();

      expect(json['statusLoja'], 'ATIVA');
      expect(json['latitude'], -23.5);
      expect(json['longitude'], -46.6);
    });
  });

  group('campos ausentes', () {
    test('loja sem endereço não envia as chaves vazias', () {
      const semEndereco = StoreDto(
        id: 1,
        nome: 'Sem endereço',
        statusLoja: 'INATIVA',
        categoria: '',
      );

      final json = StoreCreateRequest.fromStore(semEndereco).toJson();

      expect(json.containsKey('endereco'), isFalse);
      expect(json.containsKey('latitude'), isFalse);
      expect(json['categorias'], isEmpty);
    });
  });
}
