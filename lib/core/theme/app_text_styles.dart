import 'package:flutter/material.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class AppText {
  // Título de grande destaque
  static TextStyle display(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: 32.0, // Absoluto
      fontWeight: FontWeight.bold,
    );
  }

  // Título principal da página
  static TextStyle titulo(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
  }

  // Subtítulo / Seções
  static TextStyle subtitulo(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
    );
  }

  // Texto principal
  static TextStyle corpo(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16.0);
  }

  // Texto secundário
  static TextStyle secundario(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(fontSize: 14.0, color: Colors.grey[700]);
  }

  // Detalhes pequenos
  static TextStyle legenda(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(fontSize: 12.0, color: Colors.grey[600]);
  }

  // Texto de destaque
  static TextStyle destaque(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w800,
      color: ColorsPalette.redComponents,
      letterSpacing: 1.0,
    );
  }

  // Texto de botão
  static TextStyle botao(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: Colors.white,
    );
  }
}
