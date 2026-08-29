import 'package:flutter/material.dart';


/// Cor de marca de cada categoria — pinta o círculo atrás da arte (a 12% de
/// opacidade) e o rótulo quando o filtro está ativo. As chaves espelham a
/// coluna `nome` da tabela `categoria`, igual a `utils/category_images.dart`.
///
/// Sem entrada aqui a categoria cai no cinza padrão. Isso não quebra nada, mas
/// deixa o filtro sem identidade — foi o que acontecia com as seis categorias
/// não-comida.
const Map<String, Color> categoriaCores = {
  // id 1..12 — comida
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

  // id 13..18 — não-comida
  'Produtos Artesanais': Color(0xFFB45309),
  // Ver a nota sobre os ids 14/16 duplicados em utils/category_images.dart.
  // As duas recebem a mesma cor de propósito: enquanto forem a mesma categoria
  // na prática, ficar com cores diferentes só confundiria quem filtra.
  'Vestuario e Acessórios': Color(0xFF0891B2),
  'Vestuário': Color(0xFF0891B2),
  'Pet Shop': Color(0xFF0D9488),
  'Serviços': Color(0xFF4F46E5),
  'Outros': Color(0xFF64748B),
};
const Color categoriaCorPadrao = Color(0xFF64748B);

Color corParaCategoria(String nome) => categoriaCores[nome] ?? categoriaCorPadrao;
