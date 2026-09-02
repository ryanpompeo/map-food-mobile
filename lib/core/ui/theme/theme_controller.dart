import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._(super.initialMode);

  static const _prefsKey = 'theme_mode';

  static ThemeController? _instance;

  static ThemeController get instance {
    assert(
      _instance != null,
      'ThemeController.load() precisa ser aguardado no main() antes de '
      'qualquer acesso a ThemeController.instance.',
    );
    return _instance ??= ThemeController._(ThemeMode.system);
  }

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _decode(prefs.getString(_prefsKey)) ?? ThemeMode.system;
    return _instance = ThemeController._(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (value == mode) return;
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  static ThemeMode? _decode(String? raw) {
    for (final mode in ThemeMode.values) {
      if (mode.name == raw) return mode;
    }
    return null;
  }
}
