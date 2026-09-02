import 'package:shared_preferences/shared_preferences.dart';

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
