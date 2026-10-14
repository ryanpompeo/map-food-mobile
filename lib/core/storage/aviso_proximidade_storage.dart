import 'package:shared_preferences/shared_preferences.dart';

class AvisoProximidadeStorage {
  static const _chaveData = 'favorita_proxima_ultimo_dia';
  static const _chaveLoja = 'favorita_proxima_ultima_loja';

  static Future<String?> ultimoDia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveData);
  }

  static Future<int?> ultimaLoja() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chaveLoja);
  }

  static Future<void> registrar(String dia, int lojaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveData, dia);
    await prefs.setInt(_chaveLoja, lojaId);
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveData);
    await prefs.remove(_chaveLoja);
  }
}
