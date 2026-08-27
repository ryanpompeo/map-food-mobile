import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

/// Tokens de **superfície, conteúdo e traço** — tudo que precisa mudar entre
/// claro e escuro e não tem equivalente direto no `ColorScheme` do Material.
/// Lidos via `context.mapColors` (ver [MapFoodColorsX] no fim do arquivo).
///
/// Cor de marca e de significado (vermelho, preto da marca, estrela, sucesso)
/// **não** entram aqui: valem o mesmo nos dois temas e vivem em [MfColor].
///
/// ## A escala de neutros (v2)
///
/// Antes, no tema claro, `mainBackground` e `cardSurface` eram os dois branco
/// puro — um card não se distinguia do fundo, e a única separação possível
/// virava borda cinza em tudo. Agora são três degraus, que é o que permite
/// hierarquia sem desenhar linha:
///
/// - [background] — o papel da tela
/// - [surface] — o que está sobre o papel (card, sheet, app bar)
/// - [surfaceAlt] — o que está "afundado" no papel (input, chip, skeleton)
///
/// Os neutros são cinzas de viés levemente azul, conversando com o
/// `#12172A` da marca. Nada de cinza tingido de vermelho, como no
/// `--border: 348 40% 85%` da web: borda colorida satura a tela e rouba
/// atenção do conteúdo.
@immutable
class MapFoodColors extends ThemeExtension<MapFoodColors> {
  /// Fundo da tela.
  final Color background;

  /// Superfície elevada sobre [background]: card, bottom sheet, app bar.
  final Color surface;

  /// Superfície rebaixada: campo de formulário, chip inativo, skeleton de
  /// carregamento. Um degrau de contraste em relação a [surface].
  final Color surfaceAlt;

  /// Scrim de modal/bottom sheet.
  final Color overlay;

  final Color textPrimary;
  final Color textSecondary;

  /// Placeholder, texto desabilitado, chevron de item de lista.
  final Color textTertiary;

  /// Traço **decorativo** de 1px: contorno de card, de sheet, de botão
  /// flutuante — casos em que o elemento já se identifica pela superfície e a
  /// borda só arremata a forma.
  ///
  /// Não atinge 3:1 de propósito (1,18:1 no claro): elevá-la a esse nível
  /// pintaria de cinza-médio o contorno de todo card do app. Quando a borda é
  /// **a única coisa** que delimita um controle — campo de formulário, chip
  /// inativo, botão outline —, use [borderStrong]: aí ela carrega informação e
  /// o 3:1 do WCAG 1.4.11 passa a valer.
  final Color border;

  /// Traço **funcional**: o contorno que identifica um controle. Cumpre 3:1
  /// contra as superfícies em que o app o desenha.
  final Color borderStrong;

  /// Linha entre itens de uma lista — mais fraca que [border] de propósito.
  final Color divider;

  /// Fundo do estado **selecionado** de um controle neutro: segmento ativo,
  /// chip escolhido, CTA de alto contraste.
  ///
  /// Inverte entre os temas, e é por isso que existe como token. No claro é
  /// o `#12172A` da marca; no escuro esse mesmo tom fica a um passo do fundo
  /// (`#0E0F12`) e o controle "selecionado" some — lê como um azul apagado
  /// em vez de um estado ativo. No escuro, portanto, o selecionado é claro,
  /// espelhando o mesmo contraste.
  final Color selectedSurface;

  /// Conteúdo sobre [selectedSurface].
  final Color onSelectedSurface;

  /// Vermelho da marca **como texto ou ícone sobre uma superfície do tema**.
  ///
  /// Existe porque `MfColor.brand` (`#D6011B`) rende só 3,28:1 sobre a
  /// superfície escura — reprova para texto. No claro é a cor de marca intacta;
  /// no escuro, uma versão clareada que preserva o matiz e alcança 4,5:1.
  ///
  /// Continue usando `MfColor.brand` quando o vermelho for **fundo** (CTA
  /// primário, badge): ali o par a medir é branco-sobre-vermelho, que já passa.
  final Color brandContent;

  /// Verde de sucesso como texto/ícone. Mesmo motivo de [brandContent]: o
  /// `MfColor.success` rende 3,37:1 sobre o branco e reprova no tema claro.
  final Color successContent;

  const MapFoodColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.selectedSurface,
    required this.onSelectedSurface,
    required this.brandContent,
    required this.successContent,
  });

  // ─────────────────── compatibilidade com os nomes antigos ───────────────────
  // O app tem ~360 leituras de `context.mapColors`. Trocar os valores por
  // dentro e manter os nomes antigos como apelidos deixa a fundação nova
  // entrar de uma vez, sem um mutirão de renomeação que não muda nada de
  // visual. Estes getters saem quando a migração dos lotes terminar.

  Color get mainBackground => background;
  Color get cardSurface => surface;
  Color get primaryText => textPrimary;
  Color get secondaryText => textSecondary;

  /// No sistema novo o ícone acompanha a cor do texto ao lado; ícone neutro
  /// é, por definição, [textSecondary].
  Color get iconMuted => textSecondary;

  // ─────────────────────────── contraste ───────────────────────────
  // Os valores de texto abaixo foram medidos contra a superfície mais clara
  // em que o app os desenha (`surfaceAlt`, #F3F4F5) — não contra o branco.
  // Medir contra o branco aprovaria tons que reprovam dentro de um campo ou
  // de um chip, que é justamente onde o texto fraco mais aparece.

  static const light = MapFoodColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    // `--branco-background: #F3F4F5` da web, reaproveitado como superfície
    // rebaixada em vez de fundo de tela.
    surfaceAlt: Color(0xFFF3F4F5),
    overlay: Color(0x6612172A), // ink @ 40%
    textPrimary: MfColor.ink, // 17,8:1
    // Era #6B7280 (4,39:1 sobre surfaceAlt — reprovava por pouco). Escurecido
    // além do mínimo de propósito: com o terciário subindo para 4,5:1, um
    // secundário no limite ficaria indistinguível dele e a hierarquia de
    // texto do app viraria um tom só.
    textSecondary: Color(0xFF4E535D), // 7,0:1
    // Era #9CA3AF — 2,54:1, o pior par da escala. É a cor do placeholder
    // ("Buscar comércios..."), que é conteúdo, não decoração.
    textTertiary: Color(0xFF6C7079), // 4,5:1
    border: Color(0xFFEAECEF),
    borderStrong: Color(0xFF8A8B8D), // 3,1:1
    divider: Color(0xFFF1F2F4),
    selectedSurface: MfColor.ink,
    onSelectedSurface: Color(0xFFFFFFFF),
    brandContent: MfColor.brand, // 5,4:1 — a marca passa intacta no claro
    successContent: Color(0xFF0F8743), // era #12A150 (3,37:1)
  );

  static const dark = MapFoodColors(
    // Viés azul sutil (em vez do #121212/#1E1E1E, que é o cinza padrão do
    // Material): puxa pro mesmo lado do #12172A da marca e lê como escolha,
    // não como default de framework.
    background: Color(0xFF0E0F12),
    surface: Color(0xFF17181C),
    surfaceAlt: Color(0xFF1E2025),
    overlay: Color(0x8F000000), // preto @ 56%
    textPrimary: Color(0xFFF5F6F7), // 16,4:1
    textSecondary: Color(0xFF9BA1AC), // 6,8:1 — já passava, mantido
    // Era #6B7280 (3,37:1 sobre surfaceAlt). No escuro o ajuste é clarear.
    textTertiary: Color(0xFF818793), // 4,5:1
    border: Color(0xFF2A2D34),
    borderStrong: Color(0xFF64666B), // 3,1:1
    divider: Color(0xFF212429),
    selectedSurface: Color(0xFFF5F6F7),
    onSelectedSurface: MfColor.ink,
    // `MfColor.brand` puro rende 3,28:1 sobre `surface` — reprova para texto.
    // Clareado o suficiente para 4,5:1 mantendo o matiz da marca.
    brandContent: Color(0xFFE24B5D),
    successContent: MfColor.success, // 5,3:1 — o verde passa intacto no escuro
  );

  @override
  MapFoodColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? overlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? selectedSurface,
    Color? onSelectedSurface,
    Color? brandContent,
    Color? successContent,
  }) {
    return MapFoodColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      overlay: overlay ?? this.overlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      onSelectedSurface: onSelectedSurface ?? this.onSelectedSurface,
      brandContent: brandContent ?? this.brandContent,
      successContent: successContent ?? this.successContent,
    );
  }

  @override
  MapFoodColors lerp(ThemeExtension<MapFoodColors>? other, double t) {
    if (other is! MapFoodColors) return this;
    return MapFoodColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      onSelectedSurface: Color.lerp(onSelectedSurface, other.onSelectedSurface, t)!,
      brandContent: Color.lerp(brandContent, other.brandContent, t)!,
      successContent: Color.lerp(successContent, other.successContent, t)!,
    );
  }
}

/// Syntax sugar para não repetir `Theme.of(context).extension<MapFoodColors>()!`
/// em toda view. O `!` é seguro aqui porque [MapFoodColors] é sempre
/// registrada em `AppTheme.light` e `AppTheme.dark` — ver app_theme.dart.
extension MapFoodColorsX on BuildContext {
  MapFoodColors get mapColors => Theme.of(this).extension<MapFoodColors>()!;
}
