import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class SearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _limpar() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          // Superfície levemente destacada sobre o mainBackground da página.
          color: context.mapColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          textAlignVertical: TextAlignVertical.center,
          style: AppText.corpo(
            context,
          ).copyWith(fontWeight: FontWeight.w500, color: context.mapColors.primaryText),
          decoration: InputDecoration(
            isDense: true,
            hintText: "Buscar por comércios...",
            hintStyle: AppText.corpo(
              context,
            ).copyWith(color: context.mapColors.secondaryText),
            prefixIcon: Icon(
              PhosphorIconsRegular.magnifyingGlass,
              color: context.mapColors.iconMuted,
              size: 20.0,
            ),
            suffixIcon: widget.controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      color: context.mapColors.iconMuted,
                      size: 18.0,
                    ),
                    onPressed: _limpar,
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onChanged,
        ),
      ),
    );
  }
}
