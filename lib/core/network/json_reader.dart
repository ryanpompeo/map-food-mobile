import 'package:map_food/core/errors/exception.dart';

/// Leitura defensiva de JSON vindo da API.
///
/// Antes, cada `fromJson` misturava três dialetos no mesmo objeto:
/// `(json['id'] as num)` (estoura em null), `json['nome'] as String?` (estoura
/// em tipo trocado) e `json['x']?.toString()` (tolerante a tudo). Os dois
/// primeiros lançavam `TypeError` — que não é [AppException] e, por isso,
/// atravessava todo o tratamento de erro do app.
///
/// Estas extensões concentram a decisão num lugar só: campo obrigatório
/// ausente ou inválido vira [ParseException] **com o nome do campo**; campo
/// opcional ausente vira `null` sem drama.
///
/// Vive fora do `ApiClient` de propósito: *ler JSON* não é responsabilidade do
/// cliente HTTP, e assim os models podem ser testados sem tocar em Dio.
extension JsonReader on Map<String, dynamic> {
  /// Inteiro obrigatório. Aceita `num` e string numérica (o backend devolve
  /// id como número, mas alguns agregados chegam como string).
  int requireInt(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw ParseException('Campo "$key" ausente ou inválido na resposta.');
  }

  /// String obrigatória e não vazia.
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

  /// String opcional. Devolve `null` também para string vazia — no domínio do
  /// app, `""` e "não informado" são a mesma coisa em todo campo opcional.
  String? optString(String key) {
    final value = this[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  /// String opcional com padrão. Diferente de `optString(k) ?? padrao` só na
  /// legibilidade do call site, que é onde este helper mais aparece.
  String stringOr(String key, String padrao) => optString(key) ?? padrao;

  /// Lista opcional. Devolve lista vazia (nunca null) quando o campo falta ou
  /// não é uma lista — quem consome sempre itera.
  List<dynamic> optList(String key) {
    final value = this[key];
    return value is List ? value : const [];
  }

  /// Lista de strings, ignorando entradas vazias.
  List<String> optStringList(String key) => optList(key)
      .map((e) => e?.toString() ?? '')
      .where((e) => e.isNotEmpty)
      .toList();
}
