import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';

class CategoriaService {
  final _client = ApiClient.instance;

  /// Busca todas as categorias via GET /categorias. Rota pública.
  Future<List<CategoriaModel>> getAll() async {
    final data = await _client.get<List<dynamic>>(ApiConstants.categorias);
    return data
        .map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
