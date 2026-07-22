import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';

/// Serviço responsável por consumir os endpoints de avaliação.
class AvaliacaoService {
  final _client = ApiClient.instance;

  /// Busca as avaliações de uma loja específica via GET /avaliacoes/loja/{id}.
  /// Rota pública — não requer token.
  Future<List<AvaliacaoModel>> buscarAvaliacoesDaLoja(int lojaId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.avaliacoes}/loja/$lojaId',
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

  /// Cria uma nova avaliação do consumidor autenticado para a loja, via
  /// POST /avaliacoes (rota geral). O backend sempre insere uma nova linha —
  /// múltiplas avaliações do mesmo consumidor para a mesma loja são
  /// permitidas (histórico), não há mais upsert.
  /// [lojaId]    ID da loja avaliada.
  /// [nota]      Nota inteira de 1 a 5.
  /// [comentario] Comentário opcional.
  Future<AvaliacaoModel> enviarAvaliacao({
    required int lojaId,
    required int nota,
    String? comentario,
  }) async {
    final body = <String, dynamic>{
      'id_loja': lojaId,
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
