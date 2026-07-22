import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/session/session_manager.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/core/ui/widgets/profile_stat_card.dart';
import 'package:map_food/core/ui/widgets/stacked_card_carousel.dart';
import 'package:map_food/core/ui/widgets/theme_mode_sheet.dart';
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
/// itens de "Minha Conta", a página de "Como funciona" e as métricas/
/// carrossel de destaque no topo (favoritos para consumidor, lojas próprias
/// para comerciante).
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

  /// Toque em qualquer um dos círculos de avatar — abre "Editar Perfil".
  final VoidCallback onAvatarTap;

  /// Cards de estatística do app (dias de uso, avaliações, denúncias...).
  final Future<List<ProfileStat>> Function() fetchStats;

  /// Título da seção de destaque abaixo dos cards ("Meus Favoritos" para
  /// consumidor, "Minhas Lojas" para comerciante).
  final String featuredSectionTitle;
  final Future<List<StackedCardItem>> Function() fetchFeaturedItems;
  final ValueChanged<StackedCardItem> onFeaturedItemTap;

  /// Toque em "ver tudo" ao lado do título da seção de destaque — null
  /// esconde o link (ex: comerciante não tem uma tela de listagem própria).
  final VoidCallback? onVerTudoFeatured;

  /// Texto do estado vazio da seção de destaque.
  final String featuredEmptyMessage;

  /// Notifica quando a seção de destaque deve ser buscada de novo (ex:
  /// `FavoritesManager.instance` no consumidor) — sem isso, a busca roda só
  /// uma vez no `initState`, e como esta página vive dentro de um
  /// `IndexedStack` (nunca é recriada ao trocar de aba), favoritar/
  /// desfavoritar em outra aba deixava esta seção com uma foto antiga —
  /// inclusive mostrando uma loja já desfavoritada.
  final Listenable? featuredRefreshListenable;

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
    required this.onAvatarTap,
    required this.fetchStats,
    required this.featuredSectionTitle,
    required this.fetchFeaturedItems,
    required this.onFeaturedItemTap,
    this.onVerTudoFeatured,
    required this.featuredEmptyMessage,
    this.featuredRefreshListenable,
  });

  @override
  State<ProfilePageScaffold> createState() => _ProfilePageScaffoldState();
}

class _ProfilePageScaffoldState extends State<ProfilePageScaffold> {
  String? _imagemUrl;
  List<ProfileStat>? _stats;
  List<StackedCardItem>? _featuredItems;

  @override
  void initState() {
    super.initState();
    _carregarFoto();
    _carregarStats();
    _carregarFeatured();
    widget.featuredRefreshListenable?.addListener(_carregarFeatured);
  }

  @override
  void dispose() {
    widget.featuredRefreshListenable?.removeListener(_carregarFeatured);
    super.dispose();
  }

  Future<void> _carregarFoto() async {
    try {
      final imagemUrl = await widget.fetchImagemUrl();
      if (mounted) setState(() => _imagemUrl = imagemUrl);
    } catch (_) {
      // Mantém o fallback com as iniciais do nome.
    }
  }

  Future<void> _carregarStats() async {
    try {
      final stats = await widget.fetchStats();
      if (mounted) setState(() => _stats = stats);
    } catch (_) {
      // Mantém os placeholders "—" se a API falhar.
    }
  }

  Future<void> _carregarFeatured() async {
    try {
      final items = await widget.fetchFeaturedItems();
      if (mounted) setState(() => _featuredItems = items);
    } catch (_) {
      if (mounted) setState(() => _featuredItems = []);
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
          backgroundColor: context.mapColors.cardSurface,
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
                  style: AppText.corpo(context).copyWith(color: context.mapColors.primaryText),
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
                        style: AppText.botao(context).copyWith(color: context.mapColors.secondaryText),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      // backgroundColor/foregroundColor ficam de propósito
                      // como literais: é um CTA sólido preto/branco que deve
                      // parecer o mesmo nos dois temas, não uma superfície
                      // que se adapta ao brightness.
                      onPressed: () async {
                        await AuthStorage.clear();
                        // Sempre roda, pros dois papéis — não depende de a
                        // tela chamadora lembrar de passar onLogoutExtra
                        // (foi exatamente esse esquecimento, no perfil do
                        // comerciante, que deixava FavoritesManager vazando
                        // dados de uma conta pra outra no mesmo aparelho).
                        SessionManager.clearUserScopedState();
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
      SessionManager.clearUserScopedState();
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
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              ProfileStatsRow(stats: _stats),
              const SizedBox(height: AppSpacing.xl),
              _buildFeaturedSection(context),

              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle(context, "Minha Conta"),
              for (final item in widget.minhaContaItems)
                _buildListTile(
                  context: context,
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap: item.onTap,
                ),

              _buildDivider(context),

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

              _buildDivider(context),

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

              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
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
              ),

              const SizedBox(height: AppSpacing.xxl),
              const SizedBox(height: 100.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final resolvedImagemUrl = resolveImagemUrl(_imagemUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bem-vindo!",
                  style: AppText.secundario(context).copyWith(
                    color: context.mapColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitulo(context).copyWith(
                    color: context.mapColors.primaryText,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: widget.onAvatarTap,
            child: Container(
              height: 56.0,
              width: 56.0,
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
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => showThemeModeSheet(context),
            // Isolamento de rebuild: só este ícone escuta o
            // ThemeController — o resto do header (nome, avatar) não
            // reconstrói quando o usuário troca de tema.
            child: ListenableBuilder(
              listenable: ThemeController.instance,
              builder: (context, _) {
                final mode = ThemeController.instance.value;
                final isDark = mode == ThemeMode.dark ||
                    (mode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(context) == Brightness.dark);
                return Container(
                  height: 56.0,
                  width: 56.0,
                  decoration: BoxDecoration(
                    color: context.mapColors.cardSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDark ? PhosphorIconsRegular.moon : PhosphorIconsRegular.sun,
                    color: context.mapColors.iconMuted,
                    size: AppIconSize.lg,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.featuredSectionTitle,
                style: AppText.subtitulo(context).copyWith(fontSize: 18.0, fontWeight: FontWeight.w800),
              ),
              if (widget.onVerTudoFeatured != null)
                GestureDetector(
                  onTap: widget.onVerTudoFeatured,
                  child: Text(
                    "ver tudo",
                    style: AppText.legenda(context).copyWith(
                      color: ColorsPalette.redComponents,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFeaturedContent(context),
      ],
    );
  }

  Widget _buildFeaturedContent(BuildContext context) {
    final items = _featuredItems;
    if (items == null) {
      return const SizedBox(
        height: 190.0,
        child: Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents)),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.mapColors.cardSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.mapColors.border),
          ),
          child: Text(
            widget.featuredEmptyMessage,
            textAlign: TextAlign.center,
            style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText),
          ),
        ),
      );
    }
    return StackedCardCarousel(
      items: items,
      onTap: widget.onFeaturedItemTap,
      horizontalPadding: AppSpacing.xl,
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

  Widget _buildDivider(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Divider(color: context.mapColors.border, height: 1.0, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
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
              child: Icon(icon, size: AppIconSize.lg, color: iconColor ?? context.mapColors.primaryText),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w600, color: context.mapColors.primaryText),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(subtitle, style: AppText.legenda(context).copyWith(color: context.mapColors.secondaryText)),
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
