const Map<String, String> categoriaImagens = {
  'Lanches': 'assets/images/category/snack.png',
  'Pastel': 'assets/images/category/pastry.png',
  'Espetinho': 'assets/images/category/espetinho.png',
  'Açaí': 'assets/images/category/gelatos.png',
  'Pizzas': 'assets/images/category/pizza.png',
  'Doces': 'assets/images/category/doces.png',
  'Hambúrguer': 'assets/images/category/burguer.png',
  'Hot Dog': 'assets/images/category/hotdog.png',

  'Comida Japonesa': 'assets/images/category/japonesa.png',
  'Crepe': 'assets/images/category/crepe.png',
  'Tapioca': 'assets/images/category/tapioca.png',
  'Comida Caseira': 'assets/images/category/marmita.png',
  'Pizza': 'assets/images/category/pizza.png',

  'Bebidas': 'assets/images/category/bebida.png',

  'Churros': 'assets/images/category/churros.png',
  'Salgados': 'assets/images/category/salgados.png',
};

String? imagemParaCategoria(String nome) => categoriaImagens[nome];
