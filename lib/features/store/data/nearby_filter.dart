import 'package:geolocator/geolocator.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

List<StoreDto> lojasDentroDoRaio(
  List<StoreDto> lojas, {
  required double? lat,
  required double? lng,
  required double? raioKm,
}) {
  if (raioKm == null || lat == null || lng == null) return lojas;

  final raioMetros = raioKm * 1000;
  return lojas.where((loja) {
    if (!loja.temLocalizacao) return false;
    final distancia = Geolocator.distanceBetween(
      lat,
      lng,
      loja.latitude!,
      loja.longitude!,
    );
    return distancia <= raioMetros;
  }).toList();
}

bool temPosicaoParaFiltrar({
  required double? lat,
  required double? lng,
  required double? raioKm,
}) =>
    raioKm == null || (lat != null && lng != null);
