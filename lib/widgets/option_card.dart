import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/radius.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget OptionCard({
  required String title,
  required String description,
  required List<String> benefits,
  required String buttonText,
  required bool isDark,
  required VoidCallback onTap,
  required Icon? icon,
}) {
  return Builder(
    builder: (context) {
      final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.2);

      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),

        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),

          decoration: BoxDecoration(
            color: ColorsPalette.branco,
            borderRadius: BorderRadius.circular(AppRadius.xl),

            boxShadow: [
              BoxShadow(
                color: ColorsPalette.preto.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: ColorsPalette.preto.withOpacity(0.10),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorsPalette.vermelhoComponents.withOpacity(0.20),
                  ),
                  color: ColorsPalette.vermelhoComponents.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: icon,
              ),

              SizedBox(height: AppSpacing.md.h),

              /// TITLE
              Text(
                title,
                textScaleFactor: textScale,
                style: AppText.subtitulo(context),
              ),
              SizedBox(height: AppSpacing.sm),

              /// DESCRIPTION
              Text(
                description,
                textScaleFactor: textScale,
                style: AppText.secundario(context),
              ),

              SizedBox(height: AppSpacing.md.h),

              /// BENEFITS
              ...benefits.map((b) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.checkCircle2,
                        color: ColorsPalette.vermelhoComponents,
                        size: 18,
                      ),

                      SizedBox(width: AppSpacing.sm.w),

                      Expanded(
                        child: Text(
                          b,
                          textScaleFactor: textScale,
                          style: AppText.legenda(context),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: AppSpacing.lg),

              /// BUTTON
              SizedBox(
                width: double.infinity.w,
                height: AppSpacing.xxxl.h,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? ColorsPalette.pretoComponents
                        : ColorsPalette.vermelhoComponents,
                    foregroundColor: ColorsPalette.branco,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg.r),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          buttonText,
                          textScaleFactor: textScale,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.secundario(context).copyWith(
                            color: ColorsPalette.branco,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
