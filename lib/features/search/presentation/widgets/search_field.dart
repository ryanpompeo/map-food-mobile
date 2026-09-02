import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
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
  final _focusNode = FocusNode();
  bool _focado = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _onFocusChanged() => setState(() => _focado = _focusNode.hasFocus);

  void _limpar() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        decoration: BoxDecoration(
          color: context.mapColors.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color: _focado ? MfColor.brand : context.mapColors.divider,
            width: _focado ? 1.5 : 1.0,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          textAlignVertical: TextAlignVertical.center,
          style: AppText.body(
            context,
          ).copyWith(fontWeight: FontWeight.w500, color: context.mapColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            hintText: "Buscar por comércios...",
            hintStyle: AppText.body(
              context,
            ).copyWith(color: context.mapColors.textSecondary),
            prefixIcon: Icon(
              AppIcons.magnifyingGlass,
              color: context.mapColors.textTertiary,
              size: 20.0,
            ),
            suffixIcon: widget.controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      AppIcons.x,
                      color: context.mapColors.textTertiary,
                      size: 18.0,
                    ),
                    onPressed: _limpar,
                  ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: Spacing.sm,
            ),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onChanged,
        ),
      ),
    );
  }
}
