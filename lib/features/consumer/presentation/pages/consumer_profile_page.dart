import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/app_info.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/session/session_store.dart';
// AuthStorage continua aqui só por `diasNoApp()`: é uma marca local do
// aparelho (não faz parte da sessão) e por isso não migra para o SessionStore.
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

/// Perfil do consumidor. Não usa mais o `ProfilePageScaffold` (que segue
/// servindo o comerciante): a tela foi redesenhada em torno de **atividade**
/// — um card com a métrica em destaque, o gráfico da série e os números
/// resumidos —, com o resto do conteúdo distribuído em três abas de texto no
/// lugar da rolagem única de antes.
///
/// Nada saiu: favoritos (com "ver tudo"), Editar Perfil, Minhas avaliações,
/// Minhas denúncias, Configurações, trocar tema e Sair continuam todos aqui,
/// só que agrupados por assunto.
class ConsumerProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  /// Chamado ao voltar da tela de Editar Perfil, pra quem construiu esta
  /// página poder recarregar nome/e-mail/foto — o card de perfil não
  /// atualiza sozinho porque os dados vêm de fora via [userName]/[userEmail].
  final VoidCallback? onProfileUpdated;

  /// Leva para a aba de busca — usado pelo estado vazio de favoritos, que
  /// precisa oferecer o próximo passo em vez de só constatar o vazio.
  final VoidCallback? onExplorarTap;

  /// `true` enquanto esta é a aba exibida. Esta página vive num `IndexedStack`
  /// — construída uma vez no login e nunca descartada —, então o `initState`
  /// não serve como gatilho de atualização: sem este aviso, o gráfico de
  /// atividade e os contadores ficariam parados no retrato do login, sem
  /// refletir avaliações e denúncias feitas depois.
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

  /// Datas das avaliações do consumidor — fonte única do gráfico e do
  /// contador "Lojas avaliadas". Null enquanto carrega.
  List<DateTime>? _datasAvaliacoes;

  /// Evita cargas concorrentes: voltar de "Minhas avaliações" já dispara uma
  /// recarga, e mudar de aba logo em seguida dispararia outra por cima.
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

  /// Toda vez que a aba volta a ser exibida, os números são buscados de novo —
  /// é o que faz uma avaliação recém-enviada aparecer no gráfico sem exigir
  /// que o app seja reiniciado.
  void _aoMudarVisibilidade() {
    if (widget.visivel?.value ?? false) _carregarAtividade();
  }

  Future<void> _carregarFoto() async {
    try {
      final userId = SessionStore.instance.userId;
      if (userId == null) return;
      final data = await ConsumerService().getById(userId);
      if (mounted) setState(() => _imagemUrl = data.imagemUrl);
    } catch (_) {
      // Mantém o fallback com as iniciais do nome.
    }
  }

  /// Rebusca os números da aba Atividade. Os campos só são sobrescritos
  /// quando a nova resposta chega — nada é zerado no início —, então uma
  /// recarga não faz o gráfico piscar de volta pro estado de carregamento.
  Future<void> _carregarAtividade() async {
    if (_carregandoAtividade) return;
    _carregandoAtividade = true;

    try {
      try {
        final dias = await AuthStorage.diasNoApp();
        if (mounted) setState(() => _diasNoApp = dias);
      } catch (_) {
        // Linha do resumo fica em "—"; não pode impedir a busca do gráfico.
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
          // Só na primeira carga: numa recarga que falhou, manter a série que
          // já estava na tela é melhor do que trocá-la por "sem avaliações".
          setState(() => _datasAvaliacoes = const []);
        }
      }

      // Denúncias entram só como número no resumo — falha aqui não pode
      // derrubar o gráfico, que é o conteúdo principal da aba.
      try {
        final userId = SessionStore.instance.userId;
        if (userId == null) return;
        final denuncias = await DenunciaService().getMyComplaints(userId);
        if (mounted) setState(() => _totalDenuncias = denuncias.length);
      } catch (_) {
        // Deixa o resumo mostrando "—" pra essa linha.
      }
    } finally {
      _carregandoAtividade = false;
    }
  }

  /// Abre uma tela e rebusca os números da Atividade ao voltar dela.
  Future<void> _abrirERecarregar(WidgetBuilder builder) async {
    await Navigator.push(context, appPageRoute(builder: builder));
    // Recarga em segundo plano: `_carregarAtividade` já é reentrante (guard
    // `_carregandoAtividade`) e trata os próprios erros por bloco.
    if (mounted) unawaited(_carregarAtividade());
  }

  Future<void> _abrirEditarPerfil() async {
    await Navigator.push(
      context,
      appPageRoute(builder: (context) => ConsumerEditProfile()),
    );
    widget.onProfileUpdated?.call();
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
              _buildTabs(context),
              const SizedBox(height: Spacing.lg),
              switch (_abaSelecionada) {
                0 => _buildAbaAtividade(context),
                1 => _buildAbaFavoritos(context),
                _ => _buildAbaConta(context),
              },
              // Respiro pra bottom bar flutuante da ConsumerHomePage.
              const SizedBox(height: 120.0),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── cabeçalho e abas ─────────────────────────

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
                // Isolamento de rebuild: só este ícone escuta o
                // ThemeController — nome, avatar e abas não reconstroem
                // quando o usuário troca de tema.
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
        // Superfície do tema, não o preto da marca a 10%: no escuro aquele
        // fundo ficava indistinguível da tela, e a inicial (também `ink`)
        // sumia junto.
        color: context.mapColors.surfaceAlt,
        shape: BoxShape.circle,
      ),
      // Sem foto (ou com foto quebrada), o "vazio" deste avatar não é um
      // ícone: é a inicial do nome.
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

  /// Abas de texto com indicador embaixo do rótulo ativo, sobre uma linha
  /// contínua fina — em vez de `TabBar`/`TabController`, que traria um
  /// `TickerProvider` e uma view paginada só pra alternar três colunas.
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
                  // A aba ativa se distingue pelo traço vermelho embaixo do
                  // rótulo — marcação de posição, não de cor —, mais o peso da
                  // fonte. Faltava anunciar o "selecionado".
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

  // ───────────────────────── aba: atividade ─────────────────────────

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
        // As duas linhas abaixo levam à tela que produz o número. Como essas
        // telas editam/excluem avaliações e denúncias, a volta passa por
        // `_abrirERecarregar` — senão o contador aqui continuaria mostrando o
        // total de antes da exclusão.
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
    // O visual (incluindo o `selectedSurface`, que inverte no tema escuro pra
    // o chip ativo não sumir) vive no AppChoiceChip.
    return AppChoiceChip(
      label: periodo.label,
      selected: _periodo == periodo,
      onTap: () => setState(() => _periodo = periodo),
    );
  }

  Widget _buildCardCarregando(BuildContext context) {
    return Container(
      // Placeholder do card de atividade: acompanha a escala pelo mesmo motivo
      // que o card real — senão a tela encolhe no instante em que os dados
      // chegam e o conteúdo "pula".
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

  /// Linha de "Seus números". Com [onTap], ela vira o atalho para a tela que
  /// origina aquele número — "Lojas avaliadas" abre as avaliações, "Denúncias
  /// feitas" abre as denúncias.
  ///
  /// Um número numa lista é uma pergunta implícita ("quais?"), e a resposta
  /// estava a três toques daqui, escondida na aba Conta. O chevron é o que
  /// avisa que a linha responde — sem ele, a diferença entre a linha clicável
  /// e a de "Dias no app" (que não leva a lugar nenhum, porque não existe
  /// tela de "dias") só apareceria depois do toque.
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
            // "—" enquanto carrega ou quando a chamada falhou — mesmo
            // placeholder que os cards de estatística já usavam.
            valor?.toString() ?? '—',
            style: AppText.h2(context).copyWith(
              fontWeight: FontWeight.w900,
              color: context.mapColors.textPrimary,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: Spacing.sm),
            // Decorativo: quem usa leitor de tela já ouve que a linha é um
            // botão pelo SemanticTapArea que a envolve.
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

  // ───────────────────────── aba: favoritos ─────────────────────────

  Widget _buildAbaFavoritos(BuildContext context) {
    // Escuta o FavoritesManager direto: favoritar/desfavoritar em outra aba
    // precisa refletir aqui na hora — era exatamente esse o bug que o
    // `featuredRefreshListenable` do scaffold antigo resolvia.
    return ListenableBuilder(
      listenable: FavoritesManager.instance,
      builder: (context, _) {
        final favoritos = FavoritesManager.instance.favorites;
        final erro = FavoritesManager.instance.errorMessage;

        // Falha de carga não pode se disfarçar de "nenhum favorito ainda": o
        // estado vazio convida a explorar, e é a orientação errada para quem
        // tem favoritos salvos e está só sem rede.
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
          // Estado vazio com saída: sem o botão, a aba dizia "não há nada" e
          // deixava a pessoa sem o que fazer a respeito — é o que faz um app
          // novo parecer abandonado.
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
                        // `brandContent`: vermelho como texto sobre a
                        // superfície da tela.
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
                        // Categoria e nota são o que diferencia um favorito do
                        // outro numa pilha — o nome sozinho obriga a abrir a
                        // loja pra lembrar do que se trata.
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
    // `precacheCapaDaLoja` em vez de `abrirDetalheDaLoja`: esta navegação
    // precisa recarregar a lista ao voltar (dá pra avaliar a loja lá dentro, e
    // sair daqui e voltar não passa pelo aviso de visibilidade — a aba nunca
    // deixou de ser a exibida), e quem faz isso é o `_abrirERecarregar`.
    precacheCapaDaLoja(context, store);
    _abrirERecarregar((_) => MoreInfoStorePage(store: store!));
  }

  // ─────────────────────────── aba: conta ───────────────────────────

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
        // Estas duas telas editam/excluem avaliações e denúncias, ou seja,
        // mexem justamente nos números da aba Atividade — por isso a recarga
        // ao voltar, sem esperar o usuário sair e entrar na aba de novo.
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
                // Sem onLogoutExtra: `SessionManager.clearUserScopedState()`
                // (chamado dentro do fluxo de exclusão) já limpa os
                // favoritos — passar de novo aqui seria limpeza em dobro.
                howItWorksPageBuilder: (_) => const HowItWorksPage(),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          // `inverse`: sair não é ação primária (ninguém abre o perfil para
          // sair) nem destrutiva — é o CTA neutro forte, e o token inverte
          // sozinho no tema escuro, onde o preto sólido sumia no fundo.
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
