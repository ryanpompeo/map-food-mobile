import 'package:flutter/material.dart';
import 'package:map_food/core/services/permission_service.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// BottomSheet genérico de "pre-prompt": explica por que o app precisa de
/// uma permissão ANTES de acionar o pop-up nativo do SO — exigência da Apple
/// (iOS) e do Android moderno. Também cobre o caso de permissão negada
/// permanentemente, oferecendo redirecionamento direto às Configurações.
///
/// Não chame o construtor diretamente — use o método estático [request],
/// que consulta o status atual, decide se o pre-prompt faz sentido, e só
/// então decide se chama o trigger nativo (ou abre as Configurações).
///
/// Uso:
/// ```dart
/// final status = await PermissionExplanationDialog.request(
///   context,
///   type: AppPermissionType.location,
///   icon: LucideIcons.mapPin,
///   title: 'Precisamos da sua localização',
///   description: 'Assim conseguimos mostrar os food trucks mais perto de você.',
/// );
/// ```
class PermissionExplanationDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSettingsRedirect;

  const PermissionExplanationDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isSettingsRedirect = false,
  });

  /// Orquestra o fluxo completo de permissão com justificativa:
  /// 1. Se já concedida, retorna na hora, sem mostrar nada.
  /// 2. Se negada permanentemente, mostra o pre-prompt em modo
  ///    "abrir configurações" — o SO não deixa mais pedir nativamente.
  /// 3. Caso contrário, mostra o pre-prompt normal; só chama o trigger
  ///    nativo se o usuário confirmar.
  static Future<AppPermissionStatus> request(
    BuildContext context, {
    required AppPermissionType type,
    required IconData icon,
    required String title,
    required String description,
  }) async {
    final service = PermissionService.instance;
    final current = await service.status(type);

    if (current == AppPermissionStatus.granted) {
      return current;
    }

    if (current == AppPermissionStatus.permanentlyDenied) {
      if (!context.mounted) return current;
      final openSettings = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => PermissionExplanationDialog(
          icon: icon,
          title: title,
          description: description,
          isSettingsRedirect: true,
        ),
      );
      if (openSettings == true) await service.openSettings();
      return current;
    }

    if (!context.mounted) return current;
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PermissionExplanationDialog(
        icon: icon,
        title: title,
        description: description,
      ),
    );

    if (proceed != true) return AppPermissionStatus.denied;
    return service.request(type);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.accent, size: 32),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppText.corpo(context).copyWith(color: colors.textSecondary, height: 1.3),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                  child: Text(
                    isSettingsRedirect ? 'Abrir Configurações' : 'Permitir',
                    style: AppText.botao(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Agora não',
                  style: AppText.legenda(context).copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold,
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
