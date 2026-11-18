import 'package:flutter/material.dart';

const Map<String, Color> categoriaCores = {
  'Lanches': Color(0xFFF97316),
  'Pastel': Color(0xFFD97706),
  'Espetinho': Color(0xFFDC2626),
  'Açaí': Color(0xFF7C3AED),
  'Pizzas': Color(0xFFC2410C),
  'Doces': Color(0xFFDB2777),
  'Hambúrguer': Color(0xFFEA580C),
  'Hot Dog': Color(0xFFE11D48),

  'Comida Japonesa': Color(0xFF0D9488),
  'Crepe': Color(0xFFCA8A04),
  'Tapioca': Color(0xFF0891B2),
  'Comida Caseira': Color(0xFF65A30D),
  'Pizza': Color(0xFFC2410C),

  'Bebidas': Color(0xFF2563EB),

  'Churros': Color(0xFFA16207),
  'Salgados': Color(0xFFB45309),
};
const Color categoriaCorPadrao = Color(0xFF64748B);

Color corParaCategoria(String nome) =>
    categoriaCores[nome] ?? categoriaCorPadrao;
