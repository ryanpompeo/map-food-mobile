import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';

class DenunciaService {
  final _client = ApiClient.instance;

  /// Cria a denúncia do consumidor autenticado para a loja, via
  /// POST /denuncias (rota geral) — extrai o consumidor do JWT, não precisa
  /// enviar `consumidor`/`comerciante` no corpo. A API geral bloqueia
  /// duplicidade: se o consumidor já denunciou essa loja, devolve 409 (sem
  /// upsert nem reabertura de status) — o chamador deve tratar esse caso.
  /// [lojaId] ID da loja.
  /// [motivo] Label da UI (ex: 'Fraude ou golpe') — será convertido para enum da API.
  /// [descricao] Texto descritivo opcional.
  Future<DenunciaModel> create({
    required int lojaId,
    required String motivo,
    String? descricao,
  }) async {
    final body = <String, dynamic>{
      'id_loja': lojaId,
      'motivo': MotivosDenuncia.toApi(motivo),
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

  /// Total de denúncias recebidas pelas lojas de um comerciante, via
  /// GET /denuncias/loja/comerciante/{comercianteId}.
  Future<int> getComplaintsReceivedCount(int comercianteId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.denuncias}/loja/comerciante/$comercianteId',
    );
    return data.length;
  }
}
