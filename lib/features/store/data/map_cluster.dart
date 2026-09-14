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
  const MapCluster(this.centro, this.lojas, {this.origem});

  final LatLng centro;
  final List<StoreDto> lojas;
  final LatLng? origem;

  bool get isUnico => lojas.length == 1;

  bool get espalhado => origem != null;

  StoreDto get lojaUnica => lojas.first;

  int get total => lojas.length;
}

const double raioAgrupamentoPx = 68.0;

const double zoomSemAgrupamento = 17.0;

const double raioColisaoPx = 24.0;

const double raioMinimoEspalhamentoPx = 30.0;

const double _espacoPorLojaNoCirculoPx = 8.0;

const double _tamanhoTilePx = 256.0;

double _mundoEmPixels(double zoom) => _tamanhoTilePx * math.pow(2.0, zoom).toDouble();

double _projetarX(double longitude, double mundo) => (longitude + 180.0) / 360.0 * mundo;

double _projetarY(double latitude, double mundo) {
  final seno = math.sin(latitude * math.pi / 180.0).clamp(-0.9999, 0.9999);
  final y = 0.5 - math.log((1 + seno) / (1 - seno)) / (4 * math.pi);
  return y * mundo;
}

LatLng _desprojetar(double x, double y, double mundo) {
  final longitude = x / mundo * 360.0 - 180.0;
  final n = math.pi * (1 - 2 * y / mundo);
  final latitude = math.atan((math.exp(n) - math.exp(-n)) / 2) * 180.0 / math.pi;
  return LatLng(latitude, longitude);
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
  final mundo = _mundoEmPixels(zoom);
  if (zoom >= zoomSemAgrupamento) return _espalharSobrepostas(candidatas, mundo);

  final isoladas = candidatas.where((l) => l.id == idSempreVisivel).map(_clusterDeUma);
  final agrupaveis = candidatas.where((l) => l.id != idSempreVisivel);
  final celulas = _porCelula(agrupaveis, mundo, raioPx);

  return [...isoladas, ...celulas.values.map(_consolidar)];
}

Map<int, List<StoreDto>> _porCelula(Iterable<StoreDto> lojas, double mundo, double ladoPx) {
  final celulas = <int, List<StoreDto>>{};
  for (final loja in lojas) {
    final coluna = (_projetarX(loja.longitude!, mundo) / ladoPx).floor();
    final linha = (_projetarY(loja.latitude!, mundo) / ladoPx).floor();
    celulas.putIfAbsent(_chave(coluna, linha), () => <StoreDto>[]).add(loja);
  }
  return celulas;
}

List<MapCluster> _espalharSobrepostas(List<StoreDto> lojas, double mundo) => [
      for (final grupo in _porCelula(lojas, mundo, raioColisaoPx).values)
        ..._espalhar(grupo, mundo),
    ];

List<MapCluster> _espalhar(List<StoreDto> grupo, double mundo) {
  if (grupo.length == 1) return [_clusterDeUma(grupo.first)];
  final ordenado = [...grupo]..sort((a, b) => a.id.compareTo(b.id));
  final origem = _consolidar(ordenado).centro;
  final cx = _projetarX(origem.longitude, mundo);
  final cy = _projetarY(origem.latitude, mundo);
  final raio = math.max(raioMinimoEspalhamentoPx, ordenado.length * _espacoPorLojaNoCirculoPx);
  final passo = 2 * math.pi / ordenado.length;
  return [
    for (var i = 0; i < ordenado.length; i++)
      MapCluster(
        _desprojetar(cx + raio * math.cos(passo * i), cy + raio * math.sin(passo * i), mundo),
        [ordenado[i]],
        origem: origem,
      ),
  ];
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
