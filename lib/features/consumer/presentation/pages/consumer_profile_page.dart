import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:map_food/core/services/auth_controller.dart';
import 'package:map_food/core/services/notification_service.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/widgets/account_deletion_dialog.dart';
import 'package:map_food/core/ui/widgets/theme_mode_selector_sheet.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_edit_profile.dart';
import 'package:map_food/features/favorites/presentation/pages/consumer_favorites_page.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';
import 'package:map_food/features/reviews/presentation/pages/consumer_complaints_page.dart';
import 'package:map_food/features/reviews/presentation/pages/consumer_review_page.dart';
import 'package:map_food/features/guest/presentation/pages/guest_home_page.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';

class ConsumerProfilePage extends StatelessWidget {
  const ConsumerProfilePage({super.key});

  void _logout(BuildContext context) {
    final colors = context.appColors;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: colors.surface,
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
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        color: colors.accent.withValues(
                          alpha: 0.15,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.logOut,
                        color: colors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Sair da conta",
                      style: AppText.titulo(
                        context,
                      ).copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Deseja realmente sair?",
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: colors.textPrimary),
                ),

                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancelar",
                        style: AppText.botao(
                          context,
                        ).copyWith(color: colors.textSecondary),
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
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.background,
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

  Future<void> _excluirConta(BuildContext context) async {
    final confirmado = await AccountDeletionDialog.show(context);
    if (!confirmado) return;

    final session = AuthController.instance.session;
    if (session == null) return;

    try {
      await ConsumerService().deleteAccount(session.id);
      await AuthController.instance.clear();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GuestHomePage()),
        (route) => false,
      );
      NotificationService.instance.success('Conta excluída definitivamente.');
    } catch (_) {
      if (!context.mounted) return;
      NotificationService.instance.error('Não foi possível excluir sua conta. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar, nome e e-mail centralizados — reativo ao
              // AuthController: assim que a edição de perfil salvar com
              // sucesso, esta seção atualiza sozinha, sem novo GET.
              AnimatedBuilder(
                animation: AuthController.instance,
                builder: (context, _) {
                  final session = AuthController.instance.session;
                  final nome = session?.nome ?? '';
                  final email = session?.email ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Column(
                      children: [
                        Container(
                          height: 80.0,
                          width: 80.0,
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              nome.isNotEmpty ? nome[0].toUpperCase() : 'U',
                              style: AppText.titulo(context).copyWith(
                                fontSize: 32,
                                color: colors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          nome,
                          style: AppText.subtitulo(context).copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          email,
                          style: AppText.secundario(context).copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
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
                icon: LucideIcons.heart,
                title: "Meus Favoritos",
                subtitle: "Comércios que você salvou",
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
                icon: LucideIcons.userCog,
                title: "Editar Perfil",
                subtitle: "Altere seus dados e senha",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsumerEditProfile(),
                    ),
                  );
                },
              ),

              // Real a partir da Fase 9 (GET /avaliacoes/consumidor/{id}).
              buildListTile(
                context: context,
                icon: LucideIcons.star,
                title: "Minhas avaliações",
                subtitle: "Lojas que você avaliou",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConsumerReviewPage(),
                    ),
                  );
                },
              ),
              buildListTile(
                context: context,
                icon: LucideIcons.flag,
                title: "Minhas denuncias",
                subtitle: "Acompanhe a situação de suas denuncias",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConsumerComplaintsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),
              Divider(
                color: colors.divider,
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
                onTap: () => ThemeModeSelectorSheet.show(context),
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
                color: colors.divider,
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermosPage()),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),
              Divider(
                color: colors.divider,
                height: 1.0,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              const SizedBox(height: AppSpacing.md),

              buildListTile(
                context: context,
                icon: LucideIcons.logOut,
                title: "Sair da conta",
                onTap: () => _logout(context),
              ),

              const SizedBox(height: AppSpacing.md),
              Divider(
                color: colors.divider,
                height: 1.0,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              const SizedBox(height: AppSpacing.md),

              // Danger Zone — única seção em vermelho da tela inteira.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Text(
                  "Zona de Risco",
                  style: AppText.subtitulo(context).copyWith(fontSize: 18.0, color: colors.error),
                ),
              ),
              InkWell(
                onTap: () => _excluirConta(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                        ),
                        child: Icon(LucideIcons.trash2, size: AppIconSize.md, color: colors.error),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Excluir minha conta",
                              style: AppText.corpo(context)
                                  .copyWith(fontWeight: FontWeight.w700, color: colors.error),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              "Ação permanente e irreversível",
                              style: AppText.legenda(context).copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.chevronRight, size: AppIconSize.sm, color: colors.textSecondary.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
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
    final colors = context.appColors;
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
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.divider),
              ),
              child: Icon(
                icon,
                size: AppIconSize.md,
                color: colors.accent,
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
                      color: colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: AppText.legenda(
                        context,
                      ).copyWith(color: colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: AppIconSize.sm,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
