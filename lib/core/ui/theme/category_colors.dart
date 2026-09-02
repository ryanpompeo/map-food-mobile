import 'package:flutter/material.dart';

const Map<String, Color> categoriaCores = {
  'Lanches e Hot Dogs': Color(0xFFF97316),
  'Espetinhos': Color(0xFFDC2626),
  'Pizzas': Color(0xFFC2410C),
  'Pastel e Salgados': Color(0xFFD97706),
  'Marmitas e Comida Caseira': Color(0xFF65A30D),
  'Padaria e Bolos': Color(0xFFA16207),
  'Doces e Sobremesas': Color(0xFFDB2777),
  'Gelatos e Açaí': Color(0xFF7C3AED),
  'Milho e Pamonha': Color(0xFF16A34A),
  'Pipoca': Color(0xFFCA8A04),
  'Bebidas': Color(0xFF2563EB),
  'Food Truck': Color(0xFF475569),

  'Produtos Artesanais': Color(0xFFB45309),
  'Vestuario e Acessórios': Color(0xFF0891B2),
  'Vestuário': Color(0xFF0891B2),
  'Pet Shop': Color(0xFF0D9488),
  'Serviços': Color(0xFF4F46E5),
  'Outros': Color(0xFF64748B),
};
const Color categoriaCorPadrao = Color(0xFF64748B);

Color corParaCategoria(String nome) => categoriaCores[nome] ?? categoriaCorPadrao;
