import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Confirmação de uma ação **reversível** — devolve `true` se confirmada.
///
/// Existe ao lado de `confirm_delete_dialog.dart`, não dentro dele: lá o freio
/// é digitar "EXCLUIR", porque nada volta depois do toque. Pedir o mesmo ritual
/// para inativar uma loja (que se reativa em dois toques) ensinaria a digitar a
/// palavra no automático — e é justamente esse automatismo que protege o
/// diálogo de exclusão.
Future<bool> confirmarAcao(
  BuildContext context, {
  required IconData icone,
  required String titulo,
  required String mensagem,
  required String labelConfirmar,
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final colors = ctx.mapColors;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        backgroundColor: colors.cardSurface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // Neutro, não vermelho: o vermelho é o vocabulário das
                      // ações sem volta (excluir, sair) e perde o sentido de
                      // alerta se aparecer também nas que se desfazem.
                      color: colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icone, color: colors.textSecondary, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      titulo,
                      style: AppText.titulo(ctx).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                mensagem,
                style: AppText.corpo(ctx).copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      "Cancelar",
                      style: AppText.botao(ctx).copyWith(color: colors.secondaryText),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    // Mesmo CTA sólido do diálogo de logout: preto/branco fixos
                    // para ler igual nos dois temas.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPalette.black,
                      foregroundColor: ColorsPalette.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    ),
                    child: Text(labelConfirmar, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmou ?? false;
}
