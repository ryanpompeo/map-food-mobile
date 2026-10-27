import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/location/rota_externa.dart';

void main() {
  tearDown(RotaExterna.restaurarAbridor);

  group('endereços de destino', () {
    test('o app de mapas recebe as coordenadas e o nome da loja', () {
      final destino = destinoNoAppDeMapas(-22.9068, -43.1729, 'Espetinho do Zé');

      expect(destino.scheme, 'geo');
      expect(destino.path, '-22.9068,-43.1729');
      expect(destino.queryParameters['q'], '-22.9068,-43.1729(Espetinho do Zé)');
    });

    test('loja sem nome não vira um rótulo vazio entre parênteses', () {
      final destino = destinoNoAppDeMapas(-22.9068, -43.1729, '  ');

      expect(destino.queryParameters['q'], '-22.9068,-43.1729');
    });

    test('a web recebe um pedido de rota, não só um ponto no mapa', () {
      final destino = destinoNaWeb(-22.9068, -43.1729);

      expect(destino.host, 'www.google.com');
      expect(destino.path, '/maps/dir/');
      expect(destino.queryParameters['destination'], '-22.9068,-43.1729');
    });
  });

  group('traçar', () {
    test('tenta primeiro o app de mapas do aparelho', () async {
      final tentados = <Uri>[];
      RotaExterna.abridor = (destino) async {
        tentados.add(destino);
        return true;
      };

      final abriu = await RotaExterna.tracar(
        latitude: -22.9068,
        longitude: -43.1729,
        nome: 'Espetinho do Zé',
      );

      expect(abriu, isTrue);
      expect(tentados.single.scheme, 'geo');
    });

    test('sem app de mapas instalado, cai para o navegador', () async {
      final tentados = <Uri>[];
      RotaExterna.abridor = (destino) async {
        tentados.add(destino);
        return destino.scheme == 'https';
      };

      final abriu = await RotaExterna.tracar(
        latitude: -22.9068,
        longitude: -43.1729,
        nome: 'Espetinho do Zé',
      );

      expect(abriu, isTrue);
      expect(tentados.map((d) => d.scheme), ['geo', 'https']);
    });

    test('erro ao abrir o app de mapas não derruba a tentativa seguinte', () async {
      final tentados = <Uri>[];
      RotaExterna.abridor = (destino) async {
        tentados.add(destino);
        if (destino.scheme == 'geo') throw Exception('sem atividade para geo:');
        return true;
      };

      final abriu = await RotaExterna.tracar(
        latitude: -22.9068,
        longitude: -43.1729,
        nome: 'Espetinho do Zé',
      );

      expect(abriu, isTrue);
      expect(tentados.map((d) => d.scheme), ['geo', 'https']);
    });

    test('quando nada abre, a tela precisa saber para avisar', () async {
      RotaExterna.abridor = (_) async => false;

      final abriu = await RotaExterna.tracar(
        latitude: -22.9068,
        longitude: -43.1729,
        nome: 'Espetinho do Zé',
      );

      expect(abriu, isFalse);
    });
  });
}
