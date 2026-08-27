import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

/// O que um estado vazio comunica.
enum EmptyStateTone {
  /// Não há nada **ainda** — o app está funcionando, a pessoa é que não
  /// produziu conteúdo. É o caso mais comum (sem favoritos, sem avaliações)
  /// e o que mais precisa parecer calmo: nada deu errado aqui.
  neutral,

  /// Algo falhou (rede, servidor). Ícone e ação ganham a cor de alerta.
  error,
}

/// Estado vazio ou de erro.
///
/// A versão anterior pintava o ícone dentro de um círculo **vermelho a 12%**
/// em todos os casos, inclusive nos "você ainda não avaliou nada" — o que
/// dava ao app um ar de erro permanente justamente nas telas em que o
/// usuário novo passa mais tempo. Agora:
///
/// - o tom padrão é neutro: círculo em `surfaceAlt`, ícone em
///   `textTertiary`. Some para o segundo plano em vez de gritar;
/// - só [EmptyStateTone.error] usa vermelho, e ainda assim apenas no ícone;
/// - a ação usa `AppButton` (`secondary` no neutro, `primary` no erro), em
///   vez de um `ElevatedButton` pill vermelho montado à mão.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateTone tone;

  /// Cor de acento do ícone. Use com parcimônia — o padrão neutro é o certo
  /// para quase todo estado vazio.
  final Color? color;

  /// Compacta o bloco para caber dentro de um card ou seção, em vez de
  /// ocupar a tela inteira.
  final bool dense;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.tone = EmptyStateTone.neutral,
    this.color,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isError = tone == EmptyStateTone.error;

    final iconColor = color ?? (isError ? MfColor.danger : colors.textTertiary);
    final circleColor = isError
        ? MfColor.danger.withValues(alpha: 0.10)
        : colors.surfaceAlt;

    // Círculo e ícone acompanham a escala: um estado vazio é um bloco
    // centrado de ilustração + texto, e o ícone parado ao lado de um título
    // que dobrou quebra a proporção do conjunto. O círculo cresce junto para
    // não apertar o ícone contra a borda.
    final circleSize = escalaIcone(context, dense ? 56.0 : 72.0);
    final iconSize = escalaIcone(context, dense ? 24.0 : 30.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: dense ? Spacing.lg : Spacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sem isto, dentro de uma `Column` com `crossAxisAlignment.start`
          // (o caso do perfil) o bloco encolhe até o conteúdo e fica
          // encostado à esquerda em vez de centralizado.
          const SizedBox(width: double.infinity),
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          SizedBox(height: dense ? Spacing.base : Spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.title(context),
          ),
          if (description != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              description!,
              textAlign: TextAlign.center,
              // Três linhas bastam: um estado vazio que precisa de parágrafo
              // está explicando demais. Mas o corte é uma regra de *edição de
              // texto*, não de espaço — em escala alta ele passaria a cortar
              // uma frase que cabia, então o teto sai de cena e o bloco cresce
              // (nada aqui tem altura fixa).
              maxLines: fatorDeEscala(context) > 1.3 ? null : 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.secondary(context).copyWith(height: 1.5),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: dense ? Spacing.base : Spacing.lg),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              size: AppButtonSize.sm,
              expand: false,
              variant: isError ? AppButtonVariant.primary : AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
