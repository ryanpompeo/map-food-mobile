import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_refresh.dart';
import 'package:map_food/core/app_info.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/core/ui/widgets/logout_dialog.dart';
import 'package:map_food/core/ui/widgets/menu_list_tile.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/widgets/stacked_card_carousel.dart';
import 'package:map_food/core/ui/widgets/theme_mode_sheet.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/avaliacoes/presentation/pages/consumer_review_page.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';
import 'package:map_food/features/consumer/presentation/controllers/activity_summary.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_edit_profile.dart';
import 'package:map_food/features/contato/presentation/pages/contato_page.dart';
import 'package:map_food/core/ui/widgets/delta_badge.dart';
import 'package:map_food/features/consumer/presentation/widgets/activity_chart.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/denuncias/presentation/pages/consumer_complaints_page.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/favorites/presentation/pages/consumer_favorites_page.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/features/settings/presentation/pages/settings_page.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class ConsumerProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  final VoidCallback? onProfileUpdated;

  final VoidCallback? onExplorarTap;

  final ValueListenable<bool>? visivel;

  const ConsumerProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.onProfileUpdated,
    this.onExplorarTap,
    this.visivel,
  });

  @override
  State<ConsumerProfilePage> createState() => _ConsumerProfilePageState();
}

class _ConsumerProfilePageState extends State<ConsumerProfilePage> {
  int _abaSelecionada = 0;
  ActivityPeriod _periodo = ActivityPeriod.mes;

  String? _imagemUrl;
  int? _diasNoApp;
  int? _totalDenuncias;

  List<DateTime>? _datasAvaliacoes;

  bool _carregandoAtividade = false;

  @override
  void initState() {
    super.initState();
    _carregarFoto();
    _carregarAtividade();
    widget.visivel?.addListener(_aoMudarVisibilidade);
  }

  @override
  void dispose() {
    widget.visivel?.removeListener(_aoMudarVisibilidade);
    super.dispose();
  }

  void _aoMudarVisibilidade() {
    if (!(widget.visivel?.value ?? false)) return;
    _carregarAtividade();
    unawaited(FavoritesManager.instance.load());
  }

  Future<void> _carregarFoto() async {
    try {
      final userId = SessionStore.instance.userId;
      if (userId == null) return;
      final data = await ConsumerService().getById(userId);
      if (mounted) setState(() => _imagemUrl = data.imagemUrl);
    } catch (_) {
    }
  }

  Future<void> _carregarAtividade() async {
    if (_carregandoAtividade) return;
    _carregandoAtividade = true;

    try {
      try {
        final dias = await AuthStorage.diasNoApp();
        if (mounted) setState(() => _diasNoApp = dias);
      } catch (_) {
      }

      try {
        final avaliacoes = await AvaliacaoService().getMinhasAvaliacoes();
        if (mounted) {
          setState(() {
            _datasAvaliacoes = avaliacoes
                .map((a) => DateTime.tryParse(a.dataAvaliacao ?? ''))
                .whereType<DateTime>()
                .toList();
          });
        }
      } catch (_) {
        if (mounted && _datasAvaliacoes == null) {
          setState(() => _datasAvaliacoes = const []);
        }
      }

      try {
        final userId = SessionStore.instance.userId;
        if (userId == null) return;
        final denuncias = await DenunciaService().getMyComplaints(userId);
        if (mounted) setState(() => _totalDenuncias = denuncias.length);
      } catch (_) {
      }
    } finally {
      _carregandoAtividade = false;
    }
  }

  Future<void> _abrirERecarregar(WidgetBuilder builder) async {
    await Navigator.push(context, appPageRoute(builder: builder));
    if (mounted) unawaited(_carregarAtividade());
  }

  Future<void> _abrirEditarPerfil() async {
    await Navigator.push(
      context,
      appPageRoute(builder: (context) => ConsumerEditProfile()),
    );
    widget.onProfileUpdated?.call();
  }

  Future<void> _recarregar() async {
    await Future.wait([
      _carregarFoto(),
      _carregarAtividade(),
      FavoritesManager.instance.load(),
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
                const SizedBox(height: Spacing.lg),
                _buildTabs(context),
                const SizedBox(height: Spacing.lg),
                switch (_abaSelecionada) {
                  0 => _buildAbaAtividade(context),
                  1 => _buildAbaFavoritos(context),
                  _ => _buildAbaConta(context),
                },
                const SizedBox(height: 120.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Perfil",
                  style: AppText.display(context).copyWith(
                    color: context.mapColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    fontSize: 28.0,
                  ),
                ),
              ),
              SemanticTapArea(
                label: 'Tema do aplicativo',
                hint: 'Escolhe entre claro, escuro e o do sistema',
                onTap: () => showThemeModeSheet(context),
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
                        border: Border.all(color: context.mapColors.border),
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
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              SemanticTapArea(
                label: 'Foto do perfil',
                hint: 'Abre a edição do perfil',
                onTap: _abrirEditarPerfil,
                child: _buildAvatar(context),
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
                      style: AppText.h2(context).copyWith(
                        color: context.mapColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        fontSize: 18.0,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    const tamanho = 56.0;
    return Container(
      height: tamanho,
      width: tamanho,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.mapColors.surfaceAlt,
        shape: BoxShape.circle,
      ),
      child: AppNetworkImage(
        path: _imagemUrl,
        displayWidth: tamanho,
        fallback: _buildAvatarInicial(context),
      ),
    );
  }

  Widget _buildAvatarInicial(BuildContext context) {
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

  Widget _buildTabs(BuildContext context) {
    const abas = ['Atividade', 'Favoritos', 'Conta'];

    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Positioned(
          left: Spacing.lg,
          right: Spacing.lg,
          bottom: 0,
          child: Container(height: 1.0, color: context.mapColors.border),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              for (var i = 0; i < abas.length; i++)
                SemanticTapArea(
                  label: abas[i],
                  selected: _abaSelecionada == i,
                  onTap: () => setState(() => _abaSelecionada = i),
                  child: Padding(
                    padding: EdgeInsets.only(right: i == abas.length - 1 ? 0 : Spacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            abas[i],
                            style: AppText.body(context).copyWith(
                              fontSize: 15.0,
                              fontWeight: _abaSelecionada == i ? FontWeight.w800 : FontWeight.w500,
                              color: _abaSelecionada == i
                                  ? context.mapColors.textPrimary
                                  : context.mapColors.textSecondary,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3.0,
                          width: _abaSelecionada == i ? 28.0 : 0.0,
                          decoration: BoxDecoration(
                            color: ColorsPalette.redComponents,
                            borderRadius: BorderRadius.circular(Radii.pill),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAbaAtividade(BuildContext context) {
    final datas = _datasAvaliacoes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              for (final periodo in ActivityPeriod.values) ...[
                if (periodo != ActivityPeriod.values.first) const SizedBox(width: Spacing.sm),
                _buildChipPeriodo(context, periodo),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: datas == null
              ? _buildCardCarregando(context)
              : _buildCardAtividade(context, resumirAtividade(datas, _periodo)),
        ),
        const SizedBox(height: Spacing.xl),
        const MenuSectionLabel(label: "Seus números"),
        _buildLinhaResumo(
          context,
          icon: AppIcons.calendarBlank,
          label: "Dias no app",
          valor: _diasNoApp,
        ),
        _buildLinhaResumo(
          context,
          icon: AppIcons.star,
          label: "Lojas avaliadas",
          valor: datas?.length,
          hint: 'Abre suas avaliações',
          onTap: () => _abrirERecarregar((_) => ConsumerReviewPage()),
        ),
        _buildLinhaResumo(
          context,
          icon: AppIcons.flag,
          label: "Denúncias feitas",
          valor: _totalDenuncias,
          hint: 'Abre suas denúncias',
          onTap: () => _abrirERecarregar((_) => const ConsumerComplaintsPage()),
        ),
      ],
    );
  }

  Widget _buildChipPeriodo(BuildContext context, ActivityPeriod periodo) {
    return AppChoiceChip(
      label: periodo.label,
      selected: _periodo == periodo,
      onTap: () => setState(() => _periodo = periodo),
    );
  }

  Widget _buildCardCarregando(BuildContext context) {
    return Container(
      height: escalaComTeto(context, 240.0),
      decoration: _decoracaoCard(context),
      child: const Center(
        child: CircularProgressIndicator(color: ColorsPalette.redComponents),
      ),
    );
  }

  Widget _buildCardAtividade(BuildContext context, ActivitySummary resumo) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: _decoracaoCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Avaliações que você fez",
            style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${resumo.total}',
                style: AppText.display(context).copyWith(
                  color: context.mapColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              if (resumo.deltaPercentual != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: DeltaBadge(percentual: resumo.deltaPercentual!),
                ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          ActivityChart(points: resumo.points),
        ],
      ),
    );
  }

  BoxDecoration _decoracaoCard(BuildContext context) {
    return BoxDecoration(
      color: context.mapColors.surface,
      borderRadius: BorderRadius.circular(Radii.xl),
      border: Border.all(color: context.mapColors.border),
    );
  }

  Widget _buildLinhaResumo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int? valor,
    VoidCallback? onTap,
    String? hint,
  }) {
    final linha = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.base),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: context.mapColors.surface,
              border: Border.all(color: context.mapColors.border),
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Icon(icon, size: AppIconSize.md, color: context.mapColors.textPrimary),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Text(
              label,
              style: AppText.body(context).copyWith(
                fontWeight: FontWeight.w600,
                color: context.mapColors.textPrimary,
              ),
            ),
          ),
          Text(
            valor?.toString() ?? '—',
            style: AppText.h2(context).copyWith(
              fontWeight: FontWeight.w900,
              color: context.mapColors.textPrimary,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: Spacing.sm),
            ExcludeSemantics(
              child: Icon(
                AppIcons.caretRight,
                size: AppIconSize.md,
                color: context.mapColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return linha;

    return SemanticTapArea(label: label, hint: hint, onTap: onTap, child: linha);
  }

  Widget _buildAbaFavoritos(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesManager.instance,
      builder: (context, _) {
        final favoritos = FavoritesManager.instance.favorites;
        final erro = FavoritesManager.instance.errorMessage;

        if (erro != null && favoritos.isEmpty) {
          return EmptyState(
            icon: AppIcons.wifiSlash,
            title: 'Não foi possível carregar',
            description: erro,
            actionLabel: 'Tentar novamente',
            onAction: () => FavoritesManager.instance.load(),
            tone: EmptyStateTone.error,
            dense: true,
          );
        }

        if (favoritos.isEmpty) {
          return EmptyState(
            icon: AppIcons.heart,
            title: 'Nenhum favorito ainda',
            description: 'Toque no coração de um comércio para salvá-lo aqui.',
            actionLabel: 'Explorar comércios',
            onAction: widget.onExplorarTap,
            dense: true,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${favoritos.length} ${favoritos.length == 1 ? 'comércio salvo' : 'comércios salvos'}",
                    style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SemanticTapArea(
                    label: 'Ver tudo',
                    hint: 'Abre a lista completa de favoritos',
                    onTap: () => Navigator.push(
                      context,
                      appPageRoute(builder: (context) => ConsumerFavoritesPage()),
                    ),
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
            StackedCardCarousel(
              items: favoritos
                  .map((store) => StackedCardItem(
                        id: store.id,
                        title: store.nome,
                        imageUrl: resolveImagemUrl(store.capaUrl),
                        subtitle: store.categoriaNomes.isNotEmpty
                            ? store.categoriaNomes.first
                            : (store.categoria.isNotEmpty ? store.categoria : null),
                        rating: store.avaliacao,
                      ))
                  .toList(),
              onTap: (item) => _abrirLojaFavorita(context, item),
              horizontalPadding: Spacing.xl,
            ),
          ],
        );
      },
    );
  }

  void _abrirLojaFavorita(BuildContext context, StackedCardItem item) {
    StoreDto? store;
    for (final lojaFavoritada in FavoritesManager.instance.favorites) {
      if (lojaFavoritada.id == item.id) {
        store = lojaFavoritada;
        break;
      }
    }
    if (store == null) {
      AppToast.error(context, "Não foi possível abrir esta loja.");
      return;
    }
    precacheCapaDaLoja(context, store);
    _abrirERecarregar((_) => MoreInfoStorePage(store: store!));
  }

  Widget _buildAbaConta(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MenuSectionLabel(label: "Minha Conta"),
        MenuListTile(
          icon: AppIcons.userGear,
          title: "Editar Perfil",
          subtitle: "Altere seus dados e senha",
          onTap: _abrirEditarPerfil,
        ),
        Divider(color: context.mapColors.border, height: 1.0, indent: Spacing.lg, endIndent: Spacing.lg),
        MenuListTile(
          icon: AppIcons.star,
          title: "Minhas avaliações",
          subtitle: "Lojas que você avaliou",
          onTap: () => _abrirERecarregar((_) => ConsumerReviewPage()),
        ),
        Divider(color: context.mapColors.border, height: 1.0, indent: Spacing.lg, endIndent: Spacing.lg),
        MenuListTile(
          icon: AppIcons.flag,
          title: "Minhas denuncias",
          subtitle: "Acompanhe a situação de suas denuncias",
          onTap: () => _abrirERecarregar((_) => const ConsumerComplaintsPage()),
        ),
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
                onDeleteAccount: () async {
                  final userId = SessionStore.instance.userId;
                  if (userId == null) return;
                  await ConsumerService().delete(userId);
                },
                howItWorksPageBuilder: (_) => const HowItWorksPage(),
              ),
            ),
          ),
        ),
        Divider(color: context.mapColors.border, height: 1.0, indent: Spacing.lg, endIndent: Spacing.lg),
        MenuListTile(
          icon: AppIcons.envelope,
          title: "Fale conosco",
          subtitle: "Envie dúvidas ou sugestões para a equipe",
          onTap: () => Navigator.push(
            context,
            appPageRoute(builder: (_) => const ContatoPage()),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: AppButton(
            label: 'Sair da conta',
            icon: AppIcons.signOut,
            variant: AppButtonVariant.inverse,
            onPressed: () => mostrarDialogoLogout(context),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Center(child: Text('Versão $kAppVersion', style: AppText.caption(context))),
      ],
    );
  }
}
