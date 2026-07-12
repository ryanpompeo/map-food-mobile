import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/consumer/data/models/consumer_model.dart';
import 'package:map_food/features/consumer/data/models/consumer_register_request.dart';

class ConsumerService {
  final _client = ApiClient.instance;

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

  Future<ConsumerModel> uploadImagem(int id, XFile file) async {
    final data = await _client.uploadFile<Map<String, dynamic>>(
      '${ApiConstants.consumidores}/$id/imagem',
      bytes: await file.readAsBytes(),
      fileName: file.name,
    );
    return ConsumerModel.fromJson(data);
  }

  Future<ConsumerModel> removerImagem(int id) async {
    final data = await _client.delete<Map<String, dynamic>>(
      '${ApiConstants.consumidores}/$id/imagem',
    );
    return ConsumerModel.fromJson(data);
  }

  /// Exclusão de conta — o backend faz soft delete + anonimização (LGPD),
  /// não um DELETE físico. Do lado do app, é só um DELETE comum que retorna
  /// 204; quem chama é responsável por limpar a sessão local depois.
  Future<void> deleteAccount(int id) async {
    await _client.delete<dynamic>('${ApiConstants.consumidores}/$id');
  }
}