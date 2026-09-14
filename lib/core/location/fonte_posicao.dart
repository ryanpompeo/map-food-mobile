import 'package:geolocator/geolocator.dart';

enum AcessoLocalizacao { liberado, servicoDesligado, negado }

abstract interface class FontePosicao {
  Stream<Position> posicoes(LocationSettings configuracao);

  Stream<ServiceStatus> statusDoServico();

  Future<AcessoLocalizacao> verificarAcesso();

  Future<Position> posicaoAtual(LocationSettings configuracao);

  Future<Position?> ultimaConhecida();
}

class FontePosicaoGeolocator implements FontePosicao {
  const FontePosicaoGeolocator();

  static const Duration _limite = Duration(seconds: 10);

  @override
  Stream<Position> posicoes(LocationSettings configuracao) =>
      Geolocator.getPositionStream(locationSettings: configuracao);

  @override
  Stream<ServiceStatus> statusDoServico() => Geolocator.getServiceStatusStream();

  @override
  Future<AcessoLocalizacao> verificarAcesso() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled().timeout(_limite)) {
        return AcessoLocalizacao.servicoDesligado;
      }
      return _permitido(await _permissao()) ? AcessoLocalizacao.liberado : AcessoLocalizacao.negado;
    } catch (_) {
      return AcessoLocalizacao.negado;
    }
  }

  @override
  Future<Position> posicaoAtual(LocationSettings configuracao) =>
      Geolocator.getCurrentPosition(locationSettings: configuracao).timeout(_limite);

  @override
  Future<Position?> ultimaConhecida() async {
    try {
      return await Geolocator.getLastKnownPosition().timeout(_limite);
    } catch (_) {
      return null;
    }
  }

  static Future<LocationPermission> _permissao() async {
    final atual = await Geolocator.checkPermission().timeout(_limite);
    if (atual != LocationPermission.denied) return atual;
    return Geolocator.requestPermission().timeout(_limite);
  }

  static bool _permitido(LocationPermission permissao) =>
      permissao == LocationPermission.always || permissao == LocationPermission.whileInUse;
}
