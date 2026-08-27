import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/nearby_filter.dart';

/// Coordenadas reais de Limeira-SP (a cidade do app) pra distâncias que dá
/// pra conferir num mapa, em vez de números inventados.
const _usuario = (lat: -22.5645, lng: -47.4017);

StoreDto _loja(int id, {double? lat, double? lng}) => StoreDto(
      id: id,
      nome: 'Loja $id',
      statusLoja: 'ATIVA',
      categoria: 'Lanches',
      latitude: lat,
      longitude: lng,
    );

/// ~300 m ao norte do usuário (1 grau de latitude ≈ 111 km).
final _muitoPerto = _loja(1, lat: _usuario.lat + 0.0027, lng: _usuario.lng);

/// ~3,3 km ao norte.
final _perto = _loja(2, lat: _usuario.lat + 0.03, lng: _usuario.lng);

/// ~11 km ao norte.
final _longe = _loja(3, lat: _usuario.lat + 0.10, lng: _usuario.lng);

/// Loja cadastrada sem CEP/endereço geocodificado.
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
      // Não dá pra afirmar que ela está dentro de 5 km sem saber onde fica —
      // e ela também não teria pin no mapa.
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

      // O corte não ordena por distância — quem ordena por proximidade é a
      // seção "Perto de você" da busca, não o mapa.
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
      // Este é o comportamento que mais confunde: GPS negado ou ainda sem fix,
      // o chip "1 km" fica marcado no modal e a loja a 11 km continua no mapa.
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
