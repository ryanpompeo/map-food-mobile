import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Diálogo genérico de confirmação de saída, usado tanto para formulários
/// com alterações pendentes quanto para operações em andamento (ex: cálculo
/// de rota). Devolve `true` se o usuário confirmou que quer sair mesmo assim.
Future<bool> _confirmarSaida(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String labelConfirmar,
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: ctx.mapColors.cardSurface,
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
                    color: ColorsPalette.redComponents.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(PhosphorIconsRegular.warning, color: ColorsPalette.redComponents, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(titulo, style: AppText.titulo(ctx).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              mensagem,
              style: AppText.corpo(ctx).copyWith(color: ctx.mapColors.primaryText),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text("Continuar", style: AppText.botao(ctx).copyWith(color: ctx.mapColors.secondaryText)),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents,
                    foregroundColor: Colors.white,
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
    ),
  );
  return confirmou ?? false;
}

/// Pergunta "Deseja sair sem salvar?" antes de descartar uma edição em
/// andamento. Devolve `true` se o usuário confirmou que quer sair.
Future<bool> confirmarSaidaSemSalvar(BuildContext context) => _confirmarSaida(
      context,
      titulo: "Sair sem salvar?",
      mensagem: "Você tem alterações não salvas. Se sair agora, elas serão perdidas.",
      labelConfirmar: "Sair sem salvar",
    );

/// Pergunta antes de sair de uma tela enquanto uma rota está sendo calculada
/// — o cálculo (chamada ao OSRM) é cancelado se o usuário confirmar a saída.
Future<bool> confirmarSairDuranteCalculoDeRota(BuildContext context) => _confirmarSaida(
      context,
      titulo: "Cálculo de rota em andamento",
      mensagem: "Estamos traçando a rota até a loja. Se sair agora, o cálculo é cancelado.",
      labelConfirmar: "Sair mesmo assim",
    );

/// Envolve uma tela e intercepta a saída (gesto/botão de voltar do Android)
/// enquanto [hasUnsavedChanges] for `true`, pedindo confirmação — via
/// [confirmDialog] — em vez de descartar/cancelar silenciosamente.
class UnsavedChangesGuard extends StatelessWidget {
  final bool hasUnsavedChanges;
  final Widget child;
  final Future<bool> Function(BuildContext context) confirmDialog;

  const UnsavedChangesGuard({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
    this.confirmDialog = confirmarSaidaSemSalvar,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmou = await confirmDialog(context);
        if (confirmou && context.mounted) Navigator.of(context).pop();
      },
      child: child,
    );
  }
}
