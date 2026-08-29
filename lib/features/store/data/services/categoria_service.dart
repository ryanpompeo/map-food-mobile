import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';

/// Acesso a `GET /categorias`, com cache de processo.
///
/// ## Por que o cache existe
///
/// A lista de categorias é praticamente imutável (muda quando o administrador
/// cadastra uma nova, o que não acontece durante o uso do app) e é pedida por
/// **quatro** telas independentes: a busca, o cadastro de loja, o painel do
/// comerciante e o explorador do mapa da home. Cada uma criava seu próprio
/// `CategoriaService` e chamava [getAll] no `initState`.
///
/// Como as abas vivem juntas num `IndexedStack`, elas montam praticamente ao
/// mesmo tempo: eram quatro requisições idênticas em voo, no exato momento em
/// que o app também busca lojas, favoritos e posição do GPS.
///
/// ## Duas defesas, não uma
///
/// Cache sozinho não resolveria: as quatro chamadas partem antes de qualquer
/// uma responder, então não há o que consultar ainda. Por isso há também a
/// deduplicação por [_emVoo] — a segunda chamada concorrente recebe a mesma
/// `Future` da primeira, em vez de abrir outra requisição.
///
/// ## O que este cache ainda não é
///
/// Vive só em memória: fechar o app o descarta. Persistir em disco fica para a
/// camada offline-first, que vai guardar lojas e avaliações no mesmo lugar —
/// criar agora um mecanismo próprio só para categorias seria mais um formato
/// para migrar depois.
class CategoriaService {
  CategoriaService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// `static`: o cache é do processo, não da instância — cada tela constrói o
  /// seu próprio `CategoriaService`, e um cache de instância não seria
  /// compartilhado por ninguém.
  static List<CategoriaModel>? _cache;
  static DateTime? _cacheEm;

  /// Requisição em andamento, se houver. É o que faz quatro chamadas
  /// simultâneas virarem uma só.
  static Future<List<CategoriaModel>>? _emVoo;

  /// Teto de validade. Alto de propósito: na prática o app não fica 24h aberto,
  /// então isto é menos "revalidar de vez em quando" e mais uma rede de
  /// segurança para uma sessão que ficou dias em segundo plano.
  static const Duration _validade = Duration(hours: 24);

  /// Busca as categorias, servindo do cache quando ele ainda vale.
  ///
  /// [forcarAtualizacao] ignora o cache e vai à rede — para um "puxar para
  /// atualizar" ou para uma tela que precise ver uma categoria recém-criada.
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
      // Também no caminho de erro: falha não pode deixar uma `Future` já
      // rejeitada pendurada em [_emVoo], ou toda tentativa seguinte receberia
      // a mesma falha sem nunca refazer a requisição. O erro em si continua
      // subindo para quem chamou — as quatro telas já sabem exibi-lo.
      _emVoo = null;
    }
  }

  /// Zera o cache. Existe para os testes: [_cache] é estático e vazaria de um
  /// caso para o outro.
  @visibleForTesting
  static void limparCache() {
    _cache = null;
    _cacheEm = null;
    _emVoo = null;
  }
}
