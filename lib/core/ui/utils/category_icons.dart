import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';

/// Ícone representativo de cada categoria de loja — mapeamento por nome
/// porque a API não tem campo de ícone pra categoria. Compartilhado entre os
/// filtros de categoria da Search Page e os badges de categoria dos cards de
/// loja. Sem entrada aqui, cai no ícone padrão.
const Map<String, IconData> categoriaIcones = {
  'Lanches e Hot Dogs': AppIcons.hamburger,
  'Espetinhos': AppIcons.fire,
  'Pastel e Salgados': AppIcons.cookingPot,
  'Doces e Sobremesas': AppIcons.cake,
  'Bebidas': AppIcons.coffee,
  'Gelatos e Açaí': AppIcons.iceCream,
  'Milho e Pamonha': AppIcons.bowlFood,
  'Pipoca': AppIcons.popcorn,
  'Produtos Artesanais': AppIcons.gift,
  'Food Truck': AppIcons.truck,
  'Outros': AppIcons.dotsThree,
};
const IconData categoriaIconePadrao = AppIcons.forkKnife;

IconData iconeParaCategoria(String nome) => categoriaIcones[nome] ?? categoriaIconePadrao;
