import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class FloatingBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const FloatingBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
        child: Container(
          // 1. A SOMBRA VAI AQUI POR FORA (Se ficar dentro do ClipRRect, ela é cortada)
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: BackdropFilter(
              // 2. BLUR MAIS ALTO PARA O EFEITO FROSTED GLASS (Estética iOS)
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  // 3. GRADIENTE PARA SIMULAR A REFRAÇÃO DA LUZ
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                  // 4. BORDA FINA PARA O "GLARE" (Brilho da borda do vidro)
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavItem(
                      icon: LucideIcons.house,
                      isSelected: selectedIndex == 0,
                      onTap: () => onItemTapped(0),
                    ),
                    const SizedBox(width: 8.0),
                    _NavItem(
                      icon: LucideIcons.search,
                      isSelected: selectedIndex == 1,
                      onTap: () => onItemTapped(1),
                    ),
                    const SizedBox(width: 8.0),
                    _NavItem(
                      icon: LucideIcons.user,
                      isSelected: selectedIndex == 2,
                      onTap: () => onItemTapped(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // O item selecionado ganha um fundo branco sólido para dar contraste extremo
          color: isSelected
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.transparent,
          // Sombra interna leve apenas no item ativo para criar elevação
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24.0,
            color: isSelected
                ? ColorsPalette.redComponents
                : ColorsPalette.black.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
