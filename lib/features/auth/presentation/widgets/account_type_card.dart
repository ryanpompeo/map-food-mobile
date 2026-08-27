import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';

/// Card de escolha do tipo de conta.
///
/// Antes os dois cards eram blocos sólidos de cor — um preto, um vermelho —
/// com sombra tingida da própria cor. Dois problemas: a tela virava dois
/// retângulos berrantes disputando atenção (sem dizer qual escolher), e
/// sombra colorida é o efeito que mais envelhece uma interface.
///
/// Agora um dos cards é [highlighted] (fundo escuro sólido, o neutro forte da
/// marca) e o outro é superfície neutra com traço de 1px. A hierarquia passa
/// a existir — a maioria das pessoas que chega aqui é consumidora — e o
/// vermelho fica reservado ao card secundário e ao seu CTA, o que mantém a
/// proporção 60/30/10 da paleta.
class AccountTypeCard extends StatelessWidget {
  final IconData icon;

  /// Rótulo pequeno acima do título ("PERFIL COMUM").
  final String eyebrow;

  final String title;
  final String description;
  final List<String> benefits;
  final String ctaLabel;
  final VoidCallback onTap;

  /// Card em destaque: fundo escuro sólido e CTA branco.
  final bool highlighted;

  const AccountTypeCard({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.benefits,
    required this.ctaLabel,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // O destaque só é um bloco escuro sólido no tema claro. No escuro, `ink`
    // encosta no fundo e o card fica chapado — lá o destaque vira o degrau
    // de superfície, que é o que significa "elevado" num tema escuro.
    final destaqueSolido = highlighted && !isDark;

    // Sobre o bloco sólido, tudo é branco em opacidades diferentes; fora
    // dele, a hierarquia normal de texto do tema.
    final Color titleColor = destaqueSolido ? ColorsPalette.white : colors.textPrimary;
    final Color bodyColor = destaqueSolido
        ? ColorsPalette.white.withValues(alpha: 0.72)
        : colors.textSecondary;
    final Color accent = destaqueSolido ? ColorsPalette.white : MfColor.brand;

    return AppCard(
      // O card inteiro é clicável, e o CTA repete a ação para quem procura
      // um botão — os dois levam ao mesmo lugar.
      onTap: onTap,
      // No claro, o destaque é o `ink` sólido da marca. No escuro esse mesmo
      // tom encosta no fundo e o card fica chapado, então o destaque passa a
      // ser o degrau de superfície (`surfaceAlt`) — que no tema escuro é
      // justamente o que significa "elevado".
      color: destaqueSolido ? MfColor.ink : null,
      elevation: highlighted && isDark ? AppCardElevation.flat : AppCardElevation.raised,
      bordered: !destaqueSolido,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Quadrado de ícone ao lado de texto: acompanha a escala, senão
              // vira um selo pequeno perdido ao lado de um título que dobrou.
              Container(
                height: escalaComTeto(context, 44),
                width: escalaComTeto(context, 44),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: destaqueSolido
                      ? ColorsPalette.white.withValues(alpha: 0.12)
                      : MfColor.brand.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Icon(icon, size: escalaIcone(context, AppIconSize.lg), color: accent),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  style: AppText.overline(context).copyWith(color: bodyColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          Text(title, style: AppText.h2(context).copyWith(color: titleColor)),
          const SizedBox(height: Spacing.xs),
          Text(
            description,
            style: AppText.secondary(context).copyWith(color: bodyColor, height: 1.45),
          ),
          const SizedBox(height: Spacing.lg),

          for (final benefit in benefits) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.checkCircle, size: AppIconSize.sm, color: accent),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      benefit,
                      style: AppText.secondary(context).copyWith(color: bodyColor, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Spacing.md),

          AppButton(
            label: ctaLabel,
            onPressed: onTap,
            size: AppButtonSize.sm,
            // Claro: branco sobre o bloco escuro. Escuro: o CTA de alto
            // contraste do tema — o card destacado continua sendo o que
            // "chama" mais, mesmo sem o bloco sólido.
            variant: switch ((highlighted, isDark)) {
              (true, false) => AppButtonVariant.onBrand,
              (true, true) => AppButtonVariant.inverse,
              _ => AppButtonVariant.primary,
            },
          ),
        ],
      ),
    );
  }
}
