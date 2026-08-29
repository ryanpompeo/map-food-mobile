import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/glass_container.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

class BottomBarItem {
  final IconData icon;

  /// Nome da aba. Aparece sob o ícone **e** é o que o leitor de tela anuncia.
  final String label;

  const BottomBarItem(this.icon, this.label);
}

/// Bottom bar flutuante em glass, compartilhada entre guest/consumer/merchant
/// — só a lista de itens muda entre os três papéis.
///
/// A cápsula descolada da borda é o que deixa o mapa (a tela principal do app)
/// respirar por baixo dela: uma faixa opaca de ponta a ponta comeria uma tira
/// inteira da cartografia. No claro ela é vidro fosco sobre o que passa
/// embaixo; no escuro, superfície sólida — branco translúcido sobre fundo
/// escuro não lê.
///
/// **Com rótulo sob cada ícone.** Ícone sozinho obriga a decorar o significado
/// de cada símbolo para saber onde se está, e o preço disso (uma cápsula um
/// pouco mais alta) é menor que o da adivinhação. Por causa dos rótulos, o
/// indicador que desliza atrás do item selecionado é uma pílula que cobre
/// ícone + texto, e não mais o círculo de quando só havia o ícone.
class AppBottomBar extends StatelessWidget {
  final List<BottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  /// Altura do conteúdo de um item: 22 de ícone + 2 de respiro + ~15 de
  /// rótulo, com folga para o peso 700 do selecionado.
  static const double _itemHeight = 50.0;

  /// Largura de cada item. Fixa, e não uma divisão da tela: é ela que mantém a
  /// cápsula estreita e centralizada — esticada de margem a margem, a barra
  /// deixaria de flutuar e viraria uma faixa. 72 é o que comporta o rótulo
  /// mais longo dos três papéis ("Estatísticas") no teto de escala.
  static const double _itemWidth = 72.0;

  /// Padding interno da cápsula (vale nos dois temas) e margens até as bordas
  /// da tela.
  static const double _paddingVertical = 6.0;
  static const double _margemInferior = 20.0;
  static const double _margemLateral = 16.0;

  /// Teto de escala do rótulo. A cápsula é uma das superfícies que
  /// genuinamente não pode crescer: ela flutua sobre o conteúdo e esticá-la
  /// cobriria justamente o que emoldura. O teto é baixo porque o rótulo já
  /// nasce pequeno.
  static const double _tetoEscalaRotulo = 1.2;

  /// Espaço que a barra ocupa no rodapé, da borda da tela ao topo da cápsula,
  /// **incluindo** a área segura do aparelho.
  ///
  /// Quem desenha conteúdo por baixo dela (o mapa da home, as listas do
  /// comerciante) reserva isto no rodapé, em vez de repetir um número mágico
  /// por arquivo — era assim que a barra acabava cobrindo conteúdo: cada tela
  /// chutava a própria folga.
  static double spaceFor(BuildContext context) =>
      _itemHeight +
      (_paddingVertical * 2) +
      _margemInferior +
      4.0 + // borda de 1px + sombra
      MediaQuery.paddingOf(context).bottom;

  const AppBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        // A área segura entra como margem, não como `SafeArea` interno: a
        // cápsula precisa ficar *acima* da barra de gestos, não encostada
        // nela com o próprio padding inflado.
        padding: EdgeInsets.only(
          bottom: _margemInferior + MediaQuery.paddingOf(context).bottom,
          left: _margemLateral,
          right: _margemLateral,
        ),
        child: MaxTextScale(
          max: _tetoEscalaRotulo,
          child: isDark
              ? _buildSolidDark(context)
              : GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: _paddingVertical,
                  ),
                  // Indicador claro (cardSurface) + ícone e rótulo vermelhos.
                  child: _buildContent(indicatorColor: context.mapColors.cardSurface),
                ),
        ),
      ),
    );
  }

  // Tema escuro: sem o vidro fosco (branco translúcido não lê bem sobre fundo
  // escuro) — superfície sólida, distinta do fundo do app (`cardSurface` já é
  // o tom "elevado" do tema escuro).
  Widget _buildSolidDark(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: _paddingVertical),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      // Indicador claro sobre a barra escura — mesmo alto contraste do lado
      // claro, espelhado.
      child: _buildContent(indicatorColor: ColorsPalette.white),
    );
  }

  Widget _buildContent({required Color indicatorColor}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Normalmente `_itemWidth`, o que deixa a cápsula estreita e
        // centralizada pelo `Align` do build. Só num aparelho estreito demais
        // para os quatro itens do comerciante é que o item encolhe — melhor
        // apertar do que estourar a largura da tela.
        final larguraItem = constraints.maxWidth.isFinite
            ? (constraints.maxWidth / items.length).clamp(0.0, _itemWidth)
            : _itemWidth;
        return _buildBarra(indicatorColor: indicatorColor, larguraItem: larguraItem);
      },
    );
  }

  Widget _buildBarra({required Color indicatorColor, required double larguraItem}) {
    return SizedBox(
      height: _itemHeight,
      width: larguraItem * items.length,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Indicador único que desliza de um item pro outro — em vez de cada
          // item ligar/desligar seu próprio fundo, só um deles se move, o que
          // lê como transição contínua ao trocar de aba. Virou pílula (era um
          // círculo) porque agora precisa cobrir ícone **e** rótulo.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: selectedIndex * larguraItem,
            top: 0,
            child: SizedBox(
              width: larguraItem,
              height: _itemHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    color: indicatorColor,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++)
                SizedBox(
                  width: larguraItem,
                  child: _NavItem(
                    icon: items[i].icon,
                    label: items[i].label,
                    isSelected: i == selectedIndex,
                    onTap: () => onItemTapped(i),
                  ),
                ),
            ],
          ),
        ],
      ),
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
    // Claro: vermelho de marca sobre o indicador claro. Escuro: cinza escuro
    // sobre o indicador branco. Inativo: o cinza de ícone apagado, nos dois.
    // A diferença é cor **e** peso do rótulo — cor sozinha não basta para quem
    // não distingue matiz.
    final cor = !isSelected
        ? context.mapColors.iconMuted
        : (Theme.of(context).brightness == Brightness.dark
              ? ColorsPalette.greyComponents
              : ColorsPalette.redComponents);

    return RepaintBoundary(
      child: SemanticTapArea(
        label: label,
        selected: isSelected,
        onTap: onTap,
        // O indicador que desliza por trás do item já responde ao toque;
        // encolher o item junto brigaria com essa animação.
        pressFeedback: false,
        child: SizedBox(
          height: AppBottomBar._itemHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22.0, color: cor),
              const SizedBox(height: 2.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppText.caption(context).copyWith(
                    fontSize: 10.5,
                    height: 1.1,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
