import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

@immutable
class MapFoodColors extends ThemeExtension<MapFoodColors> {
  final Color background;

  final Color surface;

  final Color surfaceAlt;

  final Color overlay;

  final Color textPrimary;
  final Color textSecondary;

  final Color textTertiary;

  final Color border;

  final Color borderStrong;

  final Color divider;

  final Color selectedSurface;

  final Color onSelectedSurface;

  final Color brandContent;

  final Color successContent;

  const MapFoodColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.selectedSurface,
    required this.onSelectedSurface,
    required this.brandContent,
    required this.successContent,
  });

  Color get mainBackground => background;
  Color get cardSurface => surface;
  Color get primaryText => textPrimary;
  Color get secondaryText => textSecondary;

  Color get iconMuted => textSecondary;

  static const light = MapFoodColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF3F4F5),
    overlay: Color(0x6612172A),
    textPrimary: MfColor.ink,
    textSecondary: Color(0xFF4E535D),
    textTertiary: Color(0xFF6C7079),
    border: Color(0xFFEAECEF),
    borderStrong: Color(0xFF8A8B8D),
    divider: Color(0xFFF1F2F4),
    selectedSurface: MfColor.ink,
    onSelectedSurface: Color(0xFFFFFFFF),
    brandContent: MfColor.brand,
    successContent: Color(0xFF0F8743),
  );

  static const dark = MapFoodColors(
    background: Color(0xFF0E0F12),
    surface: Color(0xFF17181C),
    surfaceAlt: Color(0xFF1E2025),
    overlay: Color(0x8F000000),
    textPrimary: Color(0xFFF5F6F7),
    textSecondary: Color(0xFF9BA1AC),
    textTertiary: Color(0xFF818793),
    border: Color(0xFF2A2D34),
    borderStrong: Color(0xFF64666B),
    divider: Color(0xFF212429),
    selectedSurface: Color(0xFFF5F6F7),
    onSelectedSurface: MfColor.ink,
    brandContent: Color(0xFFE24B5D),
    successContent: MfColor.success,
  );

  @override
  MapFoodColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? overlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? selectedSurface,
    Color? onSelectedSurface,
    Color? brandContent,
    Color? successContent,
  }) {
    return MapFoodColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      overlay: overlay ?? this.overlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      onSelectedSurface: onSelectedSurface ?? this.onSelectedSurface,
      brandContent: brandContent ?? this.brandContent,
      successContent: successContent ?? this.successContent,
    );
  }

  @override
  MapFoodColors lerp(ThemeExtension<MapFoodColors>? other, double t) {
    if (other is! MapFoodColors) return this;
    return MapFoodColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      onSelectedSurface: Color.lerp(onSelectedSurface, other.onSelectedSurface, t)!,
      brandContent: Color.lerp(brandContent, other.brandContent, t)!,
      successContent: Color.lerp(successContent, other.successContent, t)!,
    );
  }
}

extension MapFoodColorsX on BuildContext {
  MapFoodColors get mapColors => Theme.of(this).extension<MapFoodColors>()!;
}
