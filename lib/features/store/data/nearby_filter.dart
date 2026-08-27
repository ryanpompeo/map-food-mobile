import 'package:geolocator/geolocator.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Corte por raio das lojas do mapa.
///
/// Vive fora do widget de propósito: é a única regra de negócio do filtro de
/// distância da home, e dentro de um `State` ela só era verificável abrindo o
/// app com o GPS ligado. Aqui é uma função pura — mesma entrada, mesma saída,
/// testável sem mapa, sem GPS e sem rede (ver `test/features/store/
/// nearby_filter_test.dart`).
///
/// ## O contrato, incluindo os casos em que ele NÃO corta
///
/// - **[raioKm] nulo** é o "Todos" do modal de filtros: devolve a lista
///   inteira, sem corte. É escolha do usuário.
/// - **Sem posição do usuário** ([lat]/[lng] nulos) também devolve a lista
///   inteira. Não há de onde medir distância, e um mapa vazio seria pior do
///   que um mapa sem filtro. Vale registrar que este caso é **silencioso**: o
///   chip "1 km" continua marcado no modal enquanto nada está sendo filtrado.
///   Quem chama é que tem contexto pra avisar o usuário — ver
///   [temPosicaoParaFiltrar].
/// - **Loja sem coordenadas** é excluída quando há um raio ativo: não dá pra
///   afirmar que ela está dentro de 1 km se não se sabe onde ela fica.
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

/// `true` quando o raio escolhido está de fato sendo aplicado.
///
/// Serve para a UI distinguir "não há loja nenhuma dentro de 1 km" de "o raio
/// de 1 km não está valendo porque não sabemos onde você está" — dois estados
/// que hoje produzem telas parecidas e exigem ações opostas do usuário.
bool temPosicaoParaFiltrar({
  required double? lat,
  required double? lng,
  required double? raioKm,
}) =>
    raioKm == null || (lat != null && lng != null);
