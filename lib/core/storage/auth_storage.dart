import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';

class AuthStorage {
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUserNome = 'user_nome';
  static const _keyUserTipo = 'user_tipo';
  static const _keyUserEmail = 'user_email';

  static const _keyFirstLoginAt = 'first_login_at';

  static Future<void> saveSession(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, response.token);
    await prefs.setInt(_keyUserId, response.id);
    await prefs.setString(_keyUserNome, response.nome);
    await prefs.setString(_keyUserTipo, response.tipo);
    await prefs.setString(_keyUserEmail, response.email);
    await _ensureFirstLoginDate(prefs);
  }

  static Future<void> _ensureFirstLoginDate(SharedPreferences prefs) async {
    if (prefs.getString(_keyFirstLoginAt) != null) return;
    await prefs.setString(_keyFirstLoginAt, DateTime.now().toIso8601String());
  }

  static Future<int> diasNoApp() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureFirstLoginDate(prefs);
    final raw = prefs.getString(_keyFirstLoginAt)!;
    return DateTime.now().difference(DateTime.parse(raw)).inDays;
  }

  static Future<void> updateNomeEmail(String nome, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserNome, nome);
    await prefs.setString(_keyUserEmail, email);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<AuthResponse?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token == null) return null;
    return AuthResponse(
      token: token,
      id: prefs.getInt(_keyUserId) ?? 0,
      nome: prefs.getString(_keyUserNome) ?? '',
      tipo: prefs.getString(_keyUserTipo) ?? '',
      email: prefs.getString(_keyUserEmail) ?? '',
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserNome);
    await prefs.remove(_keyUserTipo);
    await prefs.remove(_keyUserEmail);
  }
}
