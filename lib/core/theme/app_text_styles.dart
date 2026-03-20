import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppText {
  static TextStyle display(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: 32.sp,
      fontWeight: FontWeight.bold,
    );
  }

  // título principal da página
  static TextStyle titulo(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontSize: 26.sp,
      fontWeight: FontWeight.bold,
    );
  }

  // subtítulo / seções
  static TextStyle subtitulo(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    );
  }

  // texto principal
  static TextStyle corpo(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16.sp);
  }

  // texto secundário
  static TextStyle secundario(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(fontSize: 14.sp, color: Colors.grey[700]);
  }

  // detalhes pequenos
  static TextStyle legenda(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(fontSize: 12.sp, color: Colors.grey[600]);
  }

  // texto de destaque
  static TextStyle destaque(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w800,
      color: const Color(0xFFE33E33),
      letterSpacing: 1,
    );
  }

  // texto de botão
  static TextStyle botao(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: Colors.white,
    );
  }
}
