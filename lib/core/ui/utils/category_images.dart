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
/// As chaves espelham exatamente a coluna `nome` da tabela `categoria` — o
/// casamento é por string, então qualquer divergência de acento ou espaço faz a
/// categoria cair no ícone de fallback silenciosamente.
const Map<String, String> categoriaImagens = {
  // id 1..12 — comida
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

  // id 13..18 — não-comida
  'Produtos Artesanais': 'assets/images/category/artesanal.png',
  // ATENÇÃO: os ids 14 e 16 são a mesma coisa cadastrada duas vezes no banco
  // ("Vestuario e Acessórios", sem acento, e "Vestuário"). Enquanto as duas
  // linhas existirem, ambas precisam de entrada aqui — senão uma das duas
  // aparece sem arte, e qual delas depende de qual o comerciante escolheu.
  'Vestuario e Acessórios': 'assets/images/category/vestuario.png',
  'Vestuário': 'assets/images/category/vestuario.png',
  'Pet Shop': 'assets/images/category/petshop.png',
  'Serviços': 'assets/images/category/services.png',
  'Outros': 'assets/images/category/more.png',
};

/// Caminho da arte da categoria, ou `null` quando ela ainda não tem uma.
String? imagemParaCategoria(String nome) => categoriaImagens[nome];
