import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';

const Map<String, IconData> categoriaIcones = {
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

  'Produtos Artesanais': AppIcons.gift,
  'Vestuario e Acessórios': AppIcons.tShirt,
  'Vestuário': AppIcons.tShirt,
  'Pet Shop': AppIcons.pawPrint,
  'Serviços': AppIcons.toolbox,
  'Outros': AppIcons.dotsThree,
};
const IconData categoriaIconePadrao = AppIcons.forkKnife;

IconData iconeParaCategoria(String nome) => categoriaIcones[nome] ?? categoriaIconePadrao;
