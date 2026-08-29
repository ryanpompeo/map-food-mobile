import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';

/// Ícone representativo de cada categoria de loja — mapeamento por nome
/// porque a API não tem campo de ícone pra categoria. Compartilhado entre os
/// filtros de categoria da Search Page e os badges de categoria dos cards de
/// loja. Sem entrada aqui, cai no ícone padrão.
/// As chaves espelham a coluna `nome` da tabela `categoria`, igual a
/// `utils/category_images.dart` e `theme/category_colors.dart` — os três mapas
/// precisam ser atualizados juntos quando o banco ganha uma categoria.
const Map<String, IconData> categoriaIcones = {
  // id 1..12 — comida
  'Lanches e Hot Dogs': AppIcons.hamburger,
  'Espetinhos': AppIcons.fire,
  'Pizzas': AppIcons.pizza,
  'Pastel e Salgados': AppIcons.cookingPot,
  'Marmitas e Comida Caseira': AppIcons.bowlSteam,
  'Padaria e Bolos': AppIcons.bread,
  'Doces e Sobremesas': AppIcons.cake,
  'Gelatos e Açaí': AppIcons.iceCream,
  'Milho e Pamonha': AppIcons.bowlFood,
  'Pipoca': AppIcons.popcorn,
  'Bebidas': AppIcons.coffee,
  'Food Truck': AppIcons.truck,

  // id 13..18 — não-comida
  'Produtos Artesanais': AppIcons.gift,
  // Ver a nota sobre os ids 14/16 duplicados em utils/category_images.dart.
  'Vestuario e Acessórios': AppIcons.tShirt,
  'Vestuário': AppIcons.tShirt,
  'Pet Shop': AppIcons.pawPrint,
  'Serviços': AppIcons.toolbox,
  'Outros': AppIcons.dotsThree,
};
const IconData categoriaIconePadrao = AppIcons.forkKnife;

IconData iconeParaCategoria(String nome) => categoriaIcones[nome] ?? categoriaIconePadrao;
