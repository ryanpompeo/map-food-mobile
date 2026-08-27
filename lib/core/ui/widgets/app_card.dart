import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Quanto o card "sobe" da página.
enum AppCardElevation {
  /// Bloco dentro de uma tela que já rola: sem sombra, superfície rebaixada.
  /// Serve para agrupar conteúdo sem parecer um objeto solto.
  flat,

  /// Card em lista/grade. Sombra nível 1.
  raised,

  /// O que flutua sobre outro conteúdo — barra sobre o mapa, sheet, painel
  /// de filtro. Sombra nível 2.
  floating,
}

/// Container padrão de conteúdo do app.
///
/// Três coisas que este widget resolve e que costumavam ser refeitas (com
/// valores diferentes) em cada tela:
///
/// 1. **Superfície certa por elevação** — `flat` usa `surfaceAlt`, as outras
///    usam `surface`. É o degrau da escala de neutros que dá hierarquia sem
///    precisar desenhar linha em tudo.
/// 2. **Sombra por token**, nunca `BoxShadow` improvisado, e **desligada no
///    tema escuro** na variante `raised`: sobre fundo escuro a sombra não lê,
///    a separação vem do contraste entre `surface` e `background`.
/// 3. **Ripple contido no raio** — `InkWell` sem `borderRadius` casado com o
///    container espirra tinta para fora do canto arredondado.
class AppCard extends StatelessWidget {
  final Widget child;

  /// `null` deixa o card não clicável (sem ripple, sem área de toque).
  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;
  final double radius;
  final AppCardElevation elevation;

  /// Traço de 1px. Ligado por padrão no claro (onde a sombra é sutil demais
  /// para definir sozinha o limite do card).
  final bool bordered;

  /// Sobrescreve a cor de fundo — para casos legítimos como card sobre foto.
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Spacing.base),
    this.radius = Radii.xl,
    this.elevation = AppCardElevation.raised,
    this.bordered = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius);

    final background = color ??
        (elevation == AppCardElevation.flat ? colors.surfaceAlt : colors.surface);

    final shadows = switch (elevation) {
      AppCardElevation.flat => const <BoxShadow>[],
      AppCardElevation.raised => isDark ? const <BoxShadow>[] : AppElevation.soft,
      AppCardElevation.floating => AppElevation.floating,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius,
        border: bordered ? Border.all(color: colors.border) : null,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        // O clip fica no Material, não no DecoratedBox: recortar o container
        // externo cortaria a própria sombra junto.
        clipBehavior: Clip.antiAlias,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
