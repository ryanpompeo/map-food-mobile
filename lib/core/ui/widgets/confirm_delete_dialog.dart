import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

Future<bool> confirmarRemocaoFoto(BuildContext context) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
                  child: const Icon(AppIcons.trash, color: ColorsPalette.redComponents, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text("Remover foto", style: AppText.titulo(ctx).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text("Tem certeza que deseja remover esta foto?", style: AppText.corpo(ctx).copyWith(color: ctx.mapColors.primaryText)),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text("Cancelar", style: AppText.botao(ctx).copyWith(color: ctx.mapColors.secondaryText)),
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
                  child: const Text("Remover", style: TextStyle(fontWeight: FontWeight.bold)),
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

Future<bool> confirmarExclusaoLoja(BuildContext context, String nomeLoja) =>
    _confirmarComPalavraChave(
      context,
      titulo: 'Excluir loja',
      mensagem: 'Essa ação é irreversível. "$nomeLoja" sai do mapa, e as avaliações, '
          'denúncias e o histórico de acessos dela são apagados junto.',
      labelBotao: 'Excluir loja',
    );

Future<bool> confirmarExclusaoConta(BuildContext context) => _confirmarComPalavraChave(
      context,
      titulo: 'Excluir conta',
      mensagem: 'Essa ação é irreversível. Sua conta, loja(s), avaliações e denúncias '
          'associadas serão apagadas permanentemente.',
      labelBotao: 'Excluir conta',
    );

Future<bool> _confirmarComPalavraChave(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String labelBotao,
}) async {
  const palavraChave = 'EXCLUIR';
  final controller = TextEditingController();

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final habilitado = controller.text.trim() == palavraChave;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
                      child: const Icon(AppIcons.warning, color: ColorsPalette.redComponents, size: 18),
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
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Digite $palavraChave para confirmar:",
                  style: AppText.corpo(ctx).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: palavraChave,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text("Cancelar", style: AppText.botao(ctx).copyWith(color: ctx.mapColors.secondaryText)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: habilitado ? () => Navigator.pop(ctx, true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsPalette.redComponents,
                        disabledBackgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                      ),
                      child: Text(labelBotao, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  controller.dispose();
  return confirmou ?? false;
}
