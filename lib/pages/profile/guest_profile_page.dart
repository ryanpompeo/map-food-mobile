import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class GuestProfilePage extends StatelessWidget {
  const GuestProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: ColorsPalette.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Perfil",
          style: AppText.legenda(context).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: ColorsPalette.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsPalette.black.withOpacity(0.06),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(8, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(-6, -6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: ColorsPalette.redComponents.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.userPlus,
                          color: ColorsPalette.redComponents,
                          size: AppIconSize.lg,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "Faça parte do MapFood",
                        style: AppText.subtitulo(context).copyWith(
                          color: ColorsPalette.blackDetails,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Descubra novos sabores e salve favoritos, ou crie sua conta de parceiro para vender",
                        style: AppText.secundario(context).copyWith(
                          color: ColorsPalette.greyText,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

             
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/accountType',
                          ), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsPalette.redComponents,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            elevation: 4,
                            shadowColor: ColorsPalette.redComponents
                                .withOpacity(0.5),
                          ),
                          child: Text(
                            "Criar Conta",
                            style: AppText.botao(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                              horizontal: AppSpacing.md,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: "Já tem uma conta? ",
                                style: AppText.secundario(context).copyWith(
                                  color: ColorsPalette.greyText,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Entrar",
                                    style: AppText.secundario(context).copyWith(
                                      color: ColorsPalette.blackDetails,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                "Configurações",
                style: AppText.subtitulo(context).copyWith(fontSize: 18.0),
              ),
            ),
            buildListTile(
              context: context,
              icon: LucideIcons.moon,
              title: "Tema do Aplicativo",
              subtitle: "Claro, Escuro ou Sistema",
              onTap: () {},
            ),
            buildListTile(
              context: context,
              icon: LucideIcons.mapPin,
              title: "Permissões de Localização",
              subtitle: "Gerenciar acesso ao GPS",
              onTap: () {},
            ),
            const SizedBox(height: 16.0),
            Divider(
              color: Colors.grey.shade200,
              height: 1.0,
              indent: AppSpacing.lg,
              endIndent: AppSpacing.lg,
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                "Sobre o MapFood",
                style: AppText.subtitulo(context).copyWith(fontSize: 18.0),
              ),
            ),
            buildListTile(
              context: context,
              icon: LucideIcons.helpCircle,
              title: "Como funciona?",
              onTap: () {},
            ),
            buildListTile(
              context: context,
              icon: LucideIcons.fileText,
              title: "Termos de Uso e Privacidade",
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }

  Widget buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                icon,
                size: AppIconSize.md,
                color: ColorsPalette.blackDetails,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.corpo(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorsPalette.blackDetails,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: AppText.legenda(
                        context,
                      ).copyWith(color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: AppIconSize.sm,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
