import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';

/// Papel do botão na hierarquia da tela — não é "cor", é intenção.
///
/// Uma tela tem **no máximo um** [primary]. Se duas ações disputam o mesmo
/// destaque, nenhuma se destaca.
enum AppButtonVariant {
  /// Ação principal. Fundo de marca.
  primary,

  /// Ação alternativa de mesmo peso funcional (ex: "Cancelar" ao lado de
  /// "Salvar"). Superfície neutra.
  secondary,

  /// Ação terciária, ainda com forma de botão (ex: "Denunciar").
  outline,

  /// Ação de texto, sem caixa (ex: "ver tudo", "pular").
  ghost,

  /// Ação destrutiva (ex: "Excluir conta").
  danger,

  /// CTA neutro forte: preto sólido da marca. É o "Sair da conta" e o
  /// "Começar" sobre fundo claro, onde o vermelho seria agressivo demais.
  inverse,

  /// Botão **sobre uma superfície de marca** (card preto ou vermelho sólido):
  /// branco sólido com texto escuro. Não muda com o tema — a superfície que o
  /// contém também não muda.
  onBrand,
}

enum AppButtonSize {
  /// 44px — dentro de card, ao lado de outro botão, em barra de ação.
  sm,

  /// 52px — CTA de tela e de formulário.
  md,
}

/// Botão único do app.
///
/// Decisões que valem para todas as variantes:
///
/// - **`elevation: 0` sempre.** Profundidade no sistema vem de superfície e
///   sombra de container; botão levantado é vocabulário de Material 2.
/// - **Estado pressionado é um véu**, não outra cor. Trocar a cor de fundo no
///   toque faz o botão "piscar"; um overlay preserva a identidade.
/// - **Desabilitado é superfície apagada**, não opacidade no widget inteiro —
///   baixar a opacidade apaga a borda junto e deixa o botão fantasma.
/// - **Carregando preserva a largura**: o rótulo some, o botão não pula.
/// - **A altura é mínima, não fixa.** Com a fonte do sistema em 2×, um
///   `height: 52` cravado corta o rótulo pela metade. Aqui 52 é o piso: o
///   botão cresce com o texto, e o alvo de toque nunca fica *menor* que o
///   mínimo — só maior, o que não é problema.
class AppButton extends StatelessWidget {
  final String label;

  /// `null` desabilita o botão (mesma convenção do Flutter).
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Ícone à esquerda do rótulo. Use quando o ícone **acrescenta** informação
  /// ("Ver rota" + seta de navegação), não como decoração.
  final IconData? icon;

  /// Troca o rótulo por um spinner e bloqueia o toque.
  final bool loading;

  /// `true` (padrão) ocupa a largura disponível — o certo para CTA de tela e
  /// de formulário. `false` encolhe até o conteúdo, para botão em linha.
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Piso de altura (ver nota na descrição da classe), não altura fixa.
    final alturaMinima = size == AppButtonSize.md ? 52.0 : 44.0;
    final radius = size == AppButtonSize.md ? Radii.lg : Radii.md;
    // O ícone acompanha o texto: parado no tamanho original, ele viraria um
    // detalhe minúsculo ao lado de um rótulo que dobrou.
    final iconSize = escalaIcone(context, size == AppButtonSize.md ? 20.0 : 18.0);

    final (Color background, Color foreground, Color? borderColor) = switch (variant) {
      // Primário: o vermelho aqui é **fundo**, e o par branco-sobre-vermelho
      // rende 5,4:1 — passa. Por isso segue `MfColor.brand` puro, e não
      // `brandContent`, que é a variante para vermelho como texto/ícone.
      AppButtonVariant.primary => (MfColor.brand, ColorsPalette.white, null),
      AppButtonVariant.secondary => (colors.surfaceAlt, colors.textPrimary, null),
      // Sem fundo próprio, a borda é o que identifica o botão → `borderStrong`.
      AppButtonVariant.outline => (Colors.transparent, colors.textPrimary, colors.borderStrong),
      // Ghost é vermelho como **texto** sobre a superfície da tela: no escuro
      // o vermelho puro rende 3,28:1 e reprova.
      AppButtonVariant.ghost => (Colors.transparent, colors.brandContent, null),
      AppButtonVariant.danger => (
          isDark ? MfColor.dangerSurfaceDark : MfColor.dangerSurface,
          // Mesma correção do ghost: texto vermelho sobre superfície suave.
          colors.brandContent,
          null,
        ),
      // No tema escuro o "preto sólido" some no fundo: `selectedSurface`
      // inverte para uma superfície clara com texto escuro, mantendo o mesmo
      // contraste alto. É o mesmo par usado por chip e segmento ativos.
      AppButtonVariant.inverse => (
          colors.selectedSurface,
          colors.onSelectedSurface,
          null,
        ),
      AppButtonVariant.onBrand => (ColorsPalette.white, MfColor.ink, null),
    };

    // Véu do toque: claro sobre fundo escuro, escuro sobre fundo claro.
    final overlay = switch (variant) {
      AppButtonVariant.primary ||
      AppButtonVariant.inverse =>
        ColorsPalette.white.withValues(alpha: 0.14),
      _ => colors.textPrimary.withValues(alpha: 0.06),
    };

    final enabled = onPressed != null && !loading;

    return ConstrainedBox(
      // `minHeight` no lugar de `height`: o botão parte de 52/44 e cresce se o
      // rótulo precisar de mais. Com `height` fixo, o `Row` interno recebia
      // uma altura menor que a do texto e vazava por cima da borda.
      constraints: BoxConstraints(
        minHeight: alturaMinima,
        minWidth: expand ? double.infinity : 0,
      ),
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? colors.surfaceAlt : background,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? colors.textTertiary : foreground,
          ),
          overlayColor: WidgetStatePropertyAll(overlay),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: size == AppButtonSize.md ? Spacing.xl : Spacing.base),
          ),
          minimumSize: WidgetStatePropertyAll(Size(0, alturaMinima)),
          // Sem teto: o padrão do FilledButton limita a altura e reintroduziria
          // o corte que o `minHeight` acabou de resolver.
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor),
            ),
          ),
          // Sem tap target extra: a altura já cumpre o mínimo de 44/48px.
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: loading
            // O spinner acompanha a escala junto com o rótulo que ele
            // substitui — senão o botão encolhe de volta ao entrar em carga.
            ? SizedBox(
                height: escalaIcone(context, 18),
                width: escalaIcone(context, 18),
                child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize),
                    const SizedBox(width: Spacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      // Em escala alta, insistir em uma linha só troca o
                      // vazamento por "…" — o rótulo some do mesmo jeito.
                      // Soltando a segunda linha, o texto sobrevive e a caixa
                      // acompanha porque a altura virou mínima.
                      maxLines: linhasParaRotulo(context),
                      overflow: TextOverflow.ellipsis,
                      // AppText.button não carrega cor — quem resolve é o
                      // foregroundColor acima, que também trata o disabled.
                      style: AppText.button(context).copyWith(
                        fontSize: size == AppButtonSize.md ? 15 : 14,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
