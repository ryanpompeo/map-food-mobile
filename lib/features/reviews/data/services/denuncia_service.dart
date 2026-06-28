import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/reviews/data/models/denuncia_model.dart';

class DenunciaService {
  final _client = ApiClient.instance;

  /// Cria uma denúncia para uma loja.
  /// [lojaId] ID da loja.
  /// [motivo] Label da UI (ex: 'Fraude ou golpe') — será convertido para enum da API.
  /// [descricao] Texto descritivo opcional.
  /// [consumidorId] ID do consumidor (passado no body como objeto).
  Future<DenunciaModel> create({
    required int lojaId,
    required String motivo,
    String? descricao,
  }) async {
    final body = <String, dynamic>{
      'motivo': MotivosDenuncia.toApi(motivo),
      'id_loja': lojaId,
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
    };

    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.denuncias,
      data: body,
    );
    return DenunciaModel.fromJson(data);
  }

  /// Busca as denúncias feitas por um consumidor específico.
  Future<List<DenunciaModel>> getMyComplaints(int consumidorId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.denuncias}/consumidor/$consumidorId',
    );
    return data
        .map((e) => DenunciaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
