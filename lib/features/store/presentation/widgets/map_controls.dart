import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';

/// Botão circular flutuante sobre o mapa (ampliar, reduzir, centralizar,
/// travar rotação).
///
/// Superfície do tema + borda de 1px + sombra nível 2: a borda é o que garante
/// o recorte sobre um tile claro, e a sombra o que garante sobre um tile
/// escuro — sozinhas, cada uma some numa das duas situações.
///
/// ## Acessibilidade
///
/// - **48×48 sempre**, acima do mínimo de 44×44 recomendado pela Apple e do
///   48×48 do Material. Um dos dois botões de mapa que este widget substituiu
///   media 40×40.
/// - **[tooltip] é o rótulo do leitor de tela**, então ele descreve a ação
///   ("Ampliar o mapa"), não o desenho do ícone.
/// - **Desabilitado é anunciado**, não só apagado: com [onTap] nulo o
///   `InkWell` marca o nó como botão desabilitado, e o leitor de tela avisa em
///   vez de deixar a pessoa tocando num controle inerte.
/// - O ripple do `InkWell` é o feedback de pressão — e some se o dedo sair do
///   alvo antes de soltar, tornando visível que o toque foi cancelado.
class MapControlButton extends StatelessWidget {
  /// Alvo de toque. Ver nota de acessibilidade na descrição da classe.
  static const double diametro = 48.0;

  final IconData icon;

  /// Descreve a **ação**; vira o rótulo do leitor de tela.
  final String tooltip;

  /// `null` desabilita — o botão apaga e é anunciado como desabilitado.
  final VoidCallback? onTap;

  /// Estado ligado (ex: rotação travada): pinta com a cor de marca.
  final bool isActive;

  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final habilitado = onTap != null;

    final corIcone = isActive
        ? ColorsPalette.white
        : habilitado
            ? colors.textPrimary
            : colors.textTertiary;

    return Tooltip(
      message: tooltip,
      child: Container(
        width: diametro,
        height: diametro,
        decoration: BoxDecoration(
          color: isActive ? MfColor.brand : colors.surface,
          shape: BoxShape.circle,
          // Ativo: a borda vira a própria cor de marca, e o vermelho passa a
          // ocupar o círculo inteiro. Com `colors.border` fixo, o estado ligado
          // ficava com um anel escuro em volta — no tema escuro lia como uma
          // moldura preta cercando o botão, e não como um botão vermelho.
          border: Border.all(color: isActive ? MfColor.brand : colors.border),
          // Sem sombra quando desabilitado: um botão inerte não deve continuar
          // parecendo que flutua e convida ao toque.
          boxShadow: habilitado ? AppElevation.floating : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Icon(icon, size: AppIconSize.lg, color: corIcone),
          ),
        ),
      ),
    );
  }
}

/// Par ampliar/reduzir do mapa.
///
/// Existe porque o gesto de pinça é a **única** forma de mudar o zoom num mapa
/// sem estes botões, e ele exige dois dedos e um movimento contínuo preciso —
/// inviável com uma mão ocupada, com tremor ou mobilidade reduzida nas mãos, e
/// inalcançável para quem navega por leitor de tela, que não emite gestos de
/// múltiplos toques no canvas do mapa.
///
/// Os botões se apagam ao encostar nos limites de [StoreMapController], que
/// são os mesmos aplicados à pinça — assim os dois caminhos param no mesmo
/// lugar e o botão nunca fica clicável sem fazer nada.
class MapZoomControls extends StatelessWidget {
  final StoreMapController controller;

  const MapZoomControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.zoom,
      builder: (context, zoom, _) {
        // Anunciado nos dois botões: sem enxergar o mapa, "ampliei" não diz
        // nada — "nível 9 de 16" diz onde a pessoa está na escala.
        final nivel = 'Nível ${controller.nivelZoom} de ${controller.totalNiveisZoom}';

        return Semantics(
          container: true,
          value: nivel,
          child: Column(
            children: [
              MapControlButton(
                icon: AppIcons.plus,
                tooltip: 'Ampliar o mapa',
                onTap: zoom < StoreMapController.zoomMaximo ? controller.ampliar : null,
              ),
              const SizedBox(height: Spacing.sm),
              MapControlButton(
                icon: AppIcons.minus,
                tooltip: 'Reduzir o mapa',
                onTap: zoom > StoreMapController.zoomMinimo ? controller.reduzir : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
