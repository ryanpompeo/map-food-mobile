import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

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
                style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  "limpar",
                  style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: history.map((query) {
              return GestureDetector(
                onTap: () => onQueryTap(query),
                child: Container(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: ColorsPalette.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        query,
                        style: AppText.legenda(context).copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.black),
                      ),
                      const SizedBox(width: 4.0),
                      GestureDetector(
                        onTap: () => onRemove(query),
                        child: Icon(LucideIcons.x, size: 14.0, color: ColorsPalette.greyText),
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
