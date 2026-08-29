import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';

class DenunciaService {
  DenunciaService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// Cria a denúncia do consumidor autenticado para a loja, via
  /// POST /denuncias (rota geral, contrato legado). O controller não extrai
  /// o consumidor do JWT — espera a entidade `Denuncia` crua no corpo, com
  /// `consumidor`/`loja` já resolvidos — por isso [consumidorId] precisa ser
  /// informado pelo chamador (normalmente vindo de `AuthStorage.getSession()`).
  /// Não há checagem de duplicidade no backend: reenviar cria uma nova
  /// denúncia, não há mais 409 nem upsert.
  /// [lojaId] ID da loja.
  /// [consumidorId] ID do consumidor autenticado (da sessão local).
  /// [motivo] Label da UI (ex: 'Fraude ou golpe') — será convertido para enum da API.
  /// [descricao] Texto descritivo opcional.
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

  /// Busca as denúncias feitas por um consumidor específico.
  Future<List<DenunciaModel>> getMyComplaints(int consumidorId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.denuncias}/consumidor/$consumidorId',
    );
    return data
        .map((e) => DenunciaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Denúncias recebidas pelas lojas de um comerciante, via
  /// GET /denuncias/loja/comerciante/{comercianteId}.
  ///
  /// Devolve a lista inteira — motivo, status, data e loja de cada uma. A
  /// versão anterior deste método descartava tudo isso e devolvia só
  /// `data.length`, porque o único consumo era um card de contagem. O painel
  /// de Estatísticas usa os campos para dizer **por que** e **quando**, que é
  /// o que o comerciante pode agir a respeito.
  ///
  /// Só o dono das lojas (ou um administrador) recebe 200 aqui; a API não
  /// expõe a identidade de quem denunciou.
  Future<List<DenunciaRecebidaModel>> getRecebidas(int comercianteId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.denuncias}/loja/comerciante/$comercianteId',
    );
    return data
        .map((e) => DenunciaRecebidaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
