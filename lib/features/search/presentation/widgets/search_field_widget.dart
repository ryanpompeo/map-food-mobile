import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

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
        // 1. ALTURA FIXA REMOVIDA: A altura agora é ditada pelo conteúdo interno.
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: ColorsPalette.black.withValues(alpha: 0.03),
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
          ).copyWith(fontWeight: FontWeight.w500, color: ColorsPalette.black),
          decoration: InputDecoration(
            isDense: true,
            hintText: "Buscar por comércios...",
            hintStyle: AppText.corpo(
              context,
            ).copyWith(color: Colors.grey.shade400),
            prefixIcon: Icon(
              PhosphorIconsRegular.magnifyingGlass,
              color: Colors.grey.shade400,
              size: 20.0,
            ),
            suffixIcon: widget.controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      color: Colors.grey.shade400,
                      size: 18.0,
                    ),
                    onPressed: _limpar,
                  ),
            border: InputBorder.none,
            // 2. PADDING SIMÉTRICO: 16px top + ~22px conteúdo + 16px bottom = ~54px totais
            // Isso garante centralização absoluta no eixo Y.
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
