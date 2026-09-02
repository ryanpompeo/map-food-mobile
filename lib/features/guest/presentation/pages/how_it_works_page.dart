import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/widgets/how_it_works_scaffold.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  static const _passos = <HowItWorksStep>[
    (
      icone: AppIcons.mapPin,
      titulo: 'Explore o mapa',
      descricao: 'Os comércios abertos aparecem no mapa em tempo real, com a '
          'posição de agora — não a de ontem.',
    ),
    (
      icone: AppIcons.slidersHorizontal,
      titulo: 'Escolha sua categoria',
      descricao: 'Filtre por categoria e distância para encontrar exatamente o '
          'que deseja: de espetinhos e lanches até doces e açaí.',
    ),
    (
      icone: AppIcons.navigationArrow,
      titulo: 'Siga a rota',
      descricao: 'Toque em "Visualizar no mapa" para traçar a rota até o '
          'comércio escolhido e aproveite.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const HowItWorksScaffold(
      titulo: 'Como funciona',
      subtitulo: 'Descubra os melhores comércios e vendedores de rua da sua '
          'cidade em três passos.',
      passos: _passos,
      ctaLabel: 'Começar a explorar',
    );
  }
}
