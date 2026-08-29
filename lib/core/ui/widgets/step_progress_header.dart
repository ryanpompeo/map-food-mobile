import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Progresso de um fluxo em etapas: trilhos preenchidos + "Etapa 2 de 3".
///
/// Num cadastro dividido em passos, a pergunta que trava a pessoa não é "o que
/// preencho agora?", é **"quanto falta?"**. Sem essa resposta, dividir o
/// formulário só esconde o tamanho dele — e esconder o esforço restante é o
/// que faz alguém abandonar no meio.
///
/// Genérico de propósito: sabe contar etapas, não sabe o que são. Serve a
/// qualquer fluxo que venha depois.
class StepProgressHeader extends StatelessWidget {
  /// Etapa atual, começando em zero.
  final int etapaAtual;

  final int total;

  /// Nome da etapa ("Sua loja"), mostrado ao lado da contagem. `null` deixa só
  /// os trilhos e o "Etapa X de Y".
  final String? rotulo;

  const StepProgressHeader({
    super.key,
    required this.etapaAtual,
    required this.total,
    this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 6.0),
              Expanded(
                child: AnimatedContainer(
                  duration: Motion.medium,
                  height: 4.0,
                  decoration: BoxDecoration(
                    // Etapas já vencidas e a atual ficam preenchidas: o trilho
                    // mede o caminho andado, não só onde se está.
                    color: i <= etapaAtual ? MfColor.brand : colors.border,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Text(
              'Etapa ${etapaAtual + 1} de $total',
              style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w700),
            ),
            if (rotulo != null) ...[
              Text('  ·  ', style: AppText.legenda(context)),
              Expanded(
                child: Text(
                  rotulo!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.legenda(context),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
