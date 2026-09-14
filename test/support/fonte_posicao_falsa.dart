import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';

Position posicaoDeTeste({
  double latitude = -22.9068,
  double longitude = -43.1729,
  double precisao = 8,
}) =>
    Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime(2026, 9, 13, 10),
      accuracy: precisao,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

class FontePosicaoFalsa implements FontePosicao {
  AcessoLocalizacao acesso = AcessoLocalizacao.liberado;
  Completer<AcessoLocalizacao>? acessoPendente;
  Position posicaoAtualDevolvida = posicaoDeTeste();

  final List<LocationSettings> pedidos = [];
  final List<StreamController<Position>> emissores = [];
  final StreamController<ServiceStatus> servico = StreamController<ServiceStatus>.broadcast();

  StreamController<Position> get atual => emissores.last;

  bool get lendo => emissores.isNotEmpty && emissores.last.hasListener;

  @override
  Stream<Position> posicoes(LocationSettings configuracao) {
    if (emissores.any((emissor) => emissor.hasListener)) {
      throw StateError('o plugin de GPS mantém um único stream nativo por app');
    }
    pedidos.add(configuracao);
    final emissor = StreamController<Position>();
    emissores.add(emissor);
    return emissor.stream;
  }

  @override
  Stream<ServiceStatus> statusDoServico() => servico.stream;

  @override
  Future<AcessoLocalizacao> verificarAcesso() => acessoPendente?.future ?? Future.value(acesso);

  @override
  Future<Position> posicaoAtual(LocationSettings configuracao) async => posicaoAtualDevolvida;

  Position? ultimaConhecidaDevolvida;

  @override
  Future<Position?> ultimaConhecida() async => ultimaConhecidaDevolvida;

  Future<void> fechar() async {
    await servico.close();
    for (final emissor in emissores) {
      await emissor.close();
    }
  }
}
