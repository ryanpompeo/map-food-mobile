import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';

class StackedCardItem {
  final Object id;
  final String title;
  final String? imageUrl;

  final String? subtitle;

  final double? rating;

  const StackedCardItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.rating,
  });
}

class StackedCardCarousel extends StatefulWidget {
  final List<StackedCardItem> items;
  final ValueChanged<StackedCardItem> onTap;
  final double cardHeight;
  final Duration autoAdvanceInterval;

  final double horizontalPadding;

  const StackedCardCarousel({
    super.key,
    required this.items,
    required this.onTap,
    this.cardHeight = 220.0,
    this.autoAdvanceInterval = const Duration(seconds: 4),
    this.horizontalPadding = AppSpacing.lg,
  });

  @override
  State<StackedCardCarousel> createState() => _StackedCardCarouselState();
}

class _StackedCardCarouselState extends State<StackedCardCarousel> {
  static const int _maxVisible = 3;
  static const Duration _animDuration = Duration(milliseconds: 420);
  static const double _velocidadeMinimaSwipe = 250.0;

  static const double _passoVertical = 16.0;
  static const double _passoRecuoHorizontal = 12.0;

  int _currentIndex = 0;
  Timer? _timer;

  final ValueNotifier<double> _dragDx = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant StackedCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _currentIndex = 0;
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dragDx.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;
    _timer = Timer.periodic(widget.autoAdvanceInterval, (_) => _advance());
  }

  void _advance() {
    if (!mounted || widget.items.isEmpty) return;
    setState(() => _currentIndex = (_currentIndex + 1) % widget.items.length);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    _dragDx.value = 0.0;
    if (velocity.abs() > _velocidadeMinimaSwipe) {
      _advance();
      _restartTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final count = widget.items.length;
    final visibleCount = count < _maxVisible ? count : _maxVisible;
    final extraProfundidade = (visibleCount - 1) * _passoVertical;

    return SizedBox(
      width: double.infinity,
      height: widget.cardHeight + extraProfundidade,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int depth = visibleCount - 1; depth >= 0; depth--)
            _buildSlot(context, depth, count),
        ],
      ),
    );
  }

  Widget _buildSlot(BuildContext context, int depth, int count) {
    final item = widget.items[(_currentIndex + depth) % count];
    final isFront = depth == 0;

    final horizontalInset = widget.horizontalPadding + (depth * _passoRecuoHorizontal);
    final topOffset = depth * _passoVertical;
    final opacity = depth == 0 ? 1.0 : (depth == 1 ? 0.85 : 0.55);

    final conteudo = AnimatedOpacity(
      duration: _animDuration,
      curve: Curves.easeOutCubic,
      opacity: opacity,
      child: isFront
          ? _StoreStackCard(item: item, height: widget.cardHeight, onTap: () => widget.onTap(item))
          : _StackedCardBackdrop(height: widget.cardHeight),
    );

    return AnimatedPositioned(
      key: ValueKey(item.id),
      duration: _animDuration,
      curve: Curves.easeOutCubic,
      top: topOffset,
      left: horizontalInset,
      right: horizontalInset,
      child: isFront
          ? GestureDetector(
              onHorizontalDragUpdate: (details) => _dragDx.value += details.delta.dx,
              onHorizontalDragEnd: _onDragEnd,
              child: ValueListenableBuilder<double>(
                valueListenable: _dragDx,
                builder: (context, dx, child) =>
                    Transform.translate(offset: Offset(dx * 0.3, 0), child: child),
                child: conteudo,
              ),
            )
          : IgnorePointer(child: conteudo),
    );
  }
}

class _StackedCardBackdrop extends StatelessWidget {
  final double height;

  const _StackedCardBackdrop({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.mapColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
    );
  }
}

class _StoreStackCard extends StatelessWidget {
  final StackedCardItem item;
  final double height;
  final VoidCallback onTap;

  const _StoreStackCard({required this.item, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                path: item.imageUrl,
                displayWidth: MediaQuery.sizeOf(context).width,
                fallback: _buildFallback(context),
              ),

              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                      colors: [Colors.transparent, Color(0xD9000000)],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.subtitle != null || item.rating != null) ...[
                      Row(
                        children: [
                          if (item.subtitle != null)
                            Flexible(child: _SeloDeVidro(texto: item.subtitle!)),
                          if (item.subtitle != null && item.rating != null)
                            const SizedBox(width: 6.0),
                          if (item.rating != null)
                            _SeloDeVidro(
                              texto: item.rating!.toStringAsFixed(1),
                              icone: AppIcons.star,
                              corIcone: ColorsPalette.ratingStar,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.corpo(context).copyWith(
                              fontSize: 18.0,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: ColorsPalette.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          height: 36.0,
                          width: 36.0,
                          decoration: const BoxDecoration(
                            color: ColorsPalette.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            AppIcons.arrowRight,
                            size: AppIconSize.md,
                            color: MfColor.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return ColoredBox(
      color: context.mapColors.surfaceAlt,
      child: Center(
        child: Icon(AppIcons.storefront, color: context.mapColors.iconMuted, size: 40.0),
      ),
    );
  }
}

class _SeloDeVidro extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final Color? corIcone;

  const _SeloDeVidro({required this.texto, this.icone, this.corIcone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: ColorsPalette.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: ColorsPalette.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 12.0, color: corIcone ?? ColorsPalette.white),
            const SizedBox(width: 4.0),
          ],
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.legenda(context).copyWith(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: ColorsPalette.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
