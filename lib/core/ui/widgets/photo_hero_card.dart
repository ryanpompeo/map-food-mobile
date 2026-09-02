import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';

class PhotoHeroCard extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final Widget? topLeft;
  final Widget? topRight;
  final Widget? bottomContent;

  final double? displayWidth;

  const PhotoHeroCard({
    super.key,
    required this.imageUrl,
    this.radius = 32.0,
    this.onTap,
    this.topLeft,
    this.topRight,
    this.bottomContent,
    this.displayWidth,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Container(
              color: context.mapColors.mainBackground,
              child: AppNetworkImage(
                path: imageUrl,
                displayWidth: displayWidth,
                fallbackIconSize: 48.0,
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 0.75, 1.0],
                  colors: [Colors.transparent, Color(0xB3000000), Color(0xF2000000)],
                ),
              ),
            ),
          ),
          if (topRight != null) Positioned(top: 10.0, right: 10.0, child: topRight!),
          if (topLeft != null) Positioned(top: 10.0, left: 10.0, child: topLeft!),
          if (bottomContent != null)
            Positioned(left: 14.0, right: 14.0, bottom: 12.0, child: bottomContent!),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: content);
  }
}

class FrostedBadge extends StatelessWidget {
  final Widget child;
  const FrostedBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
      ),
      child: child,
    );
  }
}
