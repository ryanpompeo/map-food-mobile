import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/pages/auth/widgets/option_card.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        foregroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Selecione o tipo de conta",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            LucideIcons.chevronLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.lg),

                optionCard(
                  context: context,
                  isCustomer: true,
                  title: 'Cliente',
                  description: 'Descubra lojas incríveis perto de você',
                  benefits: [
                    'Localize comércios próximos',
                    'Avalie e salve favoritos',
                    'Receba recomendações personalizadas',
                  ],
                  buttonText: 'Seja um Cliente',
                  isDark: true,
                  onTap: () {
                    Navigator.pushNamed(context, '/consumerRegister');
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                optionCard(
                  context: context,
                  isCustomer: false,
                  title: 'Comerciante',
                  description: 'Gerencie seu negócio e alcance mais clientes',
                  benefits: const [
                    'Divulgue sua marca no mapa',
                    'Gerencie informações da barraca',
                    'Acompanhe avaliações',
                  ],
                  buttonText: 'Seja um Comerciante',
                  isDark: false,
                  onTap: () {
                    Navigator.pushNamed(context, '/merchantRegister');
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
