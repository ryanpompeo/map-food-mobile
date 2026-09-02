import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/merchant/data/models/merchant_model.dart';
import 'package:map_food/features/merchant/data/models/merchant_register_request.dart';

class MerchantService {
  MerchantService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<MerchantModel> uploadImagem(int id, XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name),
    });
    await _client.post<dynamic>(
      '${ApiConstants.comerciantes}/$id/imagem',
      data: formData,
      options: ApiClient.uploadOptions,
    );
    return getById(id);
  }

  Future<MerchantModel> removerImagem(int id) async {
    await _client.delete('${ApiConstants.comerciantes}/$id/imagem');
    return getById(id);
  }

  Future<void> delete(int id) async {
    await _client.delete('${ApiConstants.comerciantes}/$id');
  }

  Future<void> register(MerchantRegisterRequest request) async {
    await _client.post<dynamic>(ApiConstants.comerciantes, data: request.toJson());
  }

  Future<MerchantModel> getById(int id) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.comerciantes}/$id',
    );
    return MerchantModel.fromJson(data);
  }

  Future<MerchantModel> update(MerchantModel merchant, {String? novaSenha}) async {
    final body = merchant.toJson();
    if (novaSenha != null && novaSenha.isNotEmpty) {
      body['senha'] = novaSenha;
    }
    final data = await _client.put<Map<String, dynamic>>(
      '${ApiConstants.comerciantes}/${merchant.id}',
      data: body,
    );
    return MerchantModel.fromJson(data);
  }
}
