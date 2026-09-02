import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/nearby_filter.dart';

const _usuario = (lat: -22.5645, lng: -47.4017);

StoreDto _loja(int id, {double? lat, double? lng}) => StoreDto(
      id: id,
      nome: 'Loja $id',
      statusLoja: 'ATIVA',
      categoria: 'Lanches',
      latitude: lat,
      longitude: lng,
    );

final _muitoPerto = _loja(1, lat: _usuario.lat + 0.0027, lng: _usuario.lng);

final _perto = _loja(2, lat: _usuario.lat + 0.03, lng: _usuario.lng);

final _longe = _loja(3, lat: _usuario.lat + 0.10, lng: _usuario.lng);

final _semCoordenadas = _loja(4);

void main() {
  group('corta pelo raio', () {
    test('1 km deixa só o que está a 300 m', () {
      final resultado = lojasDentroDoRaio(
        [_muitoPerto, _perto, _longe],
        lat: _usuario.lat,
        lng: _usuario.lng,
        raioKm: 1.0,
      );

      expect(resultado.map((l) => l.id), [1]);
    });

    test('5 km alcança a de 3,3 km e para antes da de 11 km', () {
      final resultado = lojasDentroDoRaio(
        [_muitoPerto, _perto, _longe],
        lat: _usuario.lat,
        lng: _usuario.lng,
        raioKm: 5.0,
      );

      expect(resultado.map((l) => l.id), [1, 2]);
    });

    test('20 km pega todas as que têm coordenada', () {
      final resultado = lojasDentroDoRaio(
        [_muitoPerto, _perto, _longe],
        lat: _usuario.lat,
        lng: _usuario.lng,
        raioKm: 20.0,
      );

      expect(resultado.map((l) => l.id), [1, 2, 3]);
    });

    test('loja sem coordenada some quando há raio ativo', () {
      final resultado = lojasDentroDoRaio(
        [_muitoPerto, _semCoordenadas],
        lat: _usuario.lat,
        lng: _usuario.lng,
        raioKm: 5.0,
      );

      expect(resultado.map((l) => l.id), [1]);
    });

    test('preserva a ordem que veio da API', () {
      final resultado = lojasDentroDoRaio(
        [_perto, _muitoPerto],
        lat: _usuario.lat,
        lng: _usuario.lng,
        raioKm: 20.0,
      );

      expect(resultado.map((l) => l.id), [2, 1]);
    });
  });

  group('quando NÃO corta', () {
    test('raio nulo ("Todos") devolve a lista inteira, inclusive sem coordenada', () {
      final resultado = lojasDentroDoRaio(
        [_muitoPerto, _longe, _semCoordenadas],
        lat: _usuario.lat,
        lng: _usuario.lng,
        raioKm: null,
      );

      expect(resultado.map((l) => l.id), [1, 3, 4]);
    });

    test('sem posição do usuário, o raio de 1 km não filtra nada', () {
      final resultado = lojasDentroDoRaio(
        [_muitoPerto, _longe],
        lat: null,
        lng: null,
        raioKm: 1.0,
      );

      expect(resultado.map((l) => l.id), [1, 3]);
      expect(
        temPosicaoParaFiltrar(lat: null, lng: null, raioKm: 1.0),
        isFalse,
        reason: 'é este sinal que a UI pode usar pra avisar em vez de mentir',
      );
    });

    test('com raio "Todos", a falta de posição não é um problema a comunicar', () {
      expect(temPosicaoParaFiltrar(lat: null, lng: null, raioKm: null), isTrue);
    });

    test('com posição e raio, o filtro está de fato valendo', () {
      expect(
        temPosicaoParaFiltrar(lat: _usuario.lat, lng: _usuario.lng, raioKm: 1.0),
        isTrue,
      );
    });
  });
}
