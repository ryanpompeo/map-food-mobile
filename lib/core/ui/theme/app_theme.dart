import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paleta semântica de cores do MapFood, com variante clara e escura,
/// injetada nativamente no [ThemeData] via [ThemeExtension].
///
/// Novas cores devem ser adicionadas aqui — nunca como `Color(0x...)` solto
/// espalhado pelas telas. Telas ainda não migradas continuam usando
/// [ColorsPalette] diretamente; a migração é incremental, feita fase a fase.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color accent;
  final Color accentIcon;
  final Color success;
  final Color warning;
  final Color error;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.accent,
    required this.accentIcon,
    required this.success,
    required this.warning,
    required this.error,
  });

  static const light = AppColorsExtension(
    background: Color.fromARGB(255, 243, 244, 245),
    surface: Colors.white,
    textPrimary: Colors.black,
    textSecondary: Color(0xFF757575),
    divider: Color(0xFFE5E7EB),
    accent: Color(0xFFD6011B),
    accentIcon: Color(0xFFE33E33),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFB07500),
    error: Color(0xFFD6011B),
  );

  static const dark = AppColorsExtension(
    background: Color(0xFF12172A),
    surface: Color(0xFF1C2136),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFAEB4C2),
    divider: Color(0xFF2E3448),
    accent: Color(0xFFE33E3E),
    accentIcon: Color(0xFFE33E33),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFE0A030),
    error: Color(0xFFE33E3E),
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? accent,
    Color? accentIcon,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      accentIcon: accentIcon ?? this.accentIcon,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentIcon: Color.lerp(accentIcon, other.accentIcon, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

/// Atalho para ler a paleta semântica ativa: `context.appColors.accent`.
extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}

/// Configuração nativa de [ThemeData] (claro/escuro) do MapFood.
///
/// Telas existentes continuam usando `ColorsPalette` diretamente (sem
/// alteração nesta fase) — este é o ponto de entrada para telas novas ou
/// migradas passarem a usar `context.appColors`/`Theme.of(context)`.
class MapFoodTheme {
  MapFoodTheme._();

  static final ThemeData light = _build(Brightness.light, AppColorsExtension.light);
  static final ThemeData dark = _build(Brightness.dark, AppColorsExtension.dark);

  static ThemeData _build(Brightness brightness, AppColorsExtension colors) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme),
      colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: colors.accent,
        secondary: colors.accent,
        surface: colors.surface,
        error: colors.error,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.textPrimary,
        selectionColor: colors.textPrimary.withValues(alpha: 0.15),
        selectionHandleColor: colors.textPrimary,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [colors],
    );
  }
}

/// Controla o [ThemeMode] ativo (claro/escuro/sistema) e persiste a escolha
/// localmente. Ainda não está conectado a nenhuma tela — o item "Tema do
/// Aplicativo" no menu de perfil (hoje com `onTap` vazio) vai chamar
/// `AppThemeController.instance.setMode(...)` numa fase futura.
class AppThemeController extends ChangeNotifier {
  AppThemeController._();
  static final AppThemeController instance = AppThemeController._();

  static const _prefsKey = 'app_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Carrega a preferência salva. Deve ser chamado uma vez em `main()`,
  /// antes do `runApp`.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}
