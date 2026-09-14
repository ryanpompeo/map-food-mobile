import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/features/store/data/map_cluster.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

StoreDto _loja(int id, double lat, double lng) => StoreDto(
      id: id,
      nome: 'Loja $id',
      statusLoja: 'ATIVA',
      categoria: 'Lanches',
      latitude: lat,
      longitude: lng,
    );

const _centro = AreaVisivel(sul: -23.1, oeste: -43.4, norte: -22.7, leste: -43.0);

void main() {
  test('lojas sem coordenada nunca entram no agrupamento', () {
    final clusters = agruparLojas([
      StoreDto(id: 1, nome: 'Sem GPS', statusLoja: 'ATIVA', categoria: 'Lanches'),
    ], zoom: 14.0);

    expect(clusters, isEmpty);
  });

  test('lojas vizinhas colapsam num cluster com o centroide entre elas', () {
    final clusters = agruparLojas(
      [_loja(1, -22.9068, -43.1729), _loja(2, -22.9070, -43.1731)],
      zoom: 13.0,
      area: _centro,
    );

    expect(clusters, hasLength(1));
    expect(clusters.single.total, 2);
    expect(clusters.single.centro.latitude, closeTo(-22.9069, 0.0001));
  });

  test('a mesma dupla se separa ao aproximar o zoom', () {
    final lojas = [_loja(1, -22.9068, -43.1729), _loja(2, -22.9070, -43.1731)];

    expect(agruparLojas(lojas, zoom: 13.0, area: _centro), hasLength(1));
    expect(agruparLojas(lojas, zoom: 18.0, area: _centro), hasLength(2));
  });

  test('lojas fora da área visível são descartadas antes de agrupar', () {
    final clusters = agruparLojas(
      [_loja(1, -22.9068, -43.1729), _loja(2, 38.7223, -9.1393)],
      zoom: 12.0,
      area: _centro,
    );

    expect(clusters, hasLength(1));
    expect(clusters.single.lojaUnica.id, 1);
  });

  test('a loja focada continua sozinha mesmo cercada de vizinhas', () {
    final clusters = agruparLojas(
      [
        _loja(1, -22.9068, -43.1729),
        _loja(2, -22.9069, -43.1730),
        _loja(3, -22.9070, -43.1731),
      ],
      zoom: 12.0,
      area: _centro,
      idSempreVisivel: 2,
    );

    expect(clusters, hasLength(2));
    expect(clusters.first.lojaUnica.id, 2);
  });

  test('área com margem alarga o recorte nos dois eixos', () {
    final ampliada = _centro.comMargem(0.5);

    expect(ampliada.contem(-22.9068, -43.1729), isTrue);
    expect(ampliada.norte, greaterThan(_centro.norte));
    expect(ampliada.oeste, lessThan(_centro.oeste));
  });

  test('agrupar mil lojas continua barato', () {
    final lojas = List.generate(
      1000,
      (i) => _loja(i, -22.9 - (i % 50) * 0.001, -43.2 + (i ~/ 50) * 0.001),
    );

    final relogio = Stopwatch()..start();
    final clusters = agruparLojas(lojas, zoom: 13.0, area: _centro);
    relogio.stop();

    expect(clusters.length, lessThan(lojas.length));
    expect(relogio.elapsedMilliseconds, lessThan(100));
  });

  group('espalhamento no zoom máximo', () {
    const ponto = LatLng(-22.9068, -43.1729);
    const distancia = Distance();

    List<StoreDto> mesmoPonto(List<int> ids) =>
        [for (final id in ids) _loja(id, ponto.latitude, ponto.longitude)];

    test('lojas no mesmo ponto se abrem em círculo, cada uma no seu lugar', () {
      final clusters = agruparLojas(mesmoPonto([1, 2, 3]), zoom: 18.0);

      expect(clusters, hasLength(3));
      expect(clusters.every((c) => c.isUnico && c.espalhado), isTrue);
      expect(clusters.map((c) => c.centro).toSet(), hasLength(3));
      expect(clusters.map((c) => c.origem).toSet(), {ponto});
    });

    test('o deslocamento é pequeno: poucos metros do ponto real', () {
      final clusters = agruparLojas(mesmoPonto([1, 2, 3]), zoom: 18.0);

      for (final c in clusters) {
        expect(distancia.as(LengthUnit.Meter, ponto, c.centro), inInclusiveRange(10, 25));
      }
    });

    test('cada loja fica sempre na mesma posição do círculo, qualquer que seja a ordem', () {
      final primeira = agruparLojas(mesmoPonto([1, 2, 3]), zoom: 18.0);
      final embaralhada = agruparLojas(mesmoPonto([3, 1, 2]), zoom: 18.0);

      Map<int, LatLng> porId(List<MapCluster> cs) => {for (final c in cs) c.lojaUnica.id: c.centro};

      expect(porId(embaralhada), porId(primeira));
    });

    test('grupo maior abre um círculo maior, para os marcadores não se sobreporem', () {
      double raio(int n) {
        final c = agruparLojas(mesmoPonto([for (var i = 1; i <= n; i++) i]), zoom: 18.0).first;
        return distancia.as(LengthUnit.Meter, ponto, c.centro);
      }

      expect(raio(8), greaterThan(raio(2)));
    });

    test('loja sozinha no zoom máximo fica exatamente onde está', () {
      final clusters = agruparLojas([_loja(1, ponto.latitude, ponto.longitude)], zoom: 18.0);

      expect(clusters.single.espalhado, isFalse);
      expect(clusters.single.centro, ponto);
    });

    test('lojas distantes no zoom máximo não são espalhadas', () {
      final clusters = agruparLojas([
        _loja(1, ponto.latitude, ponto.longitude),
        _loja(2, ponto.latitude - 0.002, ponto.longitude),
      ], zoom: 18.0);

      expect(clusters.any((c) => c.espalhado), isFalse);
    });
  });
}
