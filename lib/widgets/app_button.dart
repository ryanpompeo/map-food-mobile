import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/radius.dart';
import 'package:map_food/core/theme/spacing.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDark;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDark = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.2);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppSpacing.xxxl.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          backgroundColor: isDark
              ? ColorsPalette.pretoComponents
              : ColorsPalette.vermelhoComponents,
          foregroundColor: ColorsPalette.branco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
          ),
          elevation: 1,
        ),
        child: Text(
          text,
          textScaleFactor: textScale,
          overflow: TextOverflow.visible,

          style: AppText.botao(context),
        ),
      ),
    );
  }
}
