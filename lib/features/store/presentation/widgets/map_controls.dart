import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';

class MapControlButton extends StatelessWidget {
  static const double diametro = 48.0;

  final IconData icon;

  final String tooltip;

  final VoidCallback? onTap;

  final bool isActive;

  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final habilitado = onTap != null;

    final corIcone = isActive
        ? ColorsPalette.white
        : habilitado
            ? colors.textPrimary
            : colors.textTertiary;

    return Tooltip(
      message: tooltip,
      child: Container(
        width: diametro,
        height: diametro,
        decoration: BoxDecoration(
          color: isActive ? MfColor.brand : colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? MfColor.brand : colors.border),
          boxShadow: habilitado ? AppElevation.floating : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Icon(icon, size: AppIconSize.lg, color: corIcone),
          ),
        ),
      ),
    );
  }
}

class MapZoomControls extends StatelessWidget {
  final StoreMapController controller;

  const MapZoomControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.zoom,
      builder: (context, zoom, _) {
        final nivel = 'Nível ${controller.nivelZoom} de ${controller.totalNiveisZoom}';

        return Semantics(
          container: true,
          value: nivel,
          child: Column(
            children: [
              MapControlButton(
                icon: AppIcons.plus,
                tooltip: 'Ampliar o mapa',
                onTap: zoom < StoreMapController.zoomMaximo ? controller.ampliar : null,
              ),
              const SizedBox(height: Spacing.sm),
              MapControlButton(
                icon: AppIcons.minus,
                tooltip: 'Reduzir o mapa',
                onTap: zoom > StoreMapController.zoomMinimo ? controller.reduzir : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
