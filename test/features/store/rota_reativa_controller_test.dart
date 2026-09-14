import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/features/store/data/services/route_service.dart';
import 'package:map_food/features/store/presentation/controllers/rota_reativa_controller.dart';

import '../../support/aguardar.dart';

const _usuario = LatLng(-22.9068, -43.1729);
const _loja = LatLng(-22.9100, -43.1760);
const _lojaQuaseParada = LatLng(-22.9103, -43.1760);
const _lojaQueAndou = LatLng(-22.9110, -43.1760);
const _usuarioQueAndou = LatLng(-22.9063, -43.1729);

class _RotasFalsas {
  final List<(LatLng, LatLng)> pedidos = [];
  final List<Completer<RouteResult?>> respostas = [];
  bool responderNaHora = true;
  RouteResult? Function(LatLng, LatLng) resultado =
      (o, d) => RouteResult(pontos: [o, d], distanciaMetros: 500);

  Future<RouteResult?> calcular(LatLng origem, LatLng destino) {
    pedidos.add((origem, destino));
    if (responderNaHora) return Future.value(resultado(origem, destino));
    final resposta = Completer<RouteResult?>();
    respostas.add(resposta);
    return resposta.future;
  }
}

void main() {
  late _RotasFalsas rotas;
  late RotaReativaController rota;

  RotaReativaController criar({Duration intervalo = Duration.zero}) => rota = RotaReativaController(
        calcular: rotas.calcular,
        destinoInicial: _loja,
        intervaloMinimo: intervalo,
      );

  setUp(() => rotas = _RotasFalsas());

  tearDown(() => rota.dispose());

  test('a primeira posição conhecida do usuário traça a rota', () async {
    criar().atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);

    expect(rotas.pedidos.single, (_usuario, _loja));
    expect(rota.estado.value.distanciaMetros, 500);
  });

  test('loja que andou menos de 75 m não gera nova chamada', () async {
    criar().atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);

    rota.atualizarDestino(_lojaQuaseParada);
    await escoar();

    expect(rotas.pedidos, hasLength(1));
  });

  test('loja que andou 75 m ou mais recalcula a rota até ela', () async {
    criar().atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);

    rota.atualizarDestino(_lojaQueAndou);
    await aguardarAte(() => rotas.pedidos.length == 2);

    expect(rotas.pedidos.last.$2, _lojaQueAndou);
  });

  test('usuário que andou 50 m ou mais recalcula a partir de onde está', () async {
    criar().atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);

    rota.atualizarOrigem(_usuarioQueAndou);
    await aguardarAte(() => rotas.pedidos.length == 2);

    expect(rotas.pedidos.last.$1, _usuarioQueAndou);
  });

  test('no máximo uma chamada por intervalo: a mudança seguinte espera a janela', () async {
    criar(intervalo: const Duration(milliseconds: 150)).atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);

    rota.atualizarDestino(_lojaQueAndou);
    await escoar();
    expect(rotas.pedidos, hasLength(1), reason: 'ainda dentro dos 150 ms');

    await aguardarAte(() => rotas.pedidos.length == 2);
    expect(rotas.pedidos.last.$2, _lojaQueAndou);
  });

  test('uma chamada por vez: o que muda durante o cálculo entra na próxima, já atualizado', () async {
    rotas.responderNaHora = false;
    criar().atualizarOrigem(_usuario);
    await escoar();

    rota.atualizarDestino(_lojaQuaseParada);
    rota.atualizarDestino(_lojaQueAndou);
    expect(rotas.pedidos, hasLength(1));

    rotas.respostas.first.complete(RouteResult(pontos: const [_usuario, _loja], distanciaMetros: 500));
    await aguardarAte(() => rotas.pedidos.length == 2);

    expect(rotas.pedidos.last.$2, _lojaQueAndou);
  });

  test('falha do serviço de rotas mantém o traçado anterior na tela', () async {
    criar(intervalo: const Duration(milliseconds: 150)).atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);
    final anterior = rota.estado.value.pontos;

    rotas.resultado = (_, _) => null;
    rota.atualizarDestino(_lojaQueAndou);
    await aguardarAte(() => rotas.pedidos.length == 2 && !rota.estado.value.calculando);

    expect(rota.estado.value.pontos, anterior);
  });

  test('falha sem traçado anterior cai na linha reta até a loja', () async {
    rotas.resultado = (_, _) => null;
    criar().atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);

    expect(rota.estado.value.pontos, [_usuario, _loja]);
  });

  test('loja que saiu do mapa congela a rota; ao voltar, a rota volta a acompanhar', () async {
    criar().atualizarOrigem(_usuario);
    await aguardarAte(() => rota.estado.value.temRota);

    rota.lojaSaiu();
    rota.atualizarOrigem(_usuarioQueAndou);
    await escoar();
    expect(rota.estado.value.lojaIndisponivel, isTrue);
    expect(rotas.pedidos, hasLength(1));

    rota.atualizarDestino(_lojaQueAndou);
    await aguardarAte(() => rotas.pedidos.length == 2);
    expect(rota.estado.value.lojaIndisponivel, isFalse);
  });

  test('só o primeiro cálculo conta como "traçando rota"; os recálculos são silenciosos', () async {
    rotas.responderNaHora = false;
    criar().atualizarOrigem(_usuario);
    await escoar();
    expect(rota.estado.value.primeiroCalculo, isTrue);

    rotas.respostas.first.complete(RouteResult(pontos: const [_usuario, _loja], distanciaMetros: 500));
    await aguardarAte(() => rota.estado.value.temRota);
    rota.atualizarDestino(_lojaQueAndou);
    await escoar();

    expect(rota.estado.value.calculando, isTrue);
    expect(rota.estado.value.primeiroCalculo, isFalse);
    rotas.respostas.last.complete(null);
    await escoar();
  });

  test('sair da tela no meio do cálculo não quebra nada', () async {
    rotas.responderNaHora = false;
    criar().atualizarOrigem(_usuario);
    await escoar();

    rota.dispose();
    rotas.respostas.first.complete(RouteResult(pontos: const [_usuario, _loja], distanciaMetros: 500));
    await escoar();

    rota = criar();
  });
}
