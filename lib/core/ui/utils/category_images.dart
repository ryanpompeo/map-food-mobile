const Map<String, String> categoriaImagens = {
  'Lanches e Hot Dogs': 'assets/images/category/hamburguer.png',
  'Espetinhos': 'assets/images/category/espetinho.png',
  'Pizzas': 'assets/images/category/pizza.png',
  'Pastel e Salgados': 'assets/images/category/pastel.png',
  'Marmitas e Comida Caseira': 'assets/images/category/marmita.png',
  'Padaria e Bolos': 'assets/images/category/bolos.png',
  'Doces e Sobremesas': 'assets/images/category/doces.png',
  'Gelatos e Açaí': 'assets/images/category/gelatos.png',
  'Milho e Pamonha': 'assets/images/category/milho.png',
  'Pipoca': 'assets/images/category/popcorn.png',
  'Bebidas': 'assets/images/category/bebida.png',
  'Food Truck': 'assets/images/category/food_truck.png',

  'Produtos Artesanais': 'assets/images/category/artesanal.png',
  'Vestuario e Acessórios': 'assets/images/category/vestuario.png',
  'Vestuário': 'assets/images/category/vestuario.png',
  'Pet Shop': 'assets/images/category/petshop.png',
  'Serviços': 'assets/images/category/services.png',
  'Outros': 'assets/images/category/more.png',
};

String? imagemParaCategoria(String nome) => categoriaImagens[nome];
