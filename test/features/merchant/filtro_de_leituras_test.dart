import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/merchant/presentation/controllers/configuracao_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/filtro_de_leituras.dart';

import '../../support/fonte_posicao_falsa.dart';

const _base = -22.9068;
const _trintaETresMetros = 0.0003;

void main() {
  late FiltroDeLeituras filtro;
  final inicio = DateTime(2026, 9, 13, 10);

  setUp(() => filtro = FiltroDeLeituras(const ConfiguracaoRonda()));

  test('a primeira leitura precisa é aceita', () {
    expect(filtro.avaliar(posicaoDeTeste(), inicio), isNotNull);
  });

  test('comerciante parado não gera envio', () {
    filtro.avaliar(posicaoDeTeste(), inicio);

    expect(filtro.avaliar(posicaoDeTeste(), inicio), isNull);
  });

  test('deslocamento acima de 25 m com boa precisão é aceito', () {
    filtro.avaliar(posicaoDeTeste(), inicio);

    final andou = posicaoDeTeste(latitude: _base + _trintaETresMetros, precisao: 8);

    expect(filtro.avaliar(andou, inicio), same(andou));
  });

  test('deslocamento menor que o erro da própria leitura é tratado como ruído', () {
    filtro.avaliar(posicaoDeTeste(), inicio);

    final ruido = posicaoDeTeste(latitude: _base + _trintaETresMetros, precisao: 34);

    expect(filtro.avaliar(ruido, inicio), isNull);
  });

  test('leitura imprecisa espera a janela e depois sai a melhor, marcada como sinal fraco', () {
    final ruim = posicaoDeTeste(precisao: 80);
    final menosRuim = posicaoDeTeste(precisao: 50);

    expect(filtro.avaliar(ruim, inicio), isNull);
    expect(filtro.avaliar(menosRuim, inicio.add(const Duration(seconds: 60))), isNull);

    final aceita = filtro.avaliar(ruim, inicio.add(const Duration(minutes: 2)));

    expect(aceita, same(menosRuim));
    expect(filtro.precisaoBaixa, isTrue);
  });

  test('uma leitura precisa no meio da janela a encerra', () {
    filtro.avaliar(posicaoDeTeste(precisao: 80), inicio);
    filtro.avaliar(posicaoDeTeste(), inicio.add(const Duration(seconds: 30)));

    final depois = filtro.avaliar(
      posicaoDeTeste(precisao: 80),
      inicio.add(const Duration(minutes: 2)),
    );

    expect(depois, isNull);
    expect(filtro.precisaoBaixa, isFalse);
  });

  test('a posição da abertura vira a referência de deslocamento', () {
    filtro.semear(posicaoDeTeste());

    expect(filtro.ultimaAceita, isNotNull);
    expect(filtro.avaliar(posicaoDeTeste(), inicio), isNull);
  });

  test('precisão negativa, que o iOS usa para leitura inválida, conta como imprecisa', () {
    expect(filtro.avaliar(posicaoDeTeste(precisao: -1), inicio), isNull);
  });
}
