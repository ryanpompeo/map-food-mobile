import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/consumer/consumer_favorites_page.dart';
import 'package:map_food/pages/guest/guest_home_page.dart';
import 'package:map_food/pages/guest/profile/how_it_works_page.dart';

class ConsumerProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ConsumerProfilePage({
    super.key,
    this.userName = 'Nome do Usuária',
    this.userEmail = 'usuario@email.com',
  });
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorsPalette.redComponents.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.logOut,
                        color: ColorsPalette.redComponents,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Sair da conta",
                      style: AppText.titulo(
                        context,
                      ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Deseja realmente sair?",
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.black),
                ),

                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: ColorsPalette.transparent,
                        surfaceTintColor: ColorsPalette.transparent,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancelar",
                        style: AppText.botao(
                          context,
                        ).copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuestHomePage(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsPalette.black,
                        foregroundColor: ColorsPalette.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: const Text(
                        "Sair",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                        Row(
                          children: [
                            // Avatar do Usuário
                            Container(
                              height: 64.0,
                              width: 64.0,
                              decoration: BoxDecoration(
                                color: ColorsPalette.redComponents.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'U',
                                  style: AppText.titulo(context).copyWith(
                                    color: ColorsPalette.redComponents,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Nome e E-mail
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: AppText.subtitulo(context).copyWith(
                                      color: ColorsPalette.blackDetails,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    userEmail,
                                    style: AppText.secundario(context).copyWith(
                                      color: ColorsPalette.greyText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        SizedBox(
                          width: double.infinity,
                          height: 48.0,
                          child: ElevatedButton(
                            onPressed: () {
                              _logout(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsPalette.redComponents
                                  .withValues(alpha: 0.1),
                              foregroundColor: ColorsPalette.redComponents,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.logOut, size: 20.0),
                                const SizedBox(width: 8.0),
                                Text(
                                  "Sair da conta",
                                  style: AppText.botao(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: ColorsPalette.redComponents,
                                  ),
                                ),
                              ],
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
                  "Minha Conta",
                  style: AppText.subtitulo(context).copyWith(fontSize: 18.0),
                ),
              ),
              buildListTile(
                context: context,
                icon: LucideIcons.userCog,
                title: "Editar Perfil",
                subtitle: "Altere seus dados e senha",
                onTap: () {},
              ),
              buildListTile(
                context: context,
                icon: LucideIcons.heart,
                title: "Meus Favoritos",
                subtitle: "Lojas que você salvou",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsumerFavoritesPage(),
                    ),
                  );
                },
              ),
              buildListTile(
                context: context,
                icon: LucideIcons.star,
                title: "Minhas avaliações",
                subtitle: "Lojas que você avaliou",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsumerFavoritesPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),
              Divider(
                color: Colors.grey.shade200,
                height: 1.0,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              const SizedBox(height: AppSpacing.md),

              // Configurações
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

              // Sobre
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
                    MaterialPageRoute(builder: (_) => const HowItWorksPage()),
                  );
                },
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
