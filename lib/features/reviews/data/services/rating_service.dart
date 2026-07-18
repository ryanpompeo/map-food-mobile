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

  /// Busca as avaliações do consumidor autenticado via GET /avaliacoes/minhas.
  Future<List<AvaliacaoModel>> getMinhasAvaliacoes() async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.avaliacoes}/minhas',
    );
    return data
        .map((e) => AvaliacaoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cria ou edita a avaliação do consumidor autenticado para a loja, via
  /// POST /mobile/api/v1/avaliacoes (upsert — Fase 4/5). O backend decide
  /// INSERT vs UPDATE pelo par (consumidor, loja); nunca mais devolve 409
  /// de duplicidade, então o chamador não precisa mais tratar esse caso.
  /// [lojaId]    ID da loja avaliada.
  /// [nota]      Nota inteira de 1 a 5.
  /// [comentario] Comentário opcional.
  Future<AvaliacaoModel> submitRating({
    required int lojaId,
    required int nota,
    String? comentario,
  }) async {
    final body = <String, dynamic>{
      'lojaId': lojaId,
      'nota': nota,
      if (comentario != null && comentario.trim().isNotEmpty)
        'comentario': comentario.trim(),
    };
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.mobileAvaliacoes,
      data: body,
    );
    return AvaliacaoModel.fromJson(data);
  }

  /// Avaliação já existente do consumidor autenticado para essa loja, ou
  /// `null` se ele ainda não avaliou — usado pra pré-preencher edição.
  Future<AvaliacaoModel?> getMinhaAvaliacao(int lojaId) async {
    final data = await _client.get<Map<String, dynamic>?>(
      '${ApiConstants.mobileAvaliacoes}/minha/$lojaId',
    );
    return data == null ? null : AvaliacaoModel.fromJson(data);
  }
}
