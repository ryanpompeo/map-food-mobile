import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class StoreService {
  StoreService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<StoreDto> getById(int id) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$id',
    );
    return StoreDto.fromJson(data);
  }

  Future<StoreDto> uploadImagemCapa(int id, XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name),
    });
    await _client.post<dynamic>(
      '${ApiConstants.lojas}/$id/imagem',
      data: formData,
      options: ApiClient.uploadOptions,
    );
    return getById(id);
  }

  Future<StoreDto> uploadGaleria(int id, List<XFile> files) async {
    final formData = FormData.fromMap({
      'files': await Future.wait(files.map((f) async => MultipartFile.fromBytes(await f.readAsBytes(), filename: f.name))),
    });
    await _client.post<dynamic>(
      '${ApiConstants.lojas}/$id/galeria',
      data: formData,
      options: ApiClient.uploadOptions,
    );
    return getById(id);
  }

  Future<StoreDto> removerImagemCapa(int id) async {
    await _client.delete('${ApiConstants.lojas}/$id/imagem');
    return getById(id);
  }

  Future<StoreDto> removerFotoGaleria(int id, String url) async {
    await _client.delete('${ApiConstants.lojas}/$id/galeria?url=${Uri.encodeQueryComponent(url)}');
    return getById(id);
  }

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
    final data = await _client.get<List<dynamic>>('${ApiConstants.lojas}/ativas/completa');
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreDto>> getPopulares({int limit = 10}) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/populares',
      queryParameters: {'limit': limit},
    );
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StoreDto> getResumo(int id) async {
    final data = await _client.get<Map<String, dynamic>>('${ApiConstants.lojas}/$id/completa');
    return StoreDto.fromJson(data);
  }

  Future<StoreDto> atualizarStatus(StoreDto atual, String status) {
    return update(atual.id, StoreCreateRequest.fromStore(atual, statusLoja: status));
  }

  Future<StoreDto> atualizarPosicao(StoreDto atual, double latitude, double longitude) {
    return update(
      atual.id,
      StoreCreateRequest.fromStore(atual, latitude: latitude, longitude: longitude),
    );
  }

  Future<void> excluirLoja(int id) async {
    await _client.delete('${ApiConstants.lojas}/$id');
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
}
