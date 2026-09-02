import 'package:flutter/material.dart';

class MfColor {
  const MfColor._();

  static const brand = Color(0xFFD6011B);

  static const brandPressed = Color(0xFFB00117);

  static const brandSurface = Color(0xFFFDECEE);
  static const brandSurfaceDark = Color(0x24D6011B);

  static const ink = Color(0xFF12172A);

  static const rating = Color(0xFFF5A623);

  static const ratingText = Color(0xFF8A5300);

  static const success = Color(0xFF12A150);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFD6011B);

  static const info = Color(0xFF1D4ED8);

  static const successFill = Color(0xFF0F7A3D);

  static const dangerFill = danger;

  static const infoFill = info;

  static const warningFill = warning;

  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerSurfaceDark = Color(0x24D6011B);

  static const userDot = Color(0xFF3B82F6);
}

class ColorsPalette {
  static const black = Colors.black;
  static const white = Colors.white;
  static const transparent = Colors.transparent;

  static const blackDetails = MfColor.ink;

  static const greyDetails = Color(0xFF9BA1AC);

  static const greyText = Color(0xFF4E535D);
  static const blackText = Colors.black;

  static const offWhite = Color(0xffF8FAFC);

  static const whiteBackground = Colors.white;

  static const blackComponents = MfColor.ink;
  static const redComponents = MfColor.brand;
  static const redComponentsIcon = Color(0xFFE33E33);
  static const greyComponents = Color.fromARGB(255, 59, 61, 64);

  static const redDegrade3 = Color(0xffC33B35);

  static const ratingStar = MfColor.rating;

  static const ratingStarText = MfColor.ratingText;
}
