import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';

class _ThemeModeOption {
  final ThemeMode mode;
  final String label;
  final IconData icon;

  const _ThemeModeOption(this.mode, this.label, this.icon);
}

const _options = [
  _ThemeModeOption(ThemeMode.light, "Claro", PhosphorIconsRegular.sun),
  _ThemeModeOption(ThemeMode.dark, "Escuro", PhosphorIconsRegular.moon),
  _ThemeModeOption(ThemeMode.system, "Automático (sistema)", PhosphorIconsRegular.deviceMobile),
];

/// Abre um bottom sheet com as três opções de tema e aplica a escolha via
/// [ThemeController.instance] — chame a partir de qualquer tela de
/// configurações/perfil.
Future<void> showThemeModeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => const _ThemeModeSheetContent(),
  );
}

class _ThemeModeSheetContent extends StatelessWidget {
  const _ThemeModeSheetContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Aparência", style: AppText.titulo(context).copyWith(fontSize: 18)),
            const SizedBox(height: AppSpacing.md),
            // Isolamento de rebuild: só esta lista escuta o
            // ThemeController. O título acima e os paddings do sheet não
            // precisam reconstruir a cada troca de tema.
            ListenableBuilder(
              listenable: ThemeController.instance,
              builder: (context, _) {
                final current = ThemeController.instance.value;
                return Column(
                  children: [
                    for (final option in _options)
                      _ThemeOptionTile(
                        label: option.label,
                        icon: option.icon,
                        selected: current == option.mode,
                        onTap: () => ThemeController.instance.setThemeMode(option.mode),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppIconSize.lg,
              color: selected ? ColorsPalette.redComponents : Colors.grey.shade600,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppText.corpo(context).copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(PhosphorIconsRegular.check, color: ColorsPalette.redComponents, size: 20),
          ],
        ),
      ),
    );
  }
}
