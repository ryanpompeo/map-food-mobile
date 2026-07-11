import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Representa como uma categoria deve ser desenhada nos filtros: uma foto
/// ilustrativa (`assets/images/category/`) quando existe, ou um ícone
/// genérico como fallback para categorias que a API retorne sem imagem própria.
class CategoryVisual {
  final String? assetPath;
  final IconData fallbackIcon;

  const CategoryVisual({this.assetPath, this.fallbackIcon = LucideIcons.utensils});
}

const Map<String, String> _categoryAssets = {
  'bebida': 'assets/images/category/bebida.png',
  'bebidas': 'assets/images/category/bebida.png',
  'doce': 'assets/images/category/doces.png',
  'doces': 'assets/images/category/doces.png',
  'espetinho': 'assets/images/category/espetinho.png',
  'espetinhos': 'assets/images/category/espetinho.png',
  'gelato': 'assets/images/category/gelatos.png',
  'gelatos': 'assets/images/category/gelatos.png',
  'sorvete': 'assets/images/category/gelatos.png',
  'sorvetes': 'assets/images/category/gelatos.png',
  'hamburguer': 'assets/images/category/hamburguer.png',
  'hamburgueres': 'assets/images/category/hamburguer.png',
  'lanche': 'assets/images/category/hamburguer.png',
  'lanches': 'assets/images/category/hamburguer.png',
  'milho': 'assets/images/category/milho.png',
  'pastel': 'assets/images/category/pastel.png',
  'pasteis': 'assets/images/category/pastel.png',
};

const String _withDiacritics = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const String _withoutDiacritics = 'aaaaaeeeeiiiiooooouuuucn';

String _normalize(String value) {
  var result = value.toLowerCase().trim();
  for (var i = 0; i < _withDiacritics.length; i++) {
    result = result.replaceAll(_withDiacritics[i], _withoutDiacritics[i]);
  }
  return result;
}

CategoryVisual categoryVisualFor(String categoriaNome) {
  final assetPath = _categoryAssets[_normalize(categoriaNome)];
  if (assetPath != null) return CategoryVisual(assetPath: assetPath);
  return const CategoryVisual();
}
