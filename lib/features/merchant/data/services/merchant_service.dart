import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/merchant/data/models/merchant_model.dart';
import 'package:map_food/features/merchant/data/models/merchant_register_request.dart';

class MerchantService {
  final _client = ApiClient.instance;

  /// Envia a foto de perfil. O corpo da resposta do POST não é confiável,
  /// então busca o comerciante novamente pra devolver o estado atualizado.
  /// Usa bytes (não o path) porque o Flutter Web não expõe caminho de arquivo.
  Future<MerchantModel> uploadImagem(int id, XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name),
    });
    await _client.post<dynamic>('${ApiConstants.comerciantes}/$id/imagem', data: formData);
    return getById(id);
  }

  Future<MerchantModel> removerImagem(int id) async {
    await _client.delete('${ApiConstants.comerciantes}/$id/imagem');
    return getById(id);
  }

  /// Exclusão definitiva da conta — o backend já faz cascade (lojas,
  /// avaliações, denúncias, acessos).
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
}