import 'package:flutter/material.dart';


const Map<String, Color> categoriaCores = {
  'Lanches e Hot Dogs': Color(0xFFF97316),
  'Espetinhos': Color(0xFFDC2626),
  'Pastel e Salgados': Color(0xFFD97706),
  'Doces e Sobremesas': Color(0xFFDB2777),
  'Bebidas': Color(0xFF2563EB),
  'Gelatos e Açaí': Color(0xFF7C3AED),
  'Milho e Pamonha': Color(0xFF16A34A),
  'Pipoca': Color(0xFFCA8A04),
  'Produtos Artesanais': Color(0xFFB45309),
  'Food Truck': Color(0xFF475569),
  'Outros': Color(0xFF64748B),
};
const Color categoriaCorPadrao = Color(0xFF64748B);

Color corParaCategoria(String nome) => categoriaCores[nome] ?? categoriaCorPadrao;
