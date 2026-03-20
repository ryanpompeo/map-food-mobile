import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/core/theme/radius.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:map_food/validators/form_validator.dart';

class NomeField extends StatelessWidget {
  final TextEditingController controller;

  const NomeField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
          child: Text("Nome", style: AppText.corpo(context)),
        ),

        /// Campo
        TextFormField(
          controller: controller,
          validator: FormValidator.nome,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          autofillHints: [AutofillHints.name],
          style: AppText.legenda(context).copyWith(color: ColorsPalette.preto),
          cursorColor: ColorsPalette.vermelhoComponents,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              borderSide: BorderSide(
                color: ColorsPalette.vermelhoComponents.withOpacity(0.8),
                width: 2,
              ),
            ),
            hintText: "Digite seu nome",
            hintStyle: AppText.legenda(
              context,
            ).copyWith(color: ColorsPalette.cinzaDetails),

            prefixIcon: Icon(
              LucideIcons.user,
              color: ColorsPalette.cinzaDetails,
              size: AppIconSize.normal.sp,
            ),

            filled: true,
            fillColor: ColorsPalette.brancoOff,
            contentPadding: EdgeInsets.symmetric(
              vertical: AppSpacing.md.h,
              horizontal: AppSpacing.xl.w,
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
