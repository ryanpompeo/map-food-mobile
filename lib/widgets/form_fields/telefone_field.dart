import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/core/theme/radius.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:map_food/validators/form_validator.dart';

class TelefoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool comercio;

  bool isComercio(bool comercio) {
    if (comercio == true) {
      return true;
    } else {
      return false;
    }
  }

  TelefoneField({super.key, required this.controller, required this.comercio});

  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
          child: Text("Telefone", style: AppText.corpo(context)),
        ),

        TextFormField(
          controller: controller,
          validator: FormValidator.telefone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: [AutofillHints.telephoneNumber],
          inputFormatters: [telefoneMask],
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

            hintText: "(11) 91234-5678",
            hintStyle: AppText.legenda(
              context,
            ).copyWith(color: ColorsPalette.cinzaDetails),
            prefixIcon: Icon(
              LucideIcons.phone,
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
        SizedBox(height: AppSpacing.sm.h),

        isComercio(comercio)
            ? Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: ColorsPalette.vermelhoComponents,
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        surfaceTintColor: Colors.transparent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        
                      },

                      child: Text(
                        'Possui Telefone Fixo?',
                        style: AppText.legenda(context).copyWith(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )
            : Container(height: 0),
      ],
    );
  }
}
