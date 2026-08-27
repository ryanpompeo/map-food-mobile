import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/glass_container.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

class BottomBarItem {
  final IconData icon;

  /// Nome da aba para o leitor de tela. Obrigatório: os itens são icon-only,
  /// então sem ele a navegação principal do app é anunciada como um punhado de
  /// botões sem nome — e era exatamente esse o estado antes.
  final String label;

  const BottomBarItem(this.icon, this.label);
}

/// Bottom bar flutuante em glass, compartilhada entre guest/consumer/merchant
/// — só a lista de ícones muda entre os três papéis.
class AppBottomBar extends StatelessWidget {
  final List<BottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final double itemSpacing;

  // Área de toque de cada item (56x56, padrão ergonômico Material/Apple) e
  // diâmetro do indicador de seleção que desliza por trás dos ícones.
  static const double _itemSize = 56.0;
  static const double _indicatorSize = 48.0;

  /// Padding vertical interno da cápsula (vale nos dois temas: `GlassContainer`
  /// no claro, container sólido no escuro) e margem entre a barra e a borda
  /// inferior da tela.
  static const double _paddingVertical = 8.0;
  static const double _margemInferior = 32.0;

  /// Espaço que a barra ocupa no rodapé, da borda da tela ao topo da cápsula.
  ///
  /// Quem desenha conteúdo por baixo dela (painel da home, listas das telas
  /// do comerciante, barras de ação) reserva **isto** no rodapé, em vez de
  /// repetir um número mágico por arquivo — era assim que a barra acabava
  /// cobrindo conteúdo: cada tela chutava a própria folga, e o chute mais
  /// comum (92) ignorava o padding interno da cápsula.
  ///
  /// 56 do item + 16 de padding + 32 de margem + 4 de folga para a borda de
  /// 1px e a sombra.
  static const double reservedSpace =
      _itemSize + (_paddingVertical * 2) + _margemInferior + 4.0;

  const AppBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.itemSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _margemInferior, left: 24.0, right: 24.0),
        child: isDark
            ? _buildSolidDark(context)
            // Tema claro igual era antes do experimento de badge de alto
            // contraste: indicador claro (cardSurface) + ícone vermelho.
            : GlassContainer(child: _buildContent(indicatorColor: context.mapColors.cardSurface)),
      ),
    );
  }

  // Tema escuro: sem o vidro fosco (branco translúcido não lê bem sobre
  // fundo escuro) — superfície sólida cinza, distinta do fundo do app
  // (context.mapColors.cardSurface já é o tom "elevado" do tema escuro).
  Widget _buildSolidDark(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: _paddingVertical),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      // Indicador claro sobre a barra escura — mesmo alto contraste do lado
      // claro, espelhado: branco sólido em vez de um tom escuro próximo do
      // cardSurface da barra (que ficava quase invisível).
      child: _buildContent(indicatorColor: ColorsPalette.white),
    );
  }

  Widget _buildContent({required Color indicatorColor}) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: _itemSize,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Indicador único que desliza de um ícone pro outro — em vez
              // de cada item ligar/desligar seu próprio fundo, só um deles
              // se move, o que lê como transição contínua ao trocar de aba.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: selectedIndex * (_itemSize + itemSpacing),
                top: 0,
                child: SizedBox(
                  width: _itemSize,
                  height: _itemSize,
                  child: Center(
                    child: SizedBox(
                      width: _indicatorSize,
                      height: _indicatorSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: indicatorColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) SizedBox(width: itemSpacing),
                    _NavItem(
                      icon: items[i].icon,
                      label: items[i].label,
                      isSelected: i == selectedIndex,
                      onTap: () => onItemTapped(i),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SemanticTapArea(
        label: label,
        selected: isSelected,
        onTap: onTap,
        // O indicador que desliza por trás do ícone já responde ao toque;
        // encolher o item junto brigaria com essa animação.
        pressFeedback: false,
        child: SizedBox(
          width: AppBottomBar._itemSize,
          height: AppBottomBar._itemSize,
          child: Center(
            // Claro: volta a ser o vermelho de marca sobre o indicador claro
            // (como era antes do experimento). Escuro: mantém o cinza mais
            // escuro sobre o indicador branco, que já tinha bom contraste.
            child: Icon(
              icon,
              size: 24.0,
              color: !isSelected
                  ? context.mapColors.iconMuted
                  : (Theme.of(context).brightness == Brightness.dark
                        ? ColorsPalette.greyComponents
                        : ColorsPalette.redComponents),
            ),
          ),
        ),
      ),
    );
  }
}
