import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

/// Rodapé fixo de um fluxo em etapas: avançar à direita, voltar à esquerda.
///
/// O botão que conclui o fluxo **nunca** rola para fora da tela. Num
/// formulário longo, o CTA fica no fim de uma rolagem que a pessoa precisa
/// descobrir; aqui ele está sempre à mão, e é o elemento de maior contraste da
/// tela — o único lugar onde a cor cheia da marca aparece.
///
/// Use como `Scaffold.bottomNavigationBar`: assim o próprio Scaffold o levanta
/// junto com o teclado, sem cálculo de `viewInsets` na mão.
class WizardFooter extends StatelessWidget {
  final String labelPrimario;

  /// `null` desabilita (ex: envio em curso ou etapa inválida).
  final VoidCallback? onPrimario;

  final bool carregando;

  /// `null` esconde o botão de voltar — o caso da primeira etapa, onde não há
  /// passo anterior e um botão desabilitado só ocuparia espaço.
  final VoidCallback? onVoltar;

  /// Rótulo do secundário. "Voltar" num fluxo em etapas, "Cancelar" quando a
  /// barra fecha um formulário — a ação é a mesma forma, o significado não.
  final String labelSecundario;

  final IconData? iconePrimario;

  const WizardFooter({
    super.key,
    required this.labelPrimario,
    required this.onPrimario,
    this.carregando = false,
    this.onVoltar,
    this.labelSecundario = 'Voltar',
    this.iconePrimario,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        // `divider`, o traço mais fraco do sistema: aqui ele só separa o
        // rodapé do conteúdo que passa por baixo. Uma borda forte ou uma
        // sombra transformaria a barra num objeto flutuante, que é peso
        // visual que este fluxo não quer.
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.md,
            Spacing.lg,
            Spacing.md,
          ),
          child: Row(
            children: [
              if (onVoltar != null) ...[
                Expanded(
                  child: AppButton(
                    label: labelSecundario,
                    onPressed: carregando ? null : onVoltar,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: Spacing.md),
              ],
              Expanded(
                // O avanço domina a linha: dois botões de mesma largura leem
                // como duas opções equivalentes, e continuar não é opcional.
                flex: 2,
                child: AppButton(
                  label: labelPrimario,
                  icon: iconePrimario,
                  onPressed: onPrimario,
                  loading: carregando,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
