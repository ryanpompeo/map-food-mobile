import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String? path;

  final BoxFit fit;
  final double? width;
  final double? height;

  final double? displayWidth;

  final String? semanticLabel;

  final Widget? fallback;

  final double fallbackIconSize;

  final Duration fadeDuration;

  const AppNetworkImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.displayWidth,
    this.semanticLabel,
    this.fallback,
    this.fallbackIconSize = 24.0,
    this.fadeDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final provider = providerFor(context, path, displayWidth: displayWidth);
    if (provider == null) return _buildFallback(context);

    return Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      frameBuilder: _comFade,
      errorBuilder: (context, error, stackTrace) => _buildFallback(context),
    );
  }

  static ImageProvider? providerFor(
    BuildContext context,
    String? path, {
    double? displayWidth,
  }) {
    final url = resolveImagemUrl(path);
    if (url == null) return null;

    final provider = CachedNetworkImageProvider(url);
    if (displayWidth == null) return provider;

    return ResizeImage(
      provider,
      width: (displayWidth * MediaQuery.devicePixelRatioOf(context)).round(),
      allowUpscaling: false,
    );
  }

  static Future<void> precache(
    BuildContext context,
    String? path, {
    double? displayWidth,
  }) async {
    final provider = providerFor(context, path, displayWidth: displayWidth);
    if (provider == null) return;
    await precacheImage(provider, context, onError: (_, _) {});
  }

  Widget _comFade(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0.0 : 1.0,
      duration: fadeDuration,
      curve: Curves.easeOut,
      child: child,
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (fallback != null) return fallback!;
    return Center(
      child: Icon(
        AppIcons.image,
        size: fallbackIconSize,
        color: context.mapColors.iconMuted,
      ),
    );
  }
}
