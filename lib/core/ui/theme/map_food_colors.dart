import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

/// Tokens de cor do Design System que precisam variar entre claro/escuro e
/// não têm equivalente direto no [ColorScheme] do Material (fundo de tela,
/// superfície de card, texto primário/secundário, borda/divisor, ícone
/// neutro). Telas que hoje leem [ColorsPalette] ou hex literal direto
/// (`Colors.white`, `Colors.grey.shade200`) devem migrar para ler daqui, via
/// `context.mapColors` — ver [MapFoodColorsX] no fim deste arquivo.
///
/// Cores de marca/ação (`ColorsPalette.redComponents`, o CTA preto sólido de
/// "Sair", o verde de sucesso do toast) ficam de fora de propósito: são
/// constantes de identidade visual que devem parecer as mesmas nos dois
/// temas, não "superfícies" que precisam se adaptar ao brightness.
@immutable
class MapFoodColors extends ThemeExtension<MapFoodColors> {
  final Color mainBackground;
  final Color cardSurface;
  final Color primaryText;
  final Color secondaryText;

  /// Linhas de divisor e bordas sutis de card/empty-state. Consolida o que
  /// hoje aparece espalhado como `Colors.grey.shade100`/`shade200`.
  final Color border;

  /// Ícones neutros/inativos (ex: o sol/lua do seletor de tema, o ícone
  /// padrão de um item de lista). Consolida `Colors.grey.shade500`/`shade600`.
  final Color iconMuted;

  const MapFoodColors({
    required this.mainBackground,
    required this.cardSurface,
    required this.primaryText,
    required this.secondaryText,
    required this.border,
    required this.iconMuted,
  });

  static const light = MapFoodColors(
    mainBackground: ColorsPalette.whiteBackground,
    cardSurface: ColorsPalette.white,
    primaryText: ColorsPalette.blackDetails,
    secondaryText: ColorsPalette.greyText,
    border: Color(0xFFEEEEEE), // == Colors.grey.shade200
    iconMuted: Color(0xFF757575), // == Colors.grey.shade600 (== ColorsPalette.greyText)
  );

  static const dark = MapFoodColors(
    // mainBackground/cardSurface iguais aos hex já usados em
    // AppTheme._base para scaffoldBackgroundColor/fieldFillColor no tema
    // escuro — centralizado aqui pra não divergir entre os dois lugares.
    mainBackground: Color(0xFF121212),
    cardSurface: Color(0xFF1E1E1E),
    primaryText: Color(0xFFF5F5F5),
    secondaryText: ColorsPalette.greyDetails,
    border: Color(0xFF2A2A2A),
    iconMuted: Color(0xFFB3B3B3),
  );

  @override
  MapFoodColors copyWith({
    Color? mainBackground,
    Color? cardSurface,
    Color? primaryText,
    Color? secondaryText,
    Color? border,
    Color? iconMuted,
  }) {
    return MapFoodColors(
      mainBackground: mainBackground ?? this.mainBackground,
      cardSurface: cardSurface ?? this.cardSurface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      border: border ?? this.border,
      iconMuted: iconMuted ?? this.iconMuted,
    );
  }

  @override
  MapFoodColors lerp(ThemeExtension<MapFoodColors>? other, double t) {
    if (other is! MapFoodColors) return this;
    return MapFoodColors(
      mainBackground: Color.lerp(mainBackground, other.mainBackground, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
    );
  }
}

/// Syntax sugar para não repetir `Theme.of(context).extension<MapFoodColors>()!`
/// em toda view. O `!` é seguro aqui porque [MapFoodColors] é sempre
/// registrada em `AppTheme.light` e `AppTheme.dark` — ver app_theme.dart.
extension MapFoodColorsX on BuildContext {
  MapFoodColors get mapColors => Theme.of(this).extension<MapFoodColors>()!;
}
