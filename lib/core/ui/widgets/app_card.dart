import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

enum AppCardElevation {
  flat,

  raised,

  floating,
}

class AppCard extends StatelessWidget {
  final Widget child;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;
  final double radius;
  final AppCardElevation elevation;

  final bool bordered;

  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Spacing.base),
    this.radius = Radii.xl,
    this.elevation = AppCardElevation.raised,
    this.bordered = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius);

    final background = color ??
        (elevation == AppCardElevation.flat ? colors.surfaceAlt : colors.surface);

    final shadows = switch (elevation) {
      AppCardElevation.flat => const <BoxShadow>[],
      AppCardElevation.raised => isDark ? const <BoxShadow>[] : AppElevation.soft,
      AppCardElevation.floating => AppElevation.floating,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius,
        border: bordered ? Border.all(color: colors.border) : null,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
