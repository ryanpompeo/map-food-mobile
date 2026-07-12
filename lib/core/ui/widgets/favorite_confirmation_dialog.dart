import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// AlertDialog minimalista de confirmação antes de favoritar/desfavoritar —
/// evita que um toque acidental no coração dispare a ação (e, quando isso
/// passar a chamar API, uma requisição) sem intenção clara do usuário.
class FavoriteConfirmationDialog {
  FavoriteConfirmationDialog._();

  /// Retorna `true` só se o usuário confirmou explicitamente.
  static Future<bool> show(BuildContext context, {required bool isFavorite}) async {
    final colors = context.appColors;
    // Remover usa a cor de erro/perigo da paleta; adicionar usa a cor de destaque.
    final confirmColor = isFavorite ? colors.error : colors.accent;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(
          isFavorite ? 'Remover dos favoritos?' : 'Adicionar aos favoritos?',
          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          isFavorite
              ? 'Esse comércio vai sair da sua lista de favoritos.'
              : 'Esse comércio vai entrar na sua lista de favoritos.',
          style: AppText.corpo(context).copyWith(color: colors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: AppText.corpo(context).copyWith(color: colors.textSecondary, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Confirmar',
              style: AppText.corpo(context).copyWith(color: confirmColor, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
