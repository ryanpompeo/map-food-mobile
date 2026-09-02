import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';

class DenunciaService {
  DenunciaService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<DenunciaModel> create({
    required int lojaId,
    required int consumidorId,
    required String motivo,
    String? descricao,
  }) async {
    final body = <String, dynamic>{
      'motivo': MotivosDenuncia.toApi(motivo),
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      'loja': {'id': lojaId},
      'consumidor': {'id': consumidorId},
    };

    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.denuncias,
      data: body,
    );
    return DenunciaModel.fromJson(data);
  }

  Future<List<DenunciaModel>> getMyComplaints(int consumidorId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.denuncias}/consumidor/$consumidorId',
    );
    return data
        .map((e) => DenunciaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DenunciaRecebidaModel>> getRecebidas(int comercianteId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.denuncias}/loja/comerciante/$comercianteId',
    );
    return data
        .map((e) => DenunciaRecebidaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
