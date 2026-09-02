import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = _base(
    brightness: Brightness.light,
    colors: MapFoodColors.light,
  );

  static final ThemeData dark = _base(
    brightness: Brightness.dark,
    colors: MapFoodColors.dark,
  );

  static ThemeData _base({
    required Brightness brightness,
    required MapFoodColors colors,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: MfColor.brand,
      onPrimary: ColorsPalette.white,
      primaryContainer: isDark ? MfColor.brandSurfaceDark : MfColor.brandSurface,
      onPrimaryContainer: MfColor.brand,
      secondary: isDark ? colors.textPrimary : MfColor.ink,
      onSecondary: isDark ? MfColor.ink : ColorsPalette.white,
      secondaryContainer: colors.surfaceAlt,
      onSecondaryContainer: colors.textPrimary,
      error: MfColor.danger,
      onError: ColorsPalette.white,
      errorContainer: isDark ? MfColor.dangerSurfaceDark : MfColor.dangerSurface,
      onErrorContainer: MfColor.danger,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surfaceAlt,
      surfaceContainerHigh: colors.surfaceAlt,
      surfaceContainerHighest: colors.surfaceAlt,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.borderStrong,
      outlineVariant: colors.border,
      shadow: ColorsPalette.black,
      scrim: colors.overlay,
      inverseSurface: isDark ? colors.textPrimary : MfColor.ink,
      onInverseSurface: isDark ? MfColor.ink : ColorsPalette.white,
      inversePrimary: MfColor.brand,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      extensions: <ThemeExtension<dynamic>>[colors],

      applyElevationOverlayColor: false,

      textTheme: _textTheme(colors),
      primaryColor: MfColor.brand,
      dividerColor: colors.divider,
      splashColor: colors.textPrimary.withValues(alpha: 0.06),
      highlightColor: colors.textPrimary.withValues(alpha: 0.04),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: colors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
          side: BorderSide(color: colors.border),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.base,
        ),
        hintStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colors.textTertiary,
        ),
        errorStyle: const TextStyle(
          fontFamily: AppText.family,
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: MfColor.danger,
        ),
        counterStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 11,
          color: colors.textTertiary,
        ),
        border: _fieldBorder(colors.borderStrong),
        enabledBorder: _fieldBorder(colors.borderStrong),
        disabledBorder: _fieldBorder(colors.divider),
        focusedBorder: _fieldBorder(MfColor.brand, width: 1.5),
        errorBorder: _fieldBorder(MfColor.danger),
        focusedErrorBorder: _fieldBorder(MfColor.danger, width: 1.5),
      ),

      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle(colors)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(colors).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled) ? colors.surfaceAlt : MfColor.brand),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled) ? colors.textTertiary : ColorsPalette.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(colors).copyWith(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(colors.textPrimary),
          side: WidgetStatePropertyAll(BorderSide(color: colors.borderStrong)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MfColor.brand,
          textStyle: const TextStyle(
            fontFamily: AppText.family,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.surface,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
        ),
        dragHandleColor: colors.border,
        dragHandleSize: const Size(36, 4),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        titleTextStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: colors.textPrimary,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceAlt,
        selectedColor: colors.selectedSurface,
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        shape: const StadiumBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surfaceAlt : MfColor.ink,
        contentTextStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? colors.textPrimary : ColorsPalette.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        elevation: 0,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: MfColor.brand,
        selectionColor: MfColor.brand.withValues(alpha: 0.18),
        selectionHandleColor: MfColor.brand,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MfColor.brand,
        strokeWidth: 2.5,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? ColorsPalette.white : colors.surface),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? MfColor.brand : colors.surfaceAlt),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.transparent : colors.border),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ButtonStyle _buttonStyle(MapFoodColors colors) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Spacing.xl),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: AppText.family,
          fontSize: 15,
          height: 20 / 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? colors.surfaceAlt : null),
      foregroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? colors.textTertiary : null),
    );
  }

  static TextTheme _textTheme(MapFoodColors colors) {
    TextStyle base(double size, double lineHeight, FontWeight weight,
            {double spacing = 0, Color? color}) =>
        TextStyle(
          fontFamily: AppText.family,
          fontSize: size,
          height: lineHeight / size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color ?? colors.textPrimary,
        );

    return TextTheme(
      displayLarge: base(32, 38, FontWeight.w700, spacing: -1.0),
      displayMedium: base(28, 34, FontWeight.w700, spacing: -0.8),
      displaySmall: base(24, 30, FontWeight.w700, spacing: -0.6),
      headlineMedium: base(24, 30, FontWeight.w700, spacing: -0.6),
      headlineSmall: base(20, 26, FontWeight.w600, spacing: -0.4),
      titleLarge: base(20, 26, FontWeight.w600, spacing: -0.4),
      titleMedium: base(16, 22, FontWeight.w600, spacing: -0.2),
      titleSmall: base(15, 20, FontWeight.w600),
      bodyLarge: base(16, 24, FontWeight.w400),
      bodyMedium: base(15, 22, FontWeight.w400),
      bodySmall: base(13, 18, FontWeight.w400, color: colors.textSecondary),
      labelLarge: base(15, 20, FontWeight.w600),
      labelMedium: base(12, 16, FontWeight.w500, color: colors.textSecondary),
      labelSmall: base(11, 14, FontWeight.w600, spacing: 0.6, color: colors.textSecondary),
    );
  }
}
