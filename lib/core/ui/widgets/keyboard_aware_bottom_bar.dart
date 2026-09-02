import 'package:flutter/material.dart';

class KeyboardAwareBottomBar extends StatelessWidget {
  final Widget child;

  const KeyboardAwareBottomBar({super.key, required this.child});

  static const Duration _duracao = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final tecladoAberto = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: _duracao,
        curve: Curves.easeOutCubic,
        offset: tecladoAberto ? const Offset(0, 1) : Offset.zero,
        child: child,
      ),
    );
  }
}
