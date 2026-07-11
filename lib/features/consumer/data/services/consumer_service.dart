import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/consumer/data/models/consumer_model.dart';
import 'package:map_food/features/consumer/data/models/consumer_register_request.dart';

class ConsumerService {
  final _client = ApiClient.instance;

  /// Envia a foto de perfil. O corpo da resposta do POST não é confiável,
  /// então busca o consumidor novamente pra devolver o estado atualizado.
  /// Usa bytes (não o path) porque o Flutter Web não expõe caminho de arquivo.
  Future<ConsumerModel> uploadImagem(int id, XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name),
    });
    await _client.post<dynamic>('${ApiConstants.consumidores}/$id/imagem', data: formData);
    return getById(id);
  }

  Future<ConsumerModel> removerImagem(int id) async {
    await _client.delete('${ApiConstants.consumidores}/$id/imagem');
    return getById(id);
  }

  Future<void> register(ConsumerRegisterRequest request) async {
    await _client.post<dynamic>(ApiConstants.consumidores, data: request.toJson());
  }

  Future<ConsumerModel> getById(int id) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.consumidores}/$id',
    );
    return ConsumerModel.fromJson(data);
  }

  /// PUT /consumidores/{id} faz replace completo no backend, então [consumer]
  /// deve carregar todos os campos existentes (inclusive os não editáveis
  /// nesta tela, como cpf) para não serem apagados.
  /// [novaSenha] só é enviada se o usuário quiser trocar a senha — omitida,
  /// o backend preserva a senha atual automaticamente.
  Future<ConsumerModel> update(ConsumerModel consumer, {String? novaSenha}) async {
    final body = consumer.toJson();
    if (novaSenha != null && novaSenha.isNotEmpty) {
      body['senha'] = novaSenha;
    }
    final data = await _client.put<Map<String, dynamic>>(
      '${ApiConstants.consumidores}/${consumer.id}',
      data: body,
    );
    return ConsumerModel.fromJson(data);
  }
}