import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/core/theme/radius.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:map_food/widgets/app_button.dart';

Widget OptionCard({
  required String title,
  required String description,
  required List<String> benefits,
  required String buttonText,
  required bool isDark,
  required VoidCallback onTap,

  required bool isCustomer,
}) {
  return Builder(
    builder: (context) {
      final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.1);

      final Color cardColor = isCustomer
          ? ColorsPalette.pretoComponents
          : ColorsPalette.vermelhoComponents;

      return Container(
        padding: EdgeInsets.all(AppSpacing.lg.sp),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl.r),

          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCustomer ? "PERFIL COMUM" : "PERFIL COMERCIAL",
                  textScaleFactor: textScale,
                  style: AppText.legenda(context).copyWith(
                    color: ColorsPalette.branco.withOpacity(0.8),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: AppSpacing.xs.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsPalette.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCustomer ? LucideIcons.user2 : LucideIcons.store,
                    color: Colors.white,
                    size: AppIconSize.medium.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg.h),

            /// TÍTULO PRINCIPAL
            Text(
              title,
              textScaleFactor: textScale,
              style: AppText.titulo(
                context,
              ).copyWith(color: ColorsPalette.branco),
            ),

            SizedBox(height: AppSpacing.xs.h),

            /// DESCRIÇÃO
            Text(
              description,
              textScaleFactor: textScale,
              style: AppText.secundario(context).copyWith(
                color: ColorsPalette.branco.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 32.h),

            /// BENEFITS
            ...benefits.map((b) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      color: ColorsPalette.branco.withOpacity(0.6),
                      size: AppIconSize.small.sp,
                    ),

                    SizedBox(width: AppSpacing.sm.w),

                    Expanded(
                      child: Text(
                        b,
                        textScaleFactor: textScale,
                        textAlign: TextAlign.left,
                        style: AppText.legenda(context).copyWith(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          height:
                              1.2, // Mantém a altura da linha compacta para alinhar melhor
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: AppSpacing.xl.h),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: buttonText,
                onPressed: onTap,
                isDark: isDark,
              ),
            ),
          ],
        ),
      );
    },
  );
}
