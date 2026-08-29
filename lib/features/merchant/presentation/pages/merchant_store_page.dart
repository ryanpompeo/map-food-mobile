import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/menu_list_tile.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_operation_section.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_reviews_section.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/store_advanced_page.dart';
import 'package:map_food/features/store/presentation/pages/store_edit_page.dart';

/// O painel de quem administra a loja.
///
/// Une o que eram duas abas — a operação (abrir/fechar + mapa da ronda) e o
/// perfil público — porque elas nunca foram assuntos diferentes: são o mesmo
/// objeto, visto de dois lados. Separadas, a informação mais consultada do dia
/// (estou aberto? apareço onde?) ficava numa aba **ao lado** do lugar onde a
/// loja é administrada.
///
/// A organização é por frequência de uso, não por tipo de dado:
///
/// | camada | o quê | onde |
/// |---|---|---|
/// | imediata | abrir/fechar, posição no mapa | topo, sem rolagem |
/// | diária | dados, fotos, categorias | um toque → [StoreEditPage] |
/// | rara | inativar/excluir loja | dois toques → [StoreAdvancedPage] |
class MerchantStorePage extends StatefulWidget {
  final StoreDto store;

  /// Barra de troca de loja (comerciante com mais de uma) — renderizada no
  /// topo do body pra não colidir com o AppBar.
  final Widget? storeSwitcher;

  /// Loja alterada no backend (status, posição da ronda, edição salva).
  final ValueChanged<StoreDto>? onStoreUpdated;

  /// Loja excluída — quem hospeda precisa recarregar a lista, porque a loja
  /// desta tela deixou de existir.
  final VoidCallback? onStoreDeleted;

  const MerchantStorePage({
    super.key,
    required this.store,
    this.storeSwitcher,
    this.onStoreUpdated,
    this.onStoreDeleted,
  });

  @override
  State<MerchantStorePage> createState() => _MerchantStorePageState();
}

class _MerchantStorePageState extends State<MerchantStorePage> {
  late StoreDto _store;

  final _avaliacaoService = AvaliacaoService();
  final _storeService = StoreService();

  List<AvaliacaoModel> _avaliacoes = [];
  bool _carregandoAvaliacoes = true;
  double? _mediaAvaliacao;

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _carregarAvaliacoes();
    _carregarMedia();
  }

  @override
  void didUpdateWidget(covariant MerchantStorePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resincroniza com a versão mais recente vinda do pai. Aqui não há
    // formulário aberto para atropelar — este painel é leitura, e a edição
    // acontece numa rota empurrada por cima.
    if (widget.store.id == _store.id) {
      setState(() => _store = widget.store);
    } else {
      // Troca de loja pelo switcher: as avaliações são de outra loja agora.
      _store = widget.store;
      _recarregarDaLoja();
    }
  }

  void _recarregarDaLoja() {
    setState(() {
      _avaliacoes = [];
      _carregandoAvaliacoes = true;
      _mediaAvaliacao = null;
    });
    _carregarAvaliacoes();
    _carregarMedia();
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final avaliacoes = await _avaliacaoService.buscarAvaliacoesDaLoja(_store.id);
      if (mounted) setState(() => _avaliacoes = avaliacoes);
    } catch (_) {
      // Lista vazia com o aviso da própria seção — não derruba o painel.
    } finally {
      if (mounted) setState(() => _carregandoAvaliacoes = false);
    }
  }

  Future<void> _carregarMedia() async {
    try {
      final resumo = await _storeService.getResumo(_store.id);
      if (mounted) setState(() => _mediaAvaliacao = resumo.avaliacao);
    } catch (_) {
      // Mantém null ("Novo") se a busca falhar.
    }
  }

  Future<void> _abrirEdicao() async {
    final atualizada = await Navigator.push<StoreDto?>(
      context,
      appPageRoute(builder: (_) => StoreEditPage(store: _store)),
    );
    if (atualizada == null || !mounted) return;
    setState(() => _store = atualizada);
    widget.onStoreUpdated?.call(atualizada);
  }

  Future<void> _abrirAvancado() async {
    final excluida = await Navigator.push<bool?>(
      context,
      appPageRoute(
        builder: (_) => StoreAdvancedPage(
          store: _store,
          // Inativar por lá muda o status da mesma loja que o card de operação
          // está exibindo aqui — sem isso o painel voltaria mostrando "Loja
          // aberta" com a ronda ligada.
          onStoreUpdated: _onOperacaoAtualizou,
        ),
      ),
    );
    if (excluida == true) widget.onStoreDeleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: Spacing.lg,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Minha loja', style: AppText.caption(context)),
            Text(
              _store.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.h2(context),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (widget.storeSwitcher != null) ...[
            widget.storeSwitcher!,
            const SizedBox(height: Spacing.base),
          ],

          // ── imediata ──
          StoreOperationSection(store: _store, onStoreUpdated: _onOperacaoAtualizou),

          const SizedBox(height: Spacing.xxl),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: Spacing.xl),

          // ── diária ──
          _PerfilPublico(store: _store, onEditar: _abrirEdicao),

          const SizedBox(height: Spacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: StoreReviewsSection(
              avaliacoes: _avaliacoes,
              carregando: _carregandoAvaliacoes,
              media: _mediaAvaliacao,
            ),
          ),

          // ── rara ──
          const SizedBox(height: Spacing.xl),
          Divider(color: colors.divider, height: 1),
          MenuListTile(
            icon: AppIcons.gearSix,
            title: 'Configurações avançadas',
            subtitle: 'Inativar ou excluir a loja e situação do cadastro',
            onTap: _abrirAvancado,
          ),

          SizedBox(height: AppBottomBar.spaceFor(context) + Spacing.base),
        ],
      ),
    );
  }

  /// A ronda escreve na loja a cada deslocamento. O painel acompanha para o
  /// preview não ficar com o endereço de antes, e repassa para o pai.
  void _onOperacaoAtualizou(StoreDto atualizada) {
    if (mounted) setState(() => _store = atualizada);
    widget.onStoreUpdated?.call(atualizada);
  }
}

/// Como o cliente vê a loja — leitura pura, com um atalho para editar.
///
/// Nada de campo de formulário aqui: para **conferir** o nome da loja não faz
/// sentido montar um `TextField` desabilitado, que era o que a tela antiga
/// fazia e o que dava a uma página de consulta a cara de formulário quebrado.
class _PerfilPublico extends StatelessWidget {
  final StoreDto store;
  final VoidCallback onEditar;

  const _PerfilPublico({required this.store, required this.onEditar});

  String? get _enderecoFormatado {
    final partes = [
      store.endereco,
      [store.cidade, store.estado].where((p) => p?.isNotEmpty == true).join(' - '),
      store.cep,
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    return partes.isEmpty ? null : partes.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perfil da loja', style: AppText.h2(context)),
                    const SizedBox(height: 2),
                    Text(
                      'É assim que os clientes veem a sua loja.',
                      style: AppText.secondary(context).copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              AppButton(
                label: 'Editar',
                icon: AppIcons.pencilSimple,
                onPressed: onEditar,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
                expand: false,
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          _LinhaInfo(icone: AppIcons.storefront, rotulo: 'Nome', valor: store.nome),
          _LinhaInfo(
            icone: AppIcons.textAlignLeft,
            rotulo: 'Descrição',
            valor: store.descricao,
          ),
          _LinhaInfo(
            icone: AppIcons.mapPinLine,
            rotulo: 'Endereço',
            valor: _enderecoFormatado,
          ),
          _LinhaInfo(
            icone: AppIcons.forkKnife,
            rotulo: 'Categorias',
            valor: store.categoriaNomes.isEmpty ? null : store.categoriaNomes.join(', '),
          ),
        ],
      ),
    );
  }
}

/// Linha de consulta: rótulo pequeno em cima, valor com contraste embaixo.
///
/// Valor ausente vira "Não informado" em tom terciário em vez de espaço em
/// branco — vazio silencioso lê como falha de carregamento.
class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String? valor;

  const _LinhaInfo({required this.icone, required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final vazio = valor == null || valor!.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icone, size: AppIconSize.md, color: colors.textTertiary),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: AppText.caption(context)),
                const SizedBox(height: 2),
                Text(
                  vazio ? 'Não informado' : valor!,
                  style: AppText.body(context).copyWith(
                    height: 1.4,
                    color: vazio ? colors.textTertiary : colors.textPrimary,
                    fontWeight: vazio ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
