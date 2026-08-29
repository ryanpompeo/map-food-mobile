import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';

/// Card "imersivo": foto preenche o espaço inteiro, com um gradiente escuro
/// em três estágios por baixo e conteúdo (badges, texto) sobreposto —
/// extraído do `DestaqueCardWidget` original (carrossel "Perto de você") pra
/// virar o padrão visual reaproveitável do app: qualquer superfície que
/// precise de tratamento "hero" (capa da loja no dashboard, header da tela
/// de detalhe) usa este widget por baixo, em vez de reimplementar o
/// Stack+gradiente+ClipRRect toda vez.
class PhotoHeroCard extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final Widget? topLeft;
  final Widget? topRight;
  final Widget? bottomContent;

  /// Largura **lógica** com que o card aparece na tela — normalmente a largura
  /// do viewport, já que este é um card de tela cheia. Era `cacheWidth`, em
  /// pixels físicos, e cada chamador precisava lembrar de multiplicar pelo
  /// `devicePixelRatio`; a conta agora mora no [AppNetworkImage].
  final double? displayWidth;

  const PhotoHeroCard({
    super.key,
    required this.imageUrl,
    this.radius = 32.0,
    this.onTap,
    this.topLeft,
    this.topRight,
    this.bottomContent,
    this.displayWidth,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // RepaintBoundary própria pra a foto não repintar por causa de
          // interações no conteúdo sobreposto (favorito, scroll do carrossel
          // ao lado etc.).
          RepaintBoundary(
            child: Container(
              // Um tom abaixo do cardSurface, senão o placeholder fica
              // invisível contra o próprio fundo antes da imagem carregar.
              color: context.mapColors.mainBackground,
              // Sem `semanticLabel`: decorativa. O conteúdo textual sobreposto
              // já descreve o card pra leitor de tela.
              child: AppNetworkImage(
                path: imageUrl,
                displayWidth: displayWidth,
                fallbackIconSize: 48.0,
              ),
            ),
          ),
          // Gradiente em três estágios — fecha em preto quase opaco no
          // último stop, senão fotos claras/quentes vazam sob o texto.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 0.75, 1.0],
                  colors: [Colors.transparent, Color(0xB3000000), Color(0xF2000000)],
                ),
              ),
            ),
          ),
          if (topRight != null) Positioned(top: 10.0, right: 10.0, child: topRight!),
          if (topLeft != null) Positioned(top: 10.0, left: 10.0, child: topLeft!),
          if (bottomContent != null)
            Positioned(left: 14.0, right: 14.0, bottom: 12.0, child: bottomContent!),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: content);
  }
}

/// Badge translúcido flutuando sobre a foto de um [PhotoHeroCard] (nota,
/// status...) — vidro fosco escuro, mesmo estilo do `FavoriteButtonWidget`
/// em modo `frosted`.
class FrostedBadge extends StatelessWidget {
  final Widget child;
  const FrostedBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
      ),
      child: child,
    );
  }
}
