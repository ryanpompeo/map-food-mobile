import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/features/guest/presentation/pages/guest_home_page.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';

/// Item de menu da seção "Minha Conta" — a única parte da tela de perfil
/// que difere de verdade entre consumidor e comerciante.
class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

/// Scaffold genérico de perfil, compartilhado entre consumidor e comerciante
/// — as duas telas eram ~85% código idêntico, variando só cor de destaque,
/// itens de "Minha Conta" e a página de "Como funciona".
class ProfilePageScaffold extends StatefulWidget {
  final String userName;
  final String userEmail;

  /// Busca a sessão salva e devolve a imagemUrl do usuário (ou null).
  final Future<String?> Function() fetchImagemUrl;

  final Color avatarColor;
  final Color logoutBackgroundColor;
  final Color logoutForegroundColor;

  final List<ProfileMenuItem> minhaContaItems;
  final WidgetBuilder howItWorksPageBuilder;

  /// Hook extra no logout (ex: limpar favoritos do consumidor).
  final VoidCallback? onLogoutExtra;

  /// Exclui a conta no backend (DELETE /comerciantes|consumidores/{id}) —
  /// hard delete definitivo nos dois papéis, mesmo endpoint usado pela Web.
  final Future<void> Function() onDeleteAccount;

  const ProfilePageScaffold({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.fetchImagemUrl,
    required this.avatarColor,
    required this.logoutBackgroundColor,
    required this.logoutForegroundColor,
    required this.minhaContaItems,
    required this.howItWorksPageBuilder,
    this.onLogoutExtra,
    required this.onDeleteAccount,
  });

  @override
  State<ProfilePageScaffold> createState() => _ProfilePageScaffoldState();
}

class _ProfilePageScaffoldState extends State<ProfilePageScaffold> {
  String? _imagemUrl;

  @override
  void initState() {
    super.initState();
    _carregarFoto();
  }

  Future<void> _carregarFoto() async {
    try {
      final imagemUrl = await widget.fetchImagemUrl();
      if (mounted) setState(() => _imagemUrl = imagemUrl);
    } catch (_) {
      // Mantém o fallback com as iniciais do nome.
    }
  }

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
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        color: ColorsPalette.redComponents.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        PhosphorIconsRegular.signOut,
                        color: ColorsPalette.redComponents,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Sair da conta",
                      style: AppText.titulo(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Deseja realmente sair?",
                  style: AppText.corpo(context).copyWith(color: ColorsPalette.black),
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
                        style: AppText.botao(context).copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: () async {
                        await AuthStorage.clear();
                        widget.onLogoutExtra?.call();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          appPageRoute(builder: (context) => GuestHomePage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsPalette.black,
                        foregroundColor: ColorsPalette.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                      ),
                      child: const Text("Sair", style: TextStyle(fontWeight: FontWeight.bold)),
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
    final confirmou = await confirmarExclusaoConta(context);
    if (!confirmou || !context.mounted) return;

    try {
      await widget.onDeleteAccount();
      await AuthStorage.clear();
      widget.onLogoutExtra?.call();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        appPageRoute(builder: (context) => GuestHomePage()),
        (route) => false,
      );
    } catch (_) {
      if (context.mounted) {
        AppToast.error(context, "Erro ao excluir a conta. Tente novamente.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedImagemUrl = resolveImagemUrl(_imagemUrl);

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
                      border: Border.all(width: 1.5, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 64.0,
                              width: 64.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: widget.avatarColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: resolvedImagemUrl != null
                                  ? Image.network(
                                      resolvedImagemUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _buildAvatarInitial(context),
                                    )
                                  : _buildAvatarInitial(context),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userName,
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
                                    widget.userEmail,
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
                            onPressed: () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.logoutBackgroundColor,
                              foregroundColor: widget.logoutForegroundColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(PhosphorIconsRegular.signOut, size: 20.0),
                                const SizedBox(width: 8.0),
                                Text(
                                  "Sair da conta",
                                  style: AppText.botao(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: widget.logoutForegroundColor,
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

              _buildSectionTitle(context, "Minha Conta"),
              for (final item in widget.minhaContaItems)
                _buildListTile(
                  context: context,
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap: item.onTap,
                ),

              _buildDivider(),

              _buildSectionTitle(context, "Configurações"),
              _buildListTile(
                context: context,
                icon: PhosphorIconsRegular.mapPin,
                title: "Permissões de Localização",
                subtitle: "Gerenciar acesso ao GPS",
                onTap: () => Geolocator.openAppSettings(),
              ),
              _buildListTile(
                context: context,
                icon: PhosphorIconsRegular.trash,
                iconColor: ColorsPalette.redComponents,
                iconBackgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.1),
                title: "Excluir conta",
                subtitle: "Apaga sua conta e dados permanentemente",
                onTap: () => _excluirConta(context),
              ),

              _buildDivider(),

              _buildSectionTitle(context, "Sobre o MapFood"),
              _buildListTile(
                context: context,
                icon: PhosphorIconsRegular.question,
                title: "Como funciona?",
                onTap: () {
                  Navigator.push(context, appPageRoute(builder: widget.howItWorksPageBuilder));
                },
              ),
              _buildListTile(
                context: context,
                icon: PhosphorIconsRegular.fileText,
                title: "Termos de Uso e Privacidade",
                onTap: () {
                  Navigator.push(context, appPageRoute(builder: (_) => const TermosPage()));
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

  Widget _buildAvatarInitial(BuildContext context) {
    return Center(
      child: Text(
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
        style: AppText.titulo(context).copyWith(color: widget.avatarColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Text(titulo, style: AppText.subtitulo(context).copyWith(fontSize: 18.0)),
    );
  }

  Widget _buildDivider() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Divider(color: Colors.grey.shade200, height: 1.0, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBackgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: AppIconSize.lg, color: iconColor ?? ColorsPalette.blackDetails),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.blackDetails),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(subtitle, style: AppText.legenda(context).copyWith(color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight, size: AppIconSize.sm, color: ColorsPalette.redComponents.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}
