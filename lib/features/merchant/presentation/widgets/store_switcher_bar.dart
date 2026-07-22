import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';

/// Barra horizontal de chips pra alternar entre as lojas do comerciante
/// (útil quando ele tem mais de uma), com um chip final pra cadastrar uma
/// loja nova. Aparece sobre as telas "Loja"/"Perfil da Loja" do comerciante.
class StoreSwitcherBar extends StatelessWidget {
  final List<StoreDto> stores;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const StoreSwitcherBar({
    super.key,
    required this.stores,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: context.mapColors.mainBackground,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: SizedBox(
        height: 40.0,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: stores.length + 1,
          itemBuilder: (context, index) {
            if (index == stores.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    appPageRoute(builder: (_) => const StoreRegisterPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.mapColors.cardSurface,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: context.mapColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIconsRegular.plus, size: 16.0, color: ColorsPalette.redComponents),
                        const SizedBox(width: 4.0),
                        Text(
                          "Nova loja",
                          style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.redComponents),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final store = stores[index];
            final bool isSelected = index == selectedIndex;
            final bool aberta = store.statusLoja == 'ATIVA';

            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? ColorsPalette.black : context.mapColors.cardSurface,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.0,
                        height: 8.0,
                        // Indicador de status operacional (aberta/fechada) —
                        // verde/cinza absolutos, não tokenizados (Lote 6).
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: aberta ? Colors.greenAccent.shade400 : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        store.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Não-selecionado sem override: legenda() já resolve pra secondaryText.
                        style: AppText.legenda(context).copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
