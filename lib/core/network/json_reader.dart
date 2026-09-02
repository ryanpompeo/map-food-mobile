import 'package:map_food/core/errors/exception.dart';

extension JsonReader on Map<String, dynamic> {
  int requireInt(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw ParseException('Campo "$key" ausente ou inválido na resposta.');
  }

  String requireString(String key) {
    final value = this[key];
    if (value != null) {
      final text = value.toString();
      if (text.isNotEmpty) return text;
    }
    throw ParseException('Campo "$key" ausente ou inválido na resposta.');
  }

  int? optInt(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? optDouble(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? optString(String key) {
    final value = this[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  String stringOr(String key, String padrao) => optString(key) ?? padrao;

  List<dynamic> optList(String key) {
    final value = this[key];
    return value is List ? value : const [];
  }

  List<String> optStringList(String key) => optList(key)
      .map((e) => e?.toString() ?? '')
      .where((e) => e.isNotEmpty)
      .toList();
}
