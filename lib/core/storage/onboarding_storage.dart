import 'package:shared_preferences/shared_preferences.dart';

/// Marca de "já viu a tela de boas-vindas" — separada de [AuthStorage] de
/// propósito: não faz parte da sessão e **não** pode ser apagada no logout,
/// senão sair da conta jogaria o usuário de volta no onboarding.
class OnboardingStorage {
  const OnboardingStorage._();

  static const _keyVisto = 'onboarding_visto';

  static Future<bool> jaVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVisto) ?? false;
  }

  static Future<void> marcarVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVisto, true);
  }
}
