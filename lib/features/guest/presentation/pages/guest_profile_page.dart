import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';

class GuestProfilePage extends StatelessWidget {
  const GuestProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorsPalette.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsPalette.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.9),
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
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            color: ColorsPalette.redComponents.withValues(
                              alpha: 0.08,
                            ),
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
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.accountType),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsPalette.redComponents,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              elevation: 4,
                              shadowColor: ColorsPalette.redComponents
                                  .withValues(alpha: 0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Criar Conta",
                                  style: AppText.botao(
                                    context,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  LucideIcons.chevronRight,
                                  color: Colors.white,
                                  size: AppIconSize.md,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.login);
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
                                      style: AppText.secundario(context)
                                          .copyWith(
                                            color: ColorsPalette.blackDetails,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
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
              const SizedBox(height: AppSpacing.md),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HowItWorksPage()),
                  );
                },
              ),
              buildListTile(
                context: context,
                icon: LucideIcons.fileText,
                title: "Termos de Uso e Privacidade",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TermosPage()),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SizedBox(height: 100.0),
            ],
          ),
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
                color: ColorsPalette.redComponents.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                size: AppIconSize.md,
                color: ColorsPalette.redComponents,
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
