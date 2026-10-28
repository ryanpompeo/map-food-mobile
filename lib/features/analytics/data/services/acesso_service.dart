import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/analytics/data/models/acesso_metricas.dart';

class AcessoService {
  AcessoService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AcessoMetricas> buscarMetricas(
    int lojaId, {
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.lojas}/$lojaId/acessos',
      queryParameters: {
        'dataInicio': aaaaMmDd(inicio),
        'dataFim': aaaaMmDd(fim),
      },
    );
    return AcessoMetricas.fromJson(data);
  }
}
