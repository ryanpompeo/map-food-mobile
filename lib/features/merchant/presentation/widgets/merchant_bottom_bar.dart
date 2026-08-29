import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';

class MerchantBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const MerchantBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomBar(
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
      items: const [
        BottomBarItem(AppIcons.house, 'Início'),
        // "Buscar" saiu daqui e virou um push a partir do mapa: explorar
        // lojas alheias é secundário para quem administra a própria.
        BottomBarItem(AppIcons.chartLineUp, 'Estatísticas'),
        // "Ronda" e "Minha loja" eram duas abas para o mesmo objeto — o
        // toggle de aberta/fechada agora é o topo do painel de gestão, que é
        // onde ele sempre foi procurado.
        BottomBarItem(AppIcons.storefront, 'Minha loja'),
        BottomBarItem(AppIcons.user, 'Perfil'),
      ],
    );
  }
}
