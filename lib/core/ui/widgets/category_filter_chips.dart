import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Fileira horizontal de pills de filtro de categoria usada no header das
/// três home pages (guest, consumidor e comerciante) — antes copiada 3×.
class CategoryFilterChips extends StatelessWidget {
  final List<String> filtros;
  final String ativo;
  final ValueChanged<String> onSelect;

  const CategoryFilterChips({
    super.key,
    required this.filtros,
    required this.ativo,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final bool isSelected = ativo == filtro;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: RepaintBoundary(
              child: GestureDetector(
                onTap: () => onSelect(filtro),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // Selecionado fica sólido preto/branco de propósito —
                    // contraste garantido nos dois temas, igual ao CTA de
                    // "Sair" (ver Lote 1). Não-selecionado usa cardSurface,
                    // que troca de branco pra cinza-escuro no dark mode —
                    // por isso o texto correspondente usa secondaryText, não
                    // um cinza fixo, senão ficaria ilegível sobre o dark.
                    color: isSelected ? ColorsPalette.black : context.mapColors.cardSurface,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    filtro,
                    style: AppText.legenda(context).copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : context.mapColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
