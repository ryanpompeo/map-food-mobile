import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AppRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;

  final Widget child;

  const AppRefresh({super.key, required this.onRefresh, required this.child});

  static const ScrollPhysics physics =
      AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  static Widget centralizado(Widget child) {
    return CustomScrollView(
      physics: physics,
      slivers: [
        SliverFillRemaining(hasScrollBody: false, child: Center(child: child)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ColorsPalette.redComponents,
      backgroundColor: context.mapColors.cardSurface,
      child: child,
    );
  }
}
