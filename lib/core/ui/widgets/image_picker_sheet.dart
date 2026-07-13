import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// Abre um bottom sheet com as opções "Tirar foto" / "Escolher da galeria"
/// e devolve o arquivo escolhido, ou `null` se o usuário cancelar.
/// Devolve `XFile` (não `dart:io.File`) porque este app também builda para
/// Flutter Web, onde não há acesso a caminhos de arquivo do sistema.
Future<XFile?> pickImageFromSheet(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.0, height: 4.0, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.0))),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Escolher foto",
              style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SheetOption(
              icon: LucideIcons.camera,
              label: "Tirar foto",
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SheetOption(
              icon: LucideIcons.image,
              label: "Escolher da galeria",
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      );
    },
  );

  if (source == null || !context.mounted) return null;

  return ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1600);
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, color: ColorsPalette.redComponents, size: AppIconSize.md),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.blackDetails)),
          ],
        ),
      ),
    );
  }
}
