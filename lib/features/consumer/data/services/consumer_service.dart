import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/consumer/data/models/consumer_model.dart';
import 'package:map_food/features/consumer/data/models/consumer_register_request.dart';

class ConsumerService {
  ConsumerService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<ConsumerModel> uploadImagem(int id, XFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name),
    });
    await _client.post<dynamic>(
      '${ApiConstants.consumidores}/$id/imagem',
      data: formData,
      options: ApiClient.uploadOptions,
    );
    return getById(id);
  }

  Future<ConsumerModel> removerImagem(int id) async {
    await _client.delete('${ApiConstants.consumidores}/$id/imagem');
    return getById(id);
  }

  Future<void> delete(int id) async {
    await _client.delete('${ApiConstants.consumidores}/$id');
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
