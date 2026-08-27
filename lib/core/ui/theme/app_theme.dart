import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// ThemeData de claro/escuro do app. [ThemeController] só escolhe QUAL destes
/// dois usar; a definição visual de cada um vive só aqui.
///
/// ## O que mudou na v2
///
/// - **Inter** no lugar de Poppins, empacotada em `assets/fonts/` em vez de
///   baixada em runtime pelo `google_fonts` (sem download no primeiro launch,
///   sem flash de fonte trocando, funciona offline). É a mesma fonte da web
///   (`mapfood-web/tailwind.config.ts`), então as duas pontas do produto
///   passam a falar a mesma língua.
/// - **`ColorScheme` escrito à mão** em vez de `fromSeed`. O algoritmo do
///   Material You deriva a paleta inteira a partir do vermelho da marca e
///   tinge tudo — superfície, borda, container — de rosa. Um sistema com cor
///   de marca forte precisa de neutros verdadeiros; a cor entra por decisão,
///   não por derivação.
/// - **Geometria**: campo com raio 12 (era pílula), superfícies com os raios
///   de [Radii], nenhuma elevação em botão.
class AppTheme {
  AppTheme._();

  static final ThemeData light = _base(
    brightness: Brightness.light,
    colors: MapFoodColors.light,
  );

  static final ThemeData dark = _base(
    brightness: Brightness.dark,
    colors: MapFoodColors.dark,
  );

  static ThemeData _base({
    required Brightness brightness,
    required MapFoodColors colors,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: MfColor.brand,
      onPrimary: ColorsPalette.white,
      // Container de marca: fundo suave de chip selecionado e badge.
      primaryContainer: isDark ? MfColor.brandSurfaceDark : MfColor.brandSurface,
      onPrimaryContainer: MfColor.brand,
      // "Secundário" aqui é o neutro forte da marca (o preto azulado), que é
      // o que o app usa em CTA neutro e pin de mapa.
      secondary: isDark ? colors.textPrimary : MfColor.ink,
      onSecondary: isDark ? MfColor.ink : ColorsPalette.white,
      secondaryContainer: colors.surfaceAlt,
      onSecondaryContainer: colors.textPrimary,
      error: MfColor.danger,
      onError: ColorsPalette.white,
      errorContainer: isDark ? MfColor.dangerSurfaceDark : MfColor.dangerSurface,
      onErrorContainer: MfColor.danger,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surfaceAlt,
      surfaceContainerHigh: colors.surfaceAlt,
      surfaceContainerHighest: colors.surfaceAlt,
      onSurfaceVariant: colors.textSecondary,
      // No Material 3 `outline` é o traço que identifica um componente e
      // `outlineVariant` o decorativo — mesmo par de `borderStrong`/`border`.
      outline: colors.borderStrong,
      outlineVariant: colors.border,
      shadow: ColorsPalette.black,
      scrim: colors.overlay,
      inverseSurface: isDark ? colors.textPrimary : MfColor.ink,
      onInverseSurface: isDark ? MfColor.ink : ColorsPalette.white,
      inversePrimary: MfColor.brand,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      // Registra o MapFoodColors correspondente pra esta brightness — é o
      // que faz `context.mapColors` devolver os tokens certos em cada tema.
      extensions: <ThemeExtension<dynamic>>[colors],

      // Material 3 tinge superfícies com a cor primária conforme a elevação
      // ("surface tint"). Com um vermelho forte de marca isso deixa card e
      // app bar rosados — desligado aqui e via surfaceTintColor nos temas
      // de componente abaixo.
      applyElevationOverlayColor: false,

      textTheme: _textTheme(colors),
      primaryColor: MfColor.brand,
      dividerColor: colors.divider,
      splashColor: colors.textPrimary.withValues(alpha: 0.06),
      highlightColor: colors.textPrimary.withValues(alpha: 0.04),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: colors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
          side: BorderSide(color: colors.border),
        ),
      ),

      // Campo de formulário: superfície rebaixada, raio 12, rótulo por fora
      // (ver AppFormField). A borda só ganha cor e espessura no foco — em
      // repouso ela existe apenas para separar o campo do fundo.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.base,
        ),
        hintStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colors.textTertiary,
        ),
        errorStyle: const TextStyle(
          fontFamily: AppText.family,
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: MfColor.danger,
        ),
        counterStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 11,
          color: colors.textTertiary,
        ),
        // `borderStrong`, não `border`: o campo tem fundo `surfaceAlt`, que
        // rende só 1,07:1 contra o fundo da tela — a borda é literalmente a
        // única coisa que diz onde o campo começa e termina, então ela carrega
        // informação e precisa dos 3:1 do WCAG 1.4.11.
        border: _fieldBorder(colors.borderStrong),
        enabledBorder: _fieldBorder(colors.borderStrong),
        // Desabilitado segue fraco de propósito: componente inativo é isento
        // (WCAG 1.4.3) e o apagamento é justamente o que comunica o estado.
        disabledBorder: _fieldBorder(colors.divider),
        focusedBorder: _fieldBorder(MfColor.brand, width: 1.5),
        errorBorder: _fieldBorder(MfColor.danger),
        focusedErrorBorder: _fieldBorder(MfColor.danger, width: 1.5),
      ),

      // Botões: altura 52, raio 16, sem elevação. Profundidade no sistema vem
      // de superfície e sombra de container, nunca de botão levantado.
      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle(colors)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(colors).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled) ? colors.surfaceAlt : MfColor.brand),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled) ? colors.textTertiary : ColorsPalette.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(colors).copyWith(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(colors.textPrimary),
          // Botão outline é só contorno: sem fundo próprio, a borda é o botão.
          side: WidgetStatePropertyAll(BorderSide(color: colors.borderStrong)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MfColor.brand,
          textStyle: const TextStyle(
            fontFamily: AppText.family,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.surface,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
        ),
        dragHandleColor: colors.border,
        dragHandleSize: const Size(36, 4),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        titleTextStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: colors.textPrimary,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceAlt,
        selectedColor: colors.selectedSurface,
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        shape: const StadiumBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surfaceAlt : MfColor.ink,
        contentTextStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? colors.textPrimary : ColorsPalette.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        elevation: 0,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: MfColor.brand,
        selectionColor: MfColor.brand.withValues(alpha: 0.18),
        selectionHandleColor: MfColor.brand,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MfColor.brand,
        // Traço fino: o padrão do Material (4px) fica pesado ao lado de
        // tipografia e ícones de traço leve.
        strokeWidth: 2.5,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? ColorsPalette.white : colors.surface),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? MfColor.brand : colors.surfaceAlt),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.transparent : colors.border),
      ),

      // Swipe-to-go-back nativo nas duas plataformas (mesma decisão do
      // appPageRoute, aplicada também às rotas nomeadas).
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Campo com raio 12. Houve uma tentativa de levar tudo para cápsula, por
  /// "coerência de família" com a busca; na tela, o formulário ficou pior —
  /// campo em cápsula lê como chip, e uma coluna de cápsulas empilhadas perde
  /// a leitura de bloco que o raio 12 dá. A cápsula ficou só onde ela é a
  /// forma certa: a **busca** (ver `SearchFieldWidget`), que é um controle
  /// solto, não um item de formulário.
  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ButtonStyle _buttonStyle(MapFoodColors colors) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      // Size(0, 52) e **não** Size.fromHeight(52): `fromHeight` produz
      // `Size(double.infinity, 52)`, ou seja, largura mínima infinita. Num
      // botão dentro de `Row` (o par Cancelar/Confirmar dos diálogos, por
      // exemplo) isso vira `BoxConstraints forces an infinite width` e
      // derruba o layout inteiro — o diálogo simplesmente não aparece.
      // Quem quiser largura total pede explicitamente (ver `AppButton.expand`).
      minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Spacing.xl),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: AppText.family,
          fontSize: 15,
          height: 20 / 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Desabilitado como superfície apagada, não como opacidade no widget
      // inteiro: baixar a opacidade apaga a borda junto e deixa o botão
      // "fantasma" em vez de claramente inativo.
      backgroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? colors.surfaceAlt : null),
      foregroundColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? colors.textTertiary : null),
    );
  }

  /// TextTheme derivado da mesma escala de [AppText] — é o que garante que um
  /// `Text` sem estilo explícito já nasça com a tipografia certa.
  static TextTheme _textTheme(MapFoodColors colors) {
    TextStyle base(double size, double lineHeight, FontWeight weight,
            {double spacing = 0, Color? color}) =>
        TextStyle(
          fontFamily: AppText.family,
          fontSize: size,
          height: lineHeight / size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color ?? colors.textPrimary,
        );

    return TextTheme(
      displayLarge: base(32, 38, FontWeight.w700, spacing: -1.0),
      displayMedium: base(28, 34, FontWeight.w700, spacing: -0.8),
      displaySmall: base(24, 30, FontWeight.w700, spacing: -0.6),
      headlineMedium: base(24, 30, FontWeight.w700, spacing: -0.6),
      headlineSmall: base(20, 26, FontWeight.w600, spacing: -0.4),
      titleLarge: base(20, 26, FontWeight.w600, spacing: -0.4),
      titleMedium: base(16, 22, FontWeight.w600, spacing: -0.2),
      titleSmall: base(15, 20, FontWeight.w600),
      bodyLarge: base(16, 24, FontWeight.w400),
      bodyMedium: base(15, 22, FontWeight.w400),
      bodySmall: base(13, 18, FontWeight.w400, color: colors.textSecondary),
      labelLarge: base(15, 20, FontWeight.w600),
      labelMedium: base(12, 16, FontWeight.w500, color: colors.textSecondary),
      labelSmall: base(11, 14, FontWeight.w600, spacing: 0.6, color: colors.textSecondary),
    );
  }
}
