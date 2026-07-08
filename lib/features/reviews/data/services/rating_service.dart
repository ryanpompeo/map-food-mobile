import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/reviews/data/models/avaliacao_model.dart';

/// Serviço responsável por consumir os endpoints de avaliação.
class RatingService {
  final _client = ApiClient.instance;

  /// Busca as avaliações de uma loja específica via GET /avaliacoes/loja/{id}.
  /// Rota pública — não requer token.
  Future<List<AvaliacaoModel>> getStoreRatings(int storeId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.avaliacoes}/loja/$storeId',
    );
    return data
        .map((e) => AvaliacaoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Envia uma nova avaliação via POST /avaliacoes.
  /// Requer token JWT de Consumidor (o backend extrai o id_consumidor do token).
  /// [lojaId]    ID da loja avaliada.
  /// [nota]      Nota inteira de 1 a 5.
  /// [comentario] Comentário opcional.
  Future<AvaliacaoModel> submitRating({
    required int lojaId,
    required int nota,
    String? comentario,
  }) async {
    final body = <String, dynamic>{
      'loja': {'id': lojaId},
      'nota': nota,
      if (comentario != null && comentario.trim().isNotEmpty)
        'comentario': comentario.trim(),
    };
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.avaliacoes,
      data: body,
    );
    return AvaliacaoModel.fromJson(data);
  }
}
