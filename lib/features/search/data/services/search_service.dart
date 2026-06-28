import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Serviço responsável por consumir o endpoint GET /lojas/search.
/// Retorna [StoreDto] já populados com dados reais da API:
/// nome, categorias e mediaAvaliacao calculada no banco.
class SearchService {
  final _client = ApiClient.instance;

  static const _searchPath = '/lojas/search';

  /// Retorna todas as lojas ATIVAS, ordenadas por mediaAvaliacao DESC.
  Future<List<StoreDto>> searchAll() async {
    final data = await _client.get<List<dynamic>>(_searchPath);
    return _parseList(data);
  }

  /// Busca lojas pelo nome (parcial, case-insensitive).
  Future<List<StoreDto>> searchByName(String nome) async {
    if (nome.trim().isEmpty) return searchAll();
    final data = await _client.get<List<dynamic>>(
      _searchPath,
      queryParameters: {'nome': nome.trim()},
    );
    return _parseList(data);
  }

  /// Filtra lojas por categoria específica.
  Future<List<StoreDto>> searchByCategory(int categoriaId) async {
    final data = await _client.get<List<dynamic>>(
      _searchPath,
      queryParameters: {'categoriaId': categoriaId},
    );
    return _parseList(data);
  }

  /// Filtra lojas por nome E categoria simultaneamente.
  Future<List<StoreDto>> search({String? nome, int? categoriaId}) async {
    final params = <String, dynamic>{};
    if (nome != null && nome.trim().isNotEmpty) params['nome'] = nome.trim();
    if (categoriaId != null) params['categoriaId'] = categoriaId;

    final data = await _client.get<List<dynamic>>(
      _searchPath,
      queryParameters: params.isEmpty ? null : params,
    );
    return _parseList(data);
  }

  List<StoreDto> _parseList(List<dynamic> data) {
    return data
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
