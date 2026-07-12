import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';

/// BottomSheet de seleção de tema (Claro/Escuro/Sistema) — o único lugar do
/// app que efetivamente chama `AppThemeController.instance.setMode(...)`.
class ThemeModeSelectorSheet extends StatelessWidget {
  const ThemeModeSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ThemeModeSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        final atual = AppThemeController.instance.mode;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema do Aplicativo',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colors.textPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  _opcao(context, icon: LucideIcons.sun, label: 'Claro', mode: ThemeMode.light, atual: atual),
                  _opcao(context, icon: LucideIcons.moon, label: 'Escuro', mode: ThemeMode.dark, atual: atual),
                  _opcao(context, icon: LucideIcons.smartphone, label: 'Sistema', mode: ThemeMode.system, atual: atual),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _opcao(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required ThemeMode atual,
  }) {
    final colors = context.appColors;
    final selecionado = mode == atual;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      // É esta chamada que faltava em qualquer lugar do app.
      onTap: () {
        AppThemeController.instance.setMode(mode);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selecionado ? colors.accent : colors.textSecondary),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: selecionado ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
            if (selecionado) Icon(LucideIcons.check, size: 18, color: colors.accent),
          ],
        ),
      ),
    );
  }
}
