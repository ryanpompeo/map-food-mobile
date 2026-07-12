import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/merchant/data/models/merchant_model.dart';
import 'package:map_food/features/merchant/data/models/merchant_register_request.dart';

class MerchantService {
  final _client = ApiClient.instance;

  Future<void> register(MerchantRegisterRequest request) async {
    await _client.post<dynamic>(ApiConstants.comerciantes, data: request.toJson());
  }

  Future<MerchantModel> getById(int id) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.comerciantes}/$id',
    );
    return MerchantModel.fromJson(data);
  }

  /// PUT /comerciantes/{id} faz replace completo no backend, então [merchant]
  /// deve carregar todos os campos existentes (inclusive os não editáveis
  /// nesta tela, como cpf) para não serem apagados.
  /// [novaSenha] só é enviada se o usuário quiser trocar a senha — omitida,
  /// o backend preserva a senha atual automaticamente.
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

  Future<MerchantModel> uploadImagem(int id, XFile file) async {
    final data = await _client.uploadFile<Map<String, dynamic>>(
      '${ApiConstants.comerciantes}/$id/imagem',
      bytes: await file.readAsBytes(),
      fileName: file.name,
    );
    return MerchantModel.fromJson(data);
  }

  Future<MerchantModel> removerImagem(int id) async {
    final data = await _client.delete<Map<String, dynamic>>(
      '${ApiConstants.comerciantes}/$id/imagem',
    );
    return MerchantModel.fromJson(data);
  }
}