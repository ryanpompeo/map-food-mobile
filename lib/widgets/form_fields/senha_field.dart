import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/core/theme/radius.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:map_food/validators/form_validator.dart';

class SenhaField extends StatefulWidget {
  final TextEditingController controller;

  const SenhaField({super.key, required this.controller});

  @override
  State<SenhaField> createState() => _SenhaFieldState();
}

class _SenhaFieldState extends State<SenhaField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
          child: Text("Senha", style: AppText.corpo(context)),
        ),

        TextFormField(
          controller: widget.controller,
          validator: FormValidator.senha,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          autofillHints: [AutofillHints.newPassword],

          obscureText: obscure,

          style: AppText.legenda(context).copyWith(color: ColorsPalette.preto),

          cursorColor: ColorsPalette.vermelhoComponents,

          decoration: InputDecoration(
            hintText: "Crie uma senha",

            hintStyle: AppText.legenda(
              context,
            ).copyWith(color: ColorsPalette.cinzaDetails),

            prefixIcon: Icon(
              LucideIcons.lock,
              color: ColorsPalette.cinzaDetails,
              size: AppIconSize.normal.sp,
            ),

            /// botão mostrar senha
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                color: ColorsPalette.cinzaDetails,
                size: AppIconSize.normal.sp,
              ),
              onPressed: () {
                setState(() {
                  obscure = !obscure;
                });
              },
            ),

            filled: true,
            fillColor: ColorsPalette.brancoBackground,

            contentPadding: EdgeInsets.symmetric(
              vertical: AppSpacing.md.h,
              horizontal: AppSpacing.xl.w,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              borderSide: BorderSide(
                color: ColorsPalette.vermelhoComponents.withOpacity(0.8),
                width: 2,
              ),
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
