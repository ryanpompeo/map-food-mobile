import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AppText {
  const AppText._();

  static const family = 'Inter';

  static TextStyle display(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 32,
        height: 38 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: context.mapColors.textPrimary,
      );

  static TextStyle h1(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: context.mapColors.textPrimary,
      );

  static TextStyle h2(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: context.mapColors.textPrimary,
      );

  static TextStyle title(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: context.mapColors.textPrimary,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: context.mapColors.textPrimary,
      );

  static TextStyle bodyStrong(BuildContext context) =>
      body(context).copyWith(fontWeight: FontWeight.w600);

  static TextStyle secondary(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: context.mapColors.textSecondary,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: context.mapColors.textSecondary,
      );

  static TextStyle overline(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: context.mapColors.textSecondary,
      );

  static TextStyle button(BuildContext context) => const TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
      );

  static TextStyle metric(BuildContext context, {double size = 28}) => TextStyle(
        fontFamily: family,
        fontSize: size,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: context.mapColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle numeric(BuildContext context, {double size = 13}) => TextStyle(
        fontFamily: family,
        fontSize: size,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: context.mapColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle titulo(BuildContext context) => h1(context);

  static TextStyle subtitulo(BuildContext context) => h2(context);

  static TextStyle corpo(BuildContext context) => body(context);

  static TextStyle secundario(BuildContext context) => secondary(context);

  static TextStyle legenda(BuildContext context) => caption(context);

  static TextStyle destaque(BuildContext context) => caption(context).copyWith(
        fontWeight: FontWeight.w700,
        color: MfColor.brand,
        letterSpacing: 0.6,
      );

  static TextStyle botao(BuildContext context) =>
      button(context).copyWith(color: ColorsPalette.white);
}
