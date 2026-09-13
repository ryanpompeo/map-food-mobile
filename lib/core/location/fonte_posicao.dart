import 'package:geolocator/geolocator.dart';

abstract interface class FontePosicao {
  Stream<Position> posicoes(LocationSettings configuracao);

  Stream<ServiceStatus> statusDoServico();
}

class FontePosicaoGeolocator implements FontePosicao {
  const FontePosicaoGeolocator();

  @override
  Stream<Position> posicoes(LocationSettings configuracao) =>
      Geolocator.getPositionStream(locationSettings: configuracao);

  @override
  Stream<ServiceStatus> statusDoServico() => Geolocator.getServiceStatusStream();
}
