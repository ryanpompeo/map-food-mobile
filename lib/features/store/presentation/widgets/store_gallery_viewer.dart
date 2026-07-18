import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';

/// Visualização fullscreen da galeria de fotos de uma loja — swipe lateral
/// entre todas as fotos (a partir da foto tocada na lista horizontal) e
/// avanço automático a cada alguns segundos, reiniciado a cada troca de
/// página (manual ou automática) para não brigar com o gesto do usuário.
class StoreGalleryViewer extends StatefulWidget {
  final List<String> imagens;
  final int initialIndex;

  const StoreGalleryViewer({
    super.key,
    required this.imagens,
    required this.initialIndex,
  });

  @override
  State<StoreGalleryViewer> createState() => _StoreGalleryViewerState();
}

class _StoreGalleryViewerState extends State<StoreGalleryViewer> {
  static const _autoplayInterval = Duration(seconds: 4);

  late final PageController _pageController;
  late int _currentIndex;
  Timer? _autoplayTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _reiniciarAutoplay();
  }

  void _reiniciarAutoplay() {
    _autoplayTimer?.cancel();
    if (widget.imagens.length <= 1) return;
    _autoplayTimer = Timer.periodic(_autoplayInterval, (_) {
      if (!mounted) return;
      final proximaPagina = (_currentIndex + 1) % widget.imagens.length;
      _pageController.animateToPage(
        proximaPagina,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagens.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _reiniciarAutoplay();
            },
            itemBuilder: (context, index) => Center(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.network(
                  widget.imagens[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    PhosphorIconsRegular.image,
                    color: Colors.white38,
                    size: 64.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            right: AppSpacing.md,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(PhosphorIconsRegular.x, color: Colors.white, size: 28.0),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                shape: const CircleBorder(),
              ),
            ),
          ),
          if (widget.imagens.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.imagens.length, (index) {
                    final isActive = index == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      width: isActive ? 20.0 : 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
