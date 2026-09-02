import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_refresh.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/app_info.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/core/ui/widgets/logout_dialog.dart';
import 'package:map_food/core/ui/widgets/menu_list_tile.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/stacked_card_carousel.dart';
import 'package:map_food/core/ui/widgets/theme_mode_sheet.dart';
import 'package:map_food/features/settings/presentation/pages/settings_page.dart';

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  final Color? iconColor;
  final Color? iconBackgroundColor;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });
}

class ProfilePageScaffold extends StatefulWidget {
  final String userName;
  final String userEmail;

  final Future<String?> Function() fetchImagemUrl;

  final List<ProfileMenuItem> minhaContaItems;
  final WidgetBuilder howItWorksPageBuilder;

  final VoidCallback? onLogoutExtra;

  final Future<void> Function()? onDeleteAccount;

  final VoidCallback onAvatarTap;

  final String featuredSectionTitle;
  final Future<List<StackedCardItem>> Function() fetchFeaturedItems;
  final ValueChanged<StackedCardItem> onFeaturedItemTap;

  final VoidCallback? onVerTudoFeatured;

  final String featuredEmptyMessage;
  final String featuredEmptyTitle;
  final IconData featuredEmptyIcon;

  final String? featuredEmptyActionLabel;
  final VoidCallback? onFeaturedEmptyAction;

  final Listenable? featuredRefreshListenable;

  final Future<void> Function()? onRefreshExtra;

  const ProfilePageScaffold({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.fetchImagemUrl,
    required this.minhaContaItems,
    required this.howItWorksPageBuilder,
    this.onLogoutExtra,
    this.onDeleteAccount,
    required this.onAvatarTap,
    required this.featuredSectionTitle,
    required this.fetchFeaturedItems,
    required this.onFeaturedItemTap,
    this.onVerTudoFeatured,
    required this.featuredEmptyMessage,
    required this.featuredEmptyTitle,
    required this.featuredEmptyIcon,
    this.featuredEmptyActionLabel,
    this.onFeaturedEmptyAction,
    this.featuredRefreshListenable,
    this.onRefreshExtra,
  });

  @override
  State<ProfilePageScaffold> createState() => _ProfilePageScaffoldState();
}

class _ProfilePageScaffoldState extends State<ProfilePageScaffold> {
  String? _imagemUrl;
  List<StackedCardItem>? _featuredItems;

  @override
  void initState() {
    super.initState();
    _carregarFoto();
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

  Future<void> _recarregar() async {
    await Future.wait([
      _carregarFoto(),
      _carregarFeatured(),
      if (widget.onRefreshExtra != null) widget.onRefreshExtra!(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.background,
      body: SafeArea(
        child: AppRefresh(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: AppRefresh.physics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.base),
                _buildHeader(context),
                const SizedBox(height: Spacing.xl),
                _buildFeaturedSection(context),

                const SizedBox(height: Spacing.xl),
                _buildMenuList(context),

                const SizedBox(height: Spacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: AppButton(
                    label: 'Sair da conta',
                    icon: AppIcons.signOut,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => mostrarDialogoLogout(
                      context,
                      onLogoutExtra: widget.onLogoutExtra,
                    ),
                  ),
                ),

                const SizedBox(height: Spacing.lg),
                Center(
                  child: Text(
                    'Versão $kAppVersion',
                    style: AppText.caption(context),
                  ),
                ),

                const SizedBox(height: Spacing.xxl),
                const SizedBox(height: 100.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final resolvedImagemUrl = resolveImagemUrl(_imagemUrl);
    const avatarSize = 72.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SemanticTapArea(
            label: 'Foto do perfil',
            hint: 'Abre a edição do perfil',
            onTap: widget.onAvatarTap,
            child: Container(
              height: avatarSize,
              width: avatarSize,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.mapColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: AppNetworkImage(
                path: resolvedImagemUrl,
                displayWidth: avatarSize,
                fallback: _buildAvatarInitial(context),
              ),
            ),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.h1(context).copyWith(
                    color: context.mapColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.secondary(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          SemanticTapArea(
            label: 'Tema do aplicativo',
            hint: 'Escolhe entre claro, escuro e o do sistema',
            onTap: () => showThemeModeSheet(context),
            child: ListenableBuilder(
              listenable: ThemeController.instance,
              builder: (context, _) {
                final mode = ThemeController.instance.value;
                final isDark =
                    mode == ThemeMode.dark ||
                    (mode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark);
                return Container(
                  height: 44.0,
                  width: 44.0,
                  decoration: BoxDecoration(
                    color: context.mapColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDark ? AppIcons.moon : AppIcons.sun,
                    color: context.mapColors.textTertiary,
                    size: AppIconSize.md,
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
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.featuredSectionTitle,
                style: AppText.h2(
                  context,
                ).copyWith(fontSize: 18.0, fontWeight: FontWeight.w800),
              ),
              if (widget.onVerTudoFeatured != null)
                SemanticTapArea(
                  label: 'Ver tudo',
                  hint: widget.featuredSectionTitle,
                  onTap: widget.onVerTudoFeatured,
                  child: Text(
                    "ver tudo",
                    style: AppText.caption(context).copyWith(
                      color: context.mapColors.brandContent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.base),
        _buildFeaturedContent(context),
      ],
    );
  }

  Widget _buildFeaturedContent(BuildContext context) {
    final items = _featuredItems;
    if (items == null) {
      return SizedBox(
        height: escalaComTeto(context, 220.0),
        child: const Center(
          child: CircularProgressIndicator(color: ColorsPalette.redComponents),
        ),
      );
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: widget.featuredEmptyIcon,
        title: widget.featuredEmptyTitle,
        description: widget.featuredEmptyMessage,
        actionLabel: widget.featuredEmptyActionLabel,
        onAction: widget.onFeaturedEmptyAction,
        dense: true,
      );
    }
    return StackedCardCarousel(
      items: items,
      onTap: widget.onFeaturedItemTap,
      horizontalPadding: Spacing.xl,
    );
  }

  Widget _buildAvatarInitial(BuildContext context) {
    return Center(
      child: Text(
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
        style: AppText.h1(context).copyWith(
          color: context.mapColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        const MenuSectionLabel(label: "Minha Conta"),
        for (var i = 0; i < widget.minhaContaItems.length; i++) ...[
          if (i > 0)
            Divider(
              color: context.mapColors.border,
              height: 1.0,
              indent: Spacing.lg,
              endIndent: Spacing.lg,
            ),
          MenuListTile(
            icon: widget.minhaContaItems[i].icon,
            title: widget.minhaContaItems[i].title,
            subtitle: widget.minhaContaItems[i].subtitle,
            onTap: widget.minhaContaItems[i].onTap,
            iconColor: widget.minhaContaItems[i].iconColor,
            iconBackgroundColor: widget.minhaContaItems[i].iconBackgroundColor,
          ),
        ],
        const SizedBox(height: Spacing.lg),
        const MenuSectionLabel(label: "Configurações"),
        MenuListTile(
          icon: AppIcons.gearSix,
          title: "Configurações",
          subtitle: "Aparência, permissões, conta e termos",
          onTap: () => Navigator.push(
            context,
            appPageRoute(
              builder: (_) => SettingsPage(
                onDeleteAccount: widget.onDeleteAccount,
                onLogoutExtra: widget.onLogoutExtra,
                howItWorksPageBuilder: widget.howItWorksPageBuilder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
