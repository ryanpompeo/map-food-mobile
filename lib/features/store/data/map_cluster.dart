import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class AreaVisivel {
  const AreaVisivel({
    required this.sul,
    required this.oeste,
    required this.norte,
    required this.leste,
  });

  final double sul;
  final double oeste;
  final double norte;
  final double leste;

  AreaVisivel comMargem(double fator) {
    final alturaExtra = (norte - sul).abs() * fator;
    final larguraExtra = (leste - oeste).abs() * fator;
    return AreaVisivel(
      sul: sul - alturaExtra,
      oeste: oeste - larguraExtra,
      norte: norte + alturaExtra,
      leste: leste + larguraExtra,
    );
  }

  bool contem(double latitude, double longitude) =>
      latitude >= sul && latitude <= norte && longitude >= oeste && longitude <= leste;
}

class MapCluster {
  const MapCluster(this.centro, this.lojas);

  final LatLng centro;
  final List<StoreDto> lojas;

  bool get isUnico => lojas.length == 1;

  StoreDto get lojaUnica => lojas.first;

  int get total => lojas.length;
}

const double raioAgrupamentoPx = 68.0;

const double zoomSemAgrupamento = 17.0;

const double _tamanhoTilePx = 256.0;

double _mundoEmPixels(double zoom) => _tamanhoTilePx * math.pow(2.0, zoom).toDouble();

double _projetarX(double longitude, double mundo) => (longitude + 180.0) / 360.0 * mundo;

double _projetarY(double latitude, double mundo) {
  final seno = math.sin(latitude * math.pi / 180.0).clamp(-0.9999, 0.9999);
  final y = 0.5 - math.log((1 + seno) / (1 - seno)) / (4 * math.pi);
  return y * mundo;
}

List<StoreDto> lojasVisiveis(List<StoreDto> lojas, AreaVisivel? area) {
  if (area == null) return lojas.where((l) => l.temLocalizacao).toList();
  return lojas
      .where((l) => l.temLocalizacao && area.contem(l.latitude!, l.longitude!))
      .toList();
}

List<MapCluster> agruparLojas(
  List<StoreDto> lojas, {
  required double zoom,
  AreaVisivel? area,
  double raioPx = raioAgrupamentoPx,
  int? idSempreVisivel,
}) {
  final candidatas = lojasVisiveis(lojas, area);
  if (zoom >= zoomSemAgrupamento) {
    return candidatas.map(_clusterDeUma).toList(growable: false);
  }

  final mundo = _mundoEmPixels(zoom);
  final celulas = <int, List<StoreDto>>{};
  final isoladas = <MapCluster>[];

  for (final loja in candidatas) {
    if (loja.id == idSempreVisivel) {
      isoladas.add(_clusterDeUma(loja));
      continue;
    }
    final coluna = (_projetarX(loja.longitude!, mundo) / raioPx).floor();
    final linha = (_projetarY(loja.latitude!, mundo) / raioPx).floor();
    celulas.putIfAbsent(_chave(coluna, linha), () => <StoreDto>[]).add(loja);
  }

  return [...isoladas, ...celulas.values.map(_consolidar)];
}

MapCluster _clusterDeUma(StoreDto loja) =>
    MapCluster(LatLng(loja.latitude!, loja.longitude!), [loja]);

int _chave(int coluna, int linha) => coluna * 16777216 + linha;

MapCluster _consolidar(List<StoreDto> lojas) {
  if (lojas.length == 1) return _clusterDeUma(lojas.first);
  var somaLat = 0.0;
  var somaLng = 0.0;
  for (final loja in lojas) {
    somaLat += loja.latitude!;
    somaLng += loja.longitude!;
  }
  final total = lojas.length;
  return MapCluster(LatLng(somaLat / total, somaLng / total), lojas);
}
