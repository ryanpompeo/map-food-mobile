/// Arte 3D de cada categoria de loja — mapeamento por nome, na mesma linha de
/// `core/ui/utils/category_icons.dart` (a API não tem campo de imagem pra
/// categoria).
///
/// Quem não tem entrada aqui devolve `null` e cai no ícone da paleta — nunca
/// num placeholder quebrado ou num quadrado vazio.
///
/// Todas as artes são PNG 1024×1024 com fundo transparente e bastante margem no
/// canvas (o objeto ocupa pouco mais da metade da largura), então elas precisam
/// ser desenhadas maiores que o ícone que substituem para ter o mesmo peso
/// visual dentro do círculo colorido.
const Map<String, String> categoriaImagens = {
  'Lanches e Hot Dogs': 'assets/images/category/hamburguer.png',
  'Espetinhos': 'assets/images/category/espetinho.png',
  'Pastel e Salgados': 'assets/images/category/pastel.png',
  'Doces e Sobremesas': 'assets/images/category/doces.png',
  'Bebidas': 'assets/images/category/bebida.png',
  'Gelatos e Açaí': 'assets/images/category/gelatos.png',
  'Milho e Pamonha': 'assets/images/category/milho.png',
  'Pipoca': 'assets/images/category/popcorn.png',
  'Produtos Artesanais': 'assets/images/category/artesanal.png',
  'Food Truck': 'assets/images/category/food_truck.png',
  'Outros': 'assets/images/category/more.png',
};

/// Caminho da arte da categoria, ou `null` quando ela ainda não tem uma.
String? imagemParaCategoria(String nome) => categoriaImagens[nome];
