import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class SearchHistoryWidget extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String> onQueryTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  const SearchHistoryWidget({
    super.key,
    required this.history,
    required this.onQueryTap,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Buscas recentes",
                style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: context.mapColors.primaryText),
              ),
              SemanticTapArea(
                label: 'Limpar buscas recentes',
                onTap: onClear,
                child: Text(
                  "limpar",
                  style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: history.map((query) {
              return SemanticTapArea(
                label: query,
                hint: 'Repete esta busca',
                onTap: () => onQueryTap(query),
                child: Container(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: context.mapColors.cardSurface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: context.mapColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        query,
                        style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600, color: context.mapColors.primaryText),
                      ),
                      const SizedBox(width: 4.0),
                      SemanticTapArea(
                        label: 'Remover "$query" do histórico',
                        onTap: () => onRemove(query),
                        child: Icon(AppIcons.x, size: 14.0, color: context.mapColors.iconMuted),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
