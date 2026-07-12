import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// BottomSheet exibido para usuários não autenticados (Guest) quando tentam
/// favoritar um comércio. Responsivo por construção — `mainAxisSize.min` +
/// `SafeArea` + `isScrollControlled: true`, então a altura sempre segue o
/// conteúdo (não estoura em telas pequenas nem com fonte do sistema maior).
class GuestFavoriteCtaSheet extends StatelessWidget {
  const GuestFavoriteCtaSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const GuestFavoriteCtaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.heart, color: colors.accent, size: 32),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Salve seus comércios favoritos!',
                textAlign: TextAlign.center,
                style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Crie uma conta gratuita em segundos para salvar, avaliar e denunciar comércios na sua cidade.',
                textAlign: TextAlign.center,
                style: AppText.corpo(context).copyWith(color: colors.textSecondary, height: 1.3),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.accountType);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                  child: Text('Criar Conta', style: AppText.botao(context).copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: Text(
                  'Fazer Login',
                  style: AppText.corpo(context).copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
