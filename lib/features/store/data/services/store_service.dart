import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';


class StoreService {
  final _client = ApiClient.instance;

  Future<StoreDto> create(StoreCreateRequest request) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.lojas,
      data: request.toJson(),
    );
    return StoreDto.fromJson(data);
  }

  Future<StoreDto> update(int storeId, StoreCreateRequest request) async {
    final data = await _client.put<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$storeId',
      data: request.toJson(),
    );
    return StoreDto.fromJson(data);
  }

  Future<List<StoreDto>> getAll() async {
    final data = await _client.get<List<dynamic>>(ApiConstants.lojas);
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreDto>> getActive() async {
    final data = await _client.get<List<dynamic>>(ApiConstants.lojasAtivas);
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreDto>> searchByName(String nome) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/nome',
      queryParameters: {'nome': nome},
    );
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreDto>> search({String? nome, int? categoriaId}) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/busca',
      queryParameters: {
        if (nome != null && nome.isNotEmpty) 'nome': nome,
        if (categoriaId != null) 'categoriaId': categoriaId,
      },
    );
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Busca uma loja completa por id (GET /lojas/{id}/detalhes) — usado pra
  /// "hidratar" um StoreDto parcial (deep link vindo só com id/nome).
  Future<StoreDto> getById(int id) async {
    final data = await _client.get<Map<String, dynamic>>('${ApiConstants.lojas}/$id/detalhes');
    return StoreDto.fromJson(data);
  }

  /// Top 5 lojas ativas ordenadas por média de avaliação (GET /lojas/destaques).
  Future<List<StoreDto>> getDestaques() async {
    final data = await _client.get<List<dynamic>>('${ApiConstants.lojas}/destaques');
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreDto>> getByCategory(int categoryId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/categoria/$categoryId',
    );
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreDto>> getByMerchant(int merchantId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/comerciante/$merchantId',
    );
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StoreDto> uploadImagemCapa(int storeId, XFile file) async {
    final data = await _client.uploadFile<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$storeId/imagem',
      bytes: await file.readAsBytes(),
      fileName: file.name,
    );
    return StoreDto.fromJson(data);
  }

  Future<StoreDto> removerImagemCapa(int storeId) async {
    final data = await _client.delete<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$storeId/imagem',
    );
    return StoreDto.fromJson(data);
  }

  Future<StoreDto> uploadGaleria(int storeId, List<XFile> files) async {
    final itens = <(List<int>, String)>[];
    for (final f in files) {
      itens.add((await f.readAsBytes(), f.name));
    }
    final data = await _client.uploadFiles<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$storeId/galeria',
      files: itens,
    );
    return StoreDto.fromJson(data);
  }

  Future<StoreDto> removerImagemGaleria(int storeId, String url) async {
    final data = await _client.delete<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$storeId/galeria',
      queryParameters: {'url': url},
    );
    return StoreDto.fromJson(data);
  }
}
