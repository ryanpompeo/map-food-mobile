import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/widgets/option_card.dart';

class TipoConta extends StatelessWidget {
  const TipoConta({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.2);
    return Scaffold(
      backgroundColor: ColorsPalette.brancoBackground,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),

          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w,
              vertical: AppSpacing.md.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.md.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: ColorsPalette.preto,
                        size: AppIconSize.normal.sp,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Selecionar conta",
                          style: AppText.subtitulo(context),
                        ),
                      ),
                    ),

                    SizedBox(width: AppSpacing.xxl.w),
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  "Comece sua experiência conosco",
                  textAlign: TextAlign.center,
                  textScaleFactor: textScale,
                  style: AppText.display(context).copyWith(
                    foreground: Paint()
                      ..shader = LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsPalette.pretoDegrade1,
                          ColorsPalette.marromDegrade2,
                          ColorsPalette.vermelhoDegrade3,
                        ],
                      ).createShader(Rect.fromLTWH(0, 0, 280.w, 50.h)),
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'Junte-se à comunidade e descubra novas experiências gastronômicas',
                  textAlign: TextAlign.center,
                  textScaleFactor: textScale,
                  style: AppText.corpo(context),
                ),

                SizedBox(height: AppSpacing.xxl.h),

                OptionCard(
                  icon: Icon(
                    LucideIcons.radar,
                    color: ColorsPalette.vermelhoComponents,
                    size: AppIconSize.large,
                  ),
                  title: 'Explorador',
                  description: 'Descubra lojas incríveis perto de você',
                  benefits: const [
                    'Localize comércios próximos',
                    'Avalie e salve favoritos',
                    'Receba recomendações personalizadas',
                  ],
                  buttonText: 'Entrar como Cliente',
                  isDark: true,
                  onTap: () {},
                ),

                SizedBox(height: 24.h),

                OptionCard(
                  icon: const Icon(
                    LucideIcons.shoppingBag,
                    color: Color(0xFFE33E33),
                    size: 32,
                  ),
                  title: 'Estabelecimento',
                  description:
                      'Gerencie seu restaurante e alcance mais clientes.',
                  benefits: const [
                    'Divulgue seu restaurante',
                    'Gerencie cardápio e informações',
                    'Acompanhe avaliações',
                  ],
                  buttonText: 'Entrar como Vendedor',
                  isDark: false,
                  onTap: () {},
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
