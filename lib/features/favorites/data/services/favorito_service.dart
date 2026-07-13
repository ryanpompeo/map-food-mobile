import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class FavoritoService {
  final _client = ApiClient.instance;

  Future<List<StoreDto>> getFavoritos() async {
    final data = await _client.get<List<dynamic>>(ApiConstants.favoritos);
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorito(int lojaId) async {
    await _client.post<dynamic>('${ApiConstants.favoritos}/$lojaId');
  }

  Future<void> removeFavorito(int lojaId) async {
    await _client.delete('${ApiConstants.favoritos}/$lojaId');
  }
}
