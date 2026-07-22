import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AppText {
  static TextStyle display(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle titulo(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle subtitulo(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle corpo(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16.0);
  }

  static TextStyle secundario(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 14.0,
      color: context.mapColors.secondaryText,
    );
  }

  static TextStyle legenda(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 12.0,
      color: context.mapColors.secondaryText,
    );
  }

  static TextStyle destaque(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w800,
      color: ColorsPalette.redComponents,
      letterSpacing: 1.0,
    );
  }

  static TextStyle botao(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: Colors.white,
    );
  }
}
