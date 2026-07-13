import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Histórico de buscas recentes, persistido localmente por dispositivo.
class SearchHistoryService {
  static const _key = 'search_history';
  static const _maxItems = 10;

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final history = await getHistory();
    history.removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    history.insert(0, trimmed);

    await _save(history.take(_maxItems).toList());
  }

  Future<void> removeQuery(String query) async {
    final history = await getHistory();
    history.removeWhere((q) => q == query);
    await _save(history);
  }

  Future<void> clear() async {
    await _save([]);
  }

  Future<void> _save(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(history));
  }
}
