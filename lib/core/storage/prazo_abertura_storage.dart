import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrazoAberturaStorage {
  static const _chave = 'loja_prazo_abertura';

  static Future<Map<int, DateTime>> ler() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null || bruto.isEmpty) return <int, DateTime>{};
    try {
      final mapa = jsonDecode(bruto) as Map<String, dynamic>;
      final prazos = <int, DateTime>{};
      for (final entrada in mapa.entries) {
        final lojaId = int.tryParse(entrada.key);
        final encerraEm = DateTime.tryParse('${entrada.value}');
        if (lojaId != null && encerraEm != null) prazos[lojaId] = encerraEm;
      }
      return prazos;
    } catch (_) {
      return <int, DateTime>{};
    }
  }

  static Future<void> salvar(Map<int, DateTime> prazos) async {
    final prefs = await SharedPreferences.getInstance();
    if (prazos.isEmpty) {
      await prefs.remove(_chave);
      return;
    }
    final mapa = <String, String>{
      for (final entrada in prazos.entries) '${entrada.key}': entrada.value.toIso8601String(),
    };
    await prefs.setString(_chave, jsonEncode(mapa));
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
