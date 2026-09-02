import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';

class AvaliacaoService {
  AvaliacaoService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<AvaliacaoModel>> buscarAvaliacoesDaLoja(int lojaId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.avaliacoes}/loja/$lojaId',
    );
    return data
        .map((e) => AvaliacaoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AvaliacaoModel>> getMinhasAvaliacoes() async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.avaliacoes}/minhas',
    );
    return data
        .map((e) => AvaliacaoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AvaliacaoModel> enviarAvaliacao({
    required int lojaId,
    required int nota,
    String? comentario,
  }) async {
    final body = <String, dynamic>{
      'nota': nota,
      if (comentario != null && comentario.trim().isNotEmpty)
        'comentario': comentario.trim(),
      'loja': {'id': lojaId},
    };
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.avaliacoes,
      data: body,
    );
    return AvaliacaoModel.fromJson(data);
  }
}
