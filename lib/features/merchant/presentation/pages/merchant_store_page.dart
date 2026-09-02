import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/app_refresh.dart';
import 'package:map_food/core/ui/widgets/menu_list_tile.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_operation_section.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_reviews_section.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/store_advanced_page.dart';
import 'package:map_food/features/store/presentation/pages/store_edit_page.dart';

class MerchantStorePage extends StatefulWidget {
  final StoreDto store;

  final Widget? storeSwitcher;

  final ValueChanged<StoreDto>? onStoreUpdated;

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
    if (widget.store.id == _store.id) {
      setState(() => _store = widget.store);
    } else {
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

  Future<void> _recarregar() async {
    await Future.wait([_carregarAvaliacoes(), _carregarMedia()]);
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final avaliacoes = await _avaliacaoService.buscarAvaliacoesDaLoja(
        _store.id,
      );
      if (mounted) setState(() => _avaliacoes = avaliacoes);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _carregandoAvaliacoes = false);
    }
  }

  Future<void> _carregarMedia() async {
    try {
      final resumo = await _storeService.getResumo(_store.id);
      if (mounted) setState(() => _mediaAvaliacao = resumo.avaliacao);
    } catch (_) {
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
      body: AppRefresh(
        onRefresh: _recarregar,
        child: ListView(
          physics: AppRefresh.physics,
          padding: EdgeInsets.zero,
          children: [
            if (widget.storeSwitcher != null) ...[
              widget.storeSwitcher!,
              const SizedBox(height: Spacing.base),
            ],

            StoreOperationSection(
              store: _store,
              onStoreUpdated: _onOperacaoAtualizou,
            ),

            const SizedBox(height: Spacing.xxl),

            _PerfilPublico(store: _store, onEditar: _abrirEdicao),

            const SizedBox(height: Spacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: StoreReviewsSection(
                avaliacoes: _avaliacoes,
                carregando: _carregandoAvaliacoes,
                media: _mediaAvaliacao,
              ),
            ),

            const SizedBox(height: Spacing.xxl),
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
      ),
    );
  }

  void _onOperacaoAtualizou(StoreDto atualizada) {
    if (mounted) setState(() => _store = atualizada);
    widget.onStoreUpdated?.call(atualizada);
  }
}

class _PerfilPublico extends StatelessWidget {
  final StoreDto store;
  final VoidCallback onEditar;

  const _PerfilPublico({required this.store, required this.onEditar});

  String? get _enderecoFormatado {
    final partes = [
      store.endereco,
      [
        store.cidade,
        store.estado,
      ].where((p) => p?.isNotEmpty == true).join(' - '),
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
          const SizedBox(height: Spacing.base),

          AppCard(
            elevation: AppCardElevation.flat,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _LinhaInfo(
                  icone: AppIcons.storefront,
                  rotulo: 'Nome',
                  valor: store.nome,
                ),
                const _SeparadorInterno(),
                _LinhaInfo(
                  icone: AppIcons.textAlignLeft,
                  rotulo: 'Descrição',
                  valor: store.descricao,
                ),
                const _SeparadorInterno(),
                _LinhaInfo(
                  icone: AppIcons.mapPinLine,
                  rotulo: 'Endereço',
                  valor: _enderecoFormatado,
                ),
                const _SeparadorInterno(),
                _LinhaInfo(
                  icone: AppIcons.forkKnife,
                  rotulo: 'Categorias',
                  valor: store.categoriaNomes.isEmpty
                      ? null
                      : store.categoriaNomes.join(', '),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeparadorInterno extends StatelessWidget {
  const _SeparadorInterno();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: Spacing.base + AppIconSize.md + Spacing.md,
      color: context.mapColors.divider,
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String? valor;

  const _LinhaInfo({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final vazio = valor == null || valor!.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.all(Spacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icone,
              size: AppIconSize.md,
              color: colors.textTertiary,
            ),
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
