import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/reviews/data/models/denuncia_model.dart';

class DenunciaService {
  final _client = ApiClient.instance;

  /// Cria ou edita a denúncia do consumidor autenticado para a loja, via
  /// POST /mobile/api/v1/denuncias (upsert — Fase 4/5). O backend decide
  /// INSERT vs UPDATE pelo par (consumidor, loja) e extrai o consumidor do
  /// JWT — não precisa mais enviar `consumidor`/`comerciante` no corpo.
  /// Editar uma denúncia já tratada reabre o status para PENDENTE.
  /// Nunca mais devolve 409 de duplicidade.
  /// [lojaId] ID da loja.
  /// [motivo] Label da UI (ex: 'Fraude ou golpe') — será convertido para enum da API.
  /// [descricao] Texto descritivo opcional.
  Future<DenunciaModel> create({
    required int lojaId,
    required String motivo,
    String? descricao,
  }) async {
    final body = <String, dynamic>{
      'lojaId': lojaId,
      'motivo': MotivosDenuncia.toApi(motivo),
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
    };

    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.mobileDenuncias,
      data: body,
    );
    return DenunciaModel.fromJson(data);
  }

  /// Denúncia já existente do consumidor autenticado para essa loja, ou
  /// `null` se ele ainda não denunciou — usado pra pré-preencher edição.
  Future<DenunciaModel?> getMinhaDenuncia(int lojaId) async {
    final data = await _client.get<Map<String, dynamic>?>(
      '${ApiConstants.mobileDenuncias}/minha/$lojaId',
    );
    return data == null ? null : DenunciaModel.fromJson(data);
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
