import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

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
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

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
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePrefixIcon =
        prefixIcon ??
        (showIcon && icon != null
            ? Icon(icon, color: ColorsPalette.greyText, size: 20.0)
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: ColorsPalette.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          textAlignVertical: maxLines > 1
              ? TextAlignVertical.top
              : TextAlignVertical.center,
          style: const TextStyle(
            color: ColorsPalette.black,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
            filled: true,
            fillColor: ColorsPalette.white,
            prefixIcon: effectivePrefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: maxLines > 1 ? 16.0 : 14.0,
            ),
          ),
        ),
      ],
    );
  }
}
