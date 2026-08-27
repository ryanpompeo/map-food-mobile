import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
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
import 'package:map_food/core/ui/widgets/profile_stat_card.dart';
import 'package:map_food/core/ui/widgets/stacked_card_carousel.dart';
import 'package:map_food/core/ui/widgets/theme_mode_sheet.dart';
import 'package:map_food/features/settings/presentation/pages/settings_page.dart';

/// Item de menu da seção "Minha Conta" — a única parte da tela de perfil
/// que difere de verdade entre consumidor e comerciante.
class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Cor de destaque opcional (ex: vermelho pra "Excluir conta") — null usa
  /// o tratamento neutro padrão da lista.
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

  /// Estado vazio da seção de destaque. Um vazio que só constata ("nada
  /// aqui") faz o app parecer abandonado; com ícone, título e uma ação, ele
  /// vira o primeiro passo — por isso os quatro campos, não só a frase.
  final String featuredEmptyMessage;
  final String featuredEmptyTitle;
  final IconData featuredEmptyIcon;

  /// Rótulo e ação do botão do estado vazio — `null` nos dois deixa o bloco
  /// só informativo.
  final String? featuredEmptyActionLabel;
  final VoidCallback? onFeaturedEmptyAction;

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
    required this.featuredEmptyTitle,
    required this.featuredEmptyIcon,
    this.featuredEmptyActionLabel,
    this.onFeaturedEmptyAction,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.base),
              _buildHeader(context),
              const SizedBox(height: Spacing.lg),
              ProfileStatsRow(stats: _stats),
              const SizedBox(height: Spacing.xl),
              _buildFeaturedSection(context),

              const SizedBox(height: Spacing.xl),
              _buildMenuList(context),

              const SizedBox(height: Spacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                // Sair não é ação primária (ninguém abre o perfil para sair)
                // nem destrutiva — é `secondary`. Antes cada papel pintava o
                // botão de um jeito: preto sólido no consumidor, vermelho
                // desbotado no comerciante, sem que a diferença significasse
                // nada.
                child: AppButton(
                  label: 'Sair da conta',
                  icon: AppIcons.signOut,
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      mostrarDialogoLogout(context, onLogoutExtra: widget.onLogoutExtra),
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
    );
  }

  /// Cabeçalho inspirado no padrão avatar-à-esquerda + nome em destaque de
  /// apps de referência (ex: iFood) — substitui a saudação genérica
  /// "Bem-vindo!" pelo e-mail, que é informação de verdade sobre a conta.
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
                // Superfície do tema, não a cor de papel a 10%: no escuro,
                // um fundo `ink`/vermelho tão diluído somia contra a tela e
                // levava a inicial junto.
                color: context.mapColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: resolvedImagemUrl != null
                  ? Image.network(
                      resolvedImagemUrl,
                      fit: BoxFit.cover,
                      // Só cacheWidth: com os dois definidos o decoder
                      // ignora a proporção original e estica a imagem.
                      cacheWidth: (avatarSize * MediaQuery.devicePixelRatioOf(context)).round(),
                      errorBuilder: (context, error, stackTrace) => _buildAvatarInitial(context),
                    )
                  : _buildAvatarInitial(context),
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
                  style: AppText.secondary(context).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          SemanticTapArea(
            label: 'Tema do aplicativo',
            hint: 'Escolhe entre claro, escuro e o do sistema',
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
                style: AppText.h2(context).copyWith(fontSize: 18.0, fontWeight: FontWeight.w800),
              ),
              if (widget.onVerTudoFeatured != null)
                SemanticTapArea(
                  label: 'Ver tudo',
                  hint: widget.featuredSectionTitle,
                  onTap: widget.onVerTudoFeatured,
                  child: Text(
                    "ver tudo",
                    style: AppText.caption(context).copyWith(
                      // `brandContent`: vermelho como texto sobre a superfície
                      // da tela — no escuro o tom puro rende 3,28:1.
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
      // Mesma altura do carrossel que vai ocupar este espaço, escalada junto
      // com ele — um placeholder parado faria a página pular ao carregar.
      return SizedBox(
        height: escalaComTeto(context, 220.0),
        child: const Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents)),
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

  /// Duas seções rotuladas — "Minha Conta" (os atalhos que variam por papel)
  /// e "Configurações" (uma única porta de entrada pra [SettingsPage]).
  ///
  /// Antes era uma lista única achatada de seis itens, que misturava atalhos
  /// de conteúdo do usuário ("Minhas avaliações") com ajustes do app
  /// ("Permissões de Localização", "Termos") sem nenhuma separação — os
  /// quatro itens de ajuste migraram pra tela dedicada.
  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        const MenuSectionLabel(label: "Minha Conta"),
        for (var i = 0; i < widget.minhaContaItems.length; i++) ...[
          if (i > 0)
            Divider(color: context.mapColors.border, height: 1.0, indent: Spacing.lg, endIndent: Spacing.lg),
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
