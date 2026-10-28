import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';

String comoDataSimples(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-'
    '${data.month.toString().padLeft(2, '0')}-'
    '${data.day.toString().padLeft(2, '0')}';

class DenunciaService {
  DenunciaService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<String> enviarFoto(XFile arquivo) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await arquivo.readAsBytes(), filename: arquivo.name),
    });
    final data = await _client.post<Map<String, dynamic>>(
      '${ApiConstants.denuncias}/foto',
      data: formData,
      options: ApiClient.uploadOptions,
    );
    return data['fotoUrl']?.toString() ?? '';
  }

  Future<DenunciaModel> create({
    required int lojaId,
    required int consumidorId,
    required String motivo,
    String? descricao,
    DateTime? dataConsumo,
    String? itemConsumido,
    String? fotoUrl,
  }) async {
    final body = <String, dynamic>{
      'motivo': MotivosDenuncia.toApi(motivo),
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      'loja': {'id': lojaId},
      'consumidor': {'id': consumidorId},
      if (dataConsumo != null) 'dataConsumo': comoDataSimples(dataConsumo),
      if (itemConsumido != null && itemConsumido.trim().isNotEmpty)
        'itemConsumido': itemConsumido.trim(),
      if (fotoUrl != null && fotoUrl.isNotEmpty) 'fotoUrl': fotoUrl,
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

  Future<DenunciaRecebidaModel> responder(int denunciaId, String texto) async {
    final data = await _client.post<Map<String, dynamic>>(
      '${ApiConstants.denuncias}/$denunciaId/resposta',
      data: <String, dynamic>{'texto': texto.trim()},
    );
    return DenunciaRecebidaModel.fromJson(data);
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
