import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// ThemeData de claro/escuro do app, centralizados aqui (fora do
/// `main.dart`) pra manter o `MaterialApp` enxuto e permitir alterar um sem
/// mexer no outro. [ThemeController] só escolhe QUAL destes dois usar; a
/// definição visual de cada um vive só aqui.
class AppTheme {
  AppTheme._();

  static final ThemeData light = _base(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ColorsPalette.whiteBackground,
    fieldFillColor: ColorsPalette.white,
    fieldBorderColor: ColorsPalette.white,
    cursorColor: ColorsPalette.black,
    mapColors: MapFoodColors.light,
  );

  static final ThemeData dark = _base(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    fieldFillColor: const Color(0xFF1E1E1E),
    fieldBorderColor: const Color(0xFF1E1E1E),
    cursorColor: ColorsPalette.white,
    mapColors: MapFoodColors.dark,
  );

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color fieldFillColor,
    required Color fieldBorderColor,
    required Color cursorColor,
    required MapFoodColors mapColors,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorsPalette.redComponents,
        brightness: brightness,
      ),
      // Registra o MapFoodColors correspondente pra esta brightness — é o
      // que faz `Theme.of(context).extension<MapFoodColors>()` (via
      // `context.mapColors`) devolver os tokens certos em cada tema.
      extensions: <ThemeExtension<dynamic>>[mapColors],
      textTheme: GoogleFonts.poppinsTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cursorColor,
        selectionColor: cursorColor.withValues(alpha: 0.15),
        selectionHandleColor: cursorColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: fieldBorderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: fieldBorderColor)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: fieldBorderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: cursorColor, width: 1.2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: ColorsPalette.redComponents, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: ColorsPalette.redComponents, width: 1.2)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorsPalette.redComponents,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
