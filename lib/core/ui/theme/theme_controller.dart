import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fonte única de verdade do [ThemeMode] do app.
///
/// É um [ValueNotifier] (não um [ChangeNotifier] com campos soltos) porque
/// o único estado que existe aqui é o próprio ThemeMode — isso permite
/// plugar direto em [ValueListenableBuilder]/[ListenableBuilder] sem
/// precisar de um model extra. Toda a lógica de leitura/gravação em disco
/// (SharedPreferences) fica encapsulada aqui, longe das telas: a UI só lê
/// [value] e chama [setThemeMode].
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._(super.initialMode);

  static const _prefsKey = 'theme_mode';

  static ThemeController? _instance;

  /// Instância única do controller, acessível globalmente sem
  /// InheritedWidget/Provider — o app inteiro (main.dart, telas de
  /// configurações, etc.) escuta o mesmo [ValueNotifier].
  ///
  /// Só é populada de verdade depois de [load] ser aguardado no `main()`.
  /// Acessar antes disso é erro de uso: falha em debug (assert) e, em
  /// release, cai num fallback `ThemeMode.system` em vez de derrubar o app.
  static ThemeController get instance {
    assert(
      _instance != null,
      'ThemeController.load() precisa ser aguardado no main() antes de '
      'qualquer acesso a ThemeController.instance.',
    );
    return _instance ??= ThemeController._(ThemeMode.system);
  }

  /// Lê a preferência salva (se existir) e cria a instância singleton.
  /// Deve ser chamado uma única vez, com `await`, ANTES do `runApp` — é o
  /// que garante que o primeiro frame já nasce no tema certo, sem FOUC
  /// (claro piscando antes de trocar pra escuro, ou vice-versa).
  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _decode(prefs.getString(_prefsKey)) ?? ThemeMode.system;
    return _instance = ThemeController._(mode);
  }

  /// Troca o tema e persiste a escolha. Idempotente: repetir o modo atual
  /// não gera notificação nem escrita em disco à toa.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (value == mode) return;
    value = mode; // ValueNotifier.value= já dispara notifyListeners().
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
