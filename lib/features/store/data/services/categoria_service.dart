import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';

class CategoriaService {
  CategoriaService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  static List<CategoriaModel>? _cache;
  static DateTime? _cacheEm;

  static Future<List<CategoriaModel>>? _emVoo;

  static const Duration _validade = Duration(hours: 24);

  Future<List<CategoriaModel>> getAll({bool forcarAtualizacao = false}) {
    if (!forcarAtualizacao) {
      final cache = _cache;
      final cacheEm = _cacheEm;
      if (cache != null && cacheEm != null && DateTime.now().difference(cacheEm) < _validade) {
        return Future.value(cache);
      }

      final emVoo = _emVoo;
      if (emVoo != null) return emVoo;
    }

    return _emVoo = _buscar();
  }

  Future<List<CategoriaModel>> _buscar() async {
    try {
      final data = await _client.get<List<dynamic>>(ApiConstants.categorias);
      final categorias = List<CategoriaModel>.unmodifiable(
        data.map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>)),
      );
      _cache = categorias;
      _cacheEm = DateTime.now();
      return categorias;
    } finally {
      _emVoo = null;
    }
  }

  @visibleForTesting
  static void limparCache() {
    _cache = null;
    _cacheEm = null;
    _emVoo = null;
  }
}
