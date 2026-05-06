import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/core/theme/image_size.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/pages/logins/page_cadastro_conta_comercial.dart';
import 'package:map_food/pages/logins/page_cadastro_usuario.dart';
import 'package:map_food/widgets/option_card.dart';

class TipoConta extends StatelessWidget {
  const TipoConta({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.brancoBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.brancoBackground,
        elevation: 0,
        foregroundColor: ColorsPalette.brancoBackground,
        surfaceTintColor: ColorsPalette.brancoBackground,
        centerTitle: true,
        title: Text(
          "SELECIONE SEU PERFIL",
          style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            LucideIcons.chevronLeft,
            color: ColorsPalette.vermelhoComponents,
            size: AppIconSize.normal.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w,
              vertical: AppSpacing.md.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.lg.h),

                OptionCard(
                  isCustomer: true,

                  title: 'Cliente',
                  description: 'Descubra lojas incríveis perto de você',
                  benefits: [
                    'Localize comércios próximos',
                    'Avalie e salve favoritos',
                    'Receba recomendações personalizadas',
                  ],
                  buttonText: 'Entrar como Cliente',
                  isDark: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PageCadastroUsuario(),
                      ),
                    );
                  },
                ),

                SizedBox(height: AppSpacing.lg.h),

                OptionCard(
                  isCustomer: false,

                  title: 'Comerciante',
                  description: 'Gerencie seu negócio e alcance mais clientes',
                  benefits: const [
                    'Divulgue sua marca',
                    'Gerencie  e informações',
                    'Acompanhe avaliações',
                  ],
                  buttonText: 'Entrar como Comerciante',
                  isDark: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PageCadastroContaComercial(),
                      ),
                    );
                  },
                ),

                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
