import 'package:shared_preferences/shared_preferences.dart';

/// Histórico de busca persistido localmente (sem backend, sem sincronização
/// entre dispositivos) — sempre o termo mais recente no topo (índice 0).
class SearchHistoryService {
  SearchHistoryService._();
  static final SearchHistoryService instance = SearchHistoryService._();

  static const _prefsKey = 'search_history';
  static const _maxTerms = 10;

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? const [];
  }

  /// Insere [term] no topo do histórico. Se já existir (comparação sem
  /// diferenciar maiúsculas/minúsculas, ignorando espaços nas pontas), a
  /// ocorrência antiga é removida antes de reinserir no topo — nunca
  /// duplica. Mantém no máximo 10 termos: ao inserir o 11º, o mais antigo
  /// (posição 10) é descartado automaticamente. Retorna a lista já
  /// atualizada, para a UI não precisar de uma segunda leitura.
  Future<List<String>> addTerm(String term) async {
    final normalized = term.trim();
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? <String>[];
    if (normalized.isEmpty) return current;

    current.removeWhere((t) => t.toLowerCase() == normalized.toLowerCase());
    current.insert(0, normalized);

    final updated = current.length > _maxTerms ? current.sublist(0, _maxTerms) : current;
    await prefs.setStringList(_prefsKey, updated);
    return updated;
  }

  /// Remove [term] do histórico (comparação sem diferenciar
  /// maiúsculas/minúsculas). Retorna a lista já atualizada.
  Future<List<String>> removeTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? <String>[];
    current.removeWhere((t) => t.toLowerCase() == term.toLowerCase());
    await prefs.setStringList(_prefsKey, current);
    return current;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
