import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/features/merchant/presentation/controllers/ronda_uplink.dart';
import 'package:map_food/features/store/data/loja_fora_de_ronda_exception.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';

import '../../support/fonte_posicao_falsa.dart';

Future<void> _escoar() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late List<Position> transmitidas;
  late List<Completer<void>> respostas;
  late List<Position> enviadas;
  late List<int> falhas;
  late List<LojaForaDeRondaException> recusas;
  late RondaUplink uplink;

  final p1 = posicaoDeTeste(latitude: -22.91);
  final p2 = posicaoDeTeste(latitude: -22.92);
  final p3 = posicaoDeTeste(latitude: -22.93);

  setUp(() {
    transmitidas = [];
    respostas = [];
    enviadas = [];
    falhas = [];
    recusas = [];
    uplink = RondaUplink(
      transmitir: (posicao) {
        transmitidas.add(posicao);
        final resposta = Completer<void>();
        respostas.add(resposta);
        return resposta.future;
      },
      esperas: const [Duration(milliseconds: 1)],
      aoEnviar: enviadas.add,
      aoFalhar: falhas.add,
      aoSerRecusado: recusas.add,
    );
  });

  tearDown(() => uplink.encerrar());

  test('uma requisição por vez: o que chega durante o voo espera, e só a mais recente sai', () async {
    uplink.enviar(p1);
    uplink.enviar(p2);
    uplink.enviar(p3);

    expect(transmitidas, [p1]);

    respostas[0].complete();
    await _escoar();

    expect(transmitidas, [p1, p3]);
    expect(enviadas, [p1]);
  });

  test('falha passageira reenvia depois da espera, levando a posição mais recente', () async {
    uplink.enviar(p1);
    uplink.enviar(p2);
    respostas[0].completeError(const NetworkException());
    await _escoar();

    expect(falhas, [1]);
    expect(transmitidas, [p1, p2]);
  });

  test('sem posição nova, a que falhou é a que volta a ser tentada', () async {
    uplink.enviar(p1);
    respostas[0].completeError(const ServerException());
    await _escoar();

    expect(transmitidas, [p1, p1]);
  });

  test('sucesso depois de falhas zera a contagem', () async {
    uplink.enviar(p1);
    respostas[0].completeError(const NetworkException());
    await _escoar();
    respostas[1].complete();
    await _escoar();

    uplink.enviar(p2);
    respostas[2].completeError(const NetworkException());
    await _escoar();

    expect(enviadas, [p1]);
    expect(falhas, [1, 1]);
  });

  test('recusa da API encerra a fila: nada mais sai', () async {
    uplink.enviar(p1);
    respostas[0].completeError(const LojaForaDeRondaException(StatusLoja.inativa, 'fechada'));
    await _escoar();

    uplink.enviar(p2);
    await _escoar();

    expect(recusas.single.status, StatusLoja.inativa);
    expect(transmitidas, [p1]);
  });

  test('encerrar cancela um reenvio já agendado', () async {
    uplink.enviar(p1);
    respostas[0].completeError(const NetworkException());
    await Future<void>.delayed(Duration.zero);
    expect(falhas, [1]);

    uplink.encerrar();
    await _escoar();

    expect(transmitidas, [p1]);
  });
}
