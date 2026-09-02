import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/app_refresh.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/consumer_review_section.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/section_header.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/store_detail_hero.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/store_detail_overview.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/store_gallery_strip.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/store_reviews_section.dart';

void precacheCapaDaLoja(BuildContext context, StoreDto store) {
  unawaited(
    AppNetworkImage.precache(
      context,
      store.capaUrl,
      displayWidth: StoreDetailHero.larguraDaCapa(context),
    ),
  );
}

Future<void> abrirDetalheDaLoja(BuildContext context, StoreDto store) {
  precacheCapaDaLoja(context, store);
  return Navigator.push(
    context,
    appPageRoute(builder: (_) => MoreInfoStorePage(store: store)),
  );
}

class MoreInfoStorePage extends StatefulWidget {
  final StoreDto store;

  const MoreInfoStorePage({super.key, required this.store});

  @override
  State<MoreInfoStorePage> createState() => _MoreInfoStorePageState();
}

class _MoreInfoStorePageState extends State<MoreInfoStorePage> {
  final AvaliacaoService _avaliacaoService = AvaliacaoService();
  final StoreService _storeService = StoreService();

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoadingRatings = true;
  String? _ratingsError;

  int _totalConhecido = 0;

  int get _totalExibido =>
      _isLoadingRatings ? _totalConhecido : _avaliacoes.length;

  double? _mediaAvaliacao;

  String get _userRole => SessionStore.instance.role;

  bool get _podeAvaliar => _userRole == 'CONSUMIDOR' || _userRole == 'GUEST';

  final ValueNotifier<bool> _hasUnsavedReview = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _mediaAvaliacao = widget.store.avaliacao;
    _totalConhecido = widget.store.totalAvaliacoes;
    _carregarAvaliacoes();
    _carregarResumoLoja();
  }

  @override
  void dispose() {
    _hasUnsavedReview.dispose();
    super.dispose();
  }

  void _onReviewUnsavedChanged(bool value) {
    if (_hasUnsavedReview.value != value) _hasUnsavedReview.value = value;
  }

  Future<void> _carregarAvaliacoes() async {
    final mostrarCarregando = _ratingsError != null || _avaliacoes.isEmpty;
    if (mostrarCarregando && !_isLoadingRatings) {
      setState(() => _isLoadingRatings = true);
    }
    try {
      final ratings = await _avaliacaoService.buscarAvaliacoesDaLoja(
        widget.store.id,
      );
      if (!mounted) return;
      setState(() {
        _avaliacoes = ratings;
        _ratingsError = null;
        _isLoadingRatings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ratingsError = 'Não foi possível carregar as avaliações.';
        _isLoadingRatings = false;
      });
    }
  }

  Future<void> _carregarResumoLoja() async {
    try {
      final resumo = await _storeService.getResumo(widget.store.id);
      if (!mounted) return;
      setState(() {
        _mediaAvaliacao = resumo.avaliacao;
        _totalConhecido = resumo.totalAvaliacoes;
      });
    } catch (_) {
    }
  }

  Future<void> _recarregar() async {
    await Future.wait([_carregarAvaliacoes(), _carregarResumoLoja()]);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final colors = context.mapColors;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedReview,
      child: Scaffold(
        backgroundColor: colors.background,
        body: AppRefresh(
          onRefresh: _recarregar,
          child: CustomScrollView(
            physics: AppRefresh.physics,
            slivers: [
              StoreDetailHero(store: store),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.xxxl,
                ),
                sliver: SliverList.list(
                  children: [
                    StoreStatsRow(
                      store: store,
                      media: _mediaAvaliacao,
                      total: _totalExibido,
                    ),
                    const SizedBox(height: Spacing.base),
                    StoreCategoryChips(store: store),
                    const SizedBox(height: Spacing.lg),
                    StoreActionsRow(store: store, userRole: _userRole),

                    const SizedBox(height: Spacing.xxl),
                    SectionHeader(title: 'Sobre o local'),
                    const SizedBox(height: Spacing.base),
                    Text(
                      store.descricao?.trim().isNotEmpty == true
                          ? store.descricao!
                          : 'O vendedor ainda não adicionou uma descrição para este comércio.',
                      style: AppText.body(
                        context,
                      ).copyWith(color: colors.textSecondary, height: 1.5),
                    ),

                    if (store.galeria.isNotEmpty) ...[
                      const SizedBox(height: Spacing.xxl),
                      StoreGalleryStrip(store: store),
                    ],

                    const SizedBox(height: Spacing.xxl),
                    StoreReviewsSection(
                      avaliacoes: _avaliacoes,
                      carregando: _isLoadingRatings,
                      totalConhecido: _totalExibido,
                      erro: _ratingsError,
                      onRetry: _carregarAvaliacoes,
                    ),

                    if (_podeAvaliar) ...[
                      const SizedBox(height: Spacing.xxl),
                      ConsumerReviewSection(
                        lojaId: store.id,
                        userRole: _userRole,
                        onReviewSubmitted: _carregarAvaliacoes,
                        onUnsavedChanged: _onReviewUnsavedChanged,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
