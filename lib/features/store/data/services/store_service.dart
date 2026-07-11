import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';


class StoreService {
  final _client = ApiClient.instance;

  Future<StoreDto> getById(int id) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$id',
    );
    return StoreDto.fromJson(data);
  }

  /// Envia a foto de capa da loja. O corpo da resposta do POST não é
  /// confiável, então busca a loja novamente pra devolver o estado atualizado.
  /// Usa bytes (não o path) porque o Flutter Web não expõe caminho de arquivo.
  Future<StoreDto> uploadImagemCapa(int id, XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name),
    });
    await _client.post<dynamic>('${ApiConstants.lojas}/$id/imagem', data: formData);
    return getById(id);
  }

  /// Envia fotos para a galeria interna da loja (máx. 10 no backend).
  Future<StoreDto> uploadGaleria(int id, List<XFile> files) async {
    final formData = FormData.fromMap({
      'files': await Future.wait(files.map((f) async => MultipartFile.fromBytes(await f.readAsBytes(), filename: f.name))),
    });
    await _client.post<dynamic>('${ApiConstants.lojas}/$id/galeria', data: formData);
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
