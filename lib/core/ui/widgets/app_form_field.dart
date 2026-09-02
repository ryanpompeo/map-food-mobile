import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;

  final bool showIcon;

  final int maxLines;

  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  final FocusNode? focusNode;

  final TextInputAction? textInputAction;

  final ValueChanged<String>? onSubmitted;

  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.showIcon = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final effectivePrefixIcon = prefixIcon ??
        (showIcon && icon != null
            ? Icon(icon, color: colors.textTertiary, size: AppIconSize.md)
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Text(
            label,
            style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Semantics(
          label: label,
          textField: true,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            validator: validator,
            inputFormatters: inputFormatters,
            maxLines: obscureText ? 1 : maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            textAlignVertical: maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
            style: AppText.body(context).copyWith(
              fontWeight: FontWeight.w500,
              color: enabled ? colors.textPrimary : colors.textTertiary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: effectivePrefixIcon,
              suffixIcon: suffixIcon,
              counterText: '',
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 24),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: maxLines > 1 ? Spacing.base : 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
