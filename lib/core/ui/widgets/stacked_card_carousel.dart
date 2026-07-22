import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class StackedCardItem {
  final Object id;
  final String title;
  final String? imageUrl;

  const StackedCardItem({required this.id, required this.title, this.imageUrl});
}

/// Carrossel de cards empilhados (efeito "baralho"): o card da frente é
/// substituído automaticamente pelo de trás a cada [autoAdvanceInterval],
/// e o usuário pode deslizar com o dedo pra trocar na hora — o que
/// acontecer primeiro reinicia o temporizador, pra não "atropelar" o gesto
/// manual com um avanço automático logo em seguida.
///
/// O empilhamento é feito por deslocamento vertical + largura decrescente
/// (não por escala a partir do centro) — assim os cards de trás realmente
/// aparecem espiando por baixo do card da frente, em vez de só encolher
/// escondidos atrás dele.
class StackedCardCarousel extends StatefulWidget {
  final List<StackedCardItem> items;
  final ValueChanged<StackedCardItem> onTap;
  final double cardHeight;
  final Duration autoAdvanceInterval;

  /// Recuo horizontal do card da frente em relação às bordas do carrossel —
  /// aumentar isso estreita o card (os de trás recuam ainda mais a partir
  /// deste valor, ver [_passoRecuoHorizontal]).
  final double horizontalPadding;

  const StackedCardCarousel({
    super.key,
    required this.items,
    required this.onTap,
    this.cardHeight = 190.0,
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

  // Cada profundidade soma este deslocamento vertical e este acréscimo de
  // recuo horizontal em relação ao card da frente (profundidade 0).
  static const double _passoVertical = 16.0;
  static const double _passoRecuoHorizontal = 12.0;

  int _currentIndex = 0;
  Timer? _timer;
  double _dragDx = 0.0;

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
    setState(() => _dragDx = 0.0);
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
      // Altura do card da frente + o quanto os cards de trás "espiam" por
      // baixo dele.
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

    final content = isFront
        ? _StoreStackCard(item: item, height: widget.cardHeight, onTap: () => widget.onTap(item))
        : _StackedCardBackdrop(height: widget.cardHeight);

    final positioned = AnimatedPositioned(
      key: ValueKey(item.id),
      duration: _animDuration,
      curve: Curves.easeOutCubic,
      top: topOffset,
      left: horizontalInset,
      right: horizontalInset,
      child: AnimatedOpacity(
        duration: _animDuration,
        curve: Curves.easeOutCubic,
        opacity: opacity,
        child: content,
      ),
    );

    if (!isFront) return IgnorePointer(child: positioned);

    return GestureDetector(
      onHorizontalDragUpdate: (details) => setState(() => _dragDx += details.delta.dx),
      onHorizontalDragEnd: _onDragEnd,
      child: Transform.translate(offset: Offset(_dragDx * 0.3, 0), child: positioned),
    );
  }
}

/// Silhueta lisa (sem foto) dos cards atrás do card da frente — mostrar a
/// imagem deles também ficaria poluído, já que só uma fatia fina aparece.
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // A imagem preenche 100% do card — o banner do nome flutua por
          // cima dela, com respiro, em vez de "cortar" a imagem por baixo.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Container(
                color: context.mapColors.cardSurface,
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
                      )
                    : _buildFallback(context),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Material(
              color: context.mapColors.cardSurface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              elevation: 4.0,
              shadowColor: Colors.black.withValues(alpha: 0.2),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.corpo(context)
                              .copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        PhosphorIconsRegular.arrowRight,
                        size: AppIconSize.md,
                        color: context.mapColors.primaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: Icon(PhosphorIconsRegular.storefront, color: context.mapColors.iconMuted, size: 40.0),
    );
  }
}
