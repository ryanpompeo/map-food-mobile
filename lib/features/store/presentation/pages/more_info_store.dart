import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
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

/// Tela de detalhe de um comércio.
///
/// A página é composição: a capa, o resumo, as seções e o bloco de avaliação
/// do consumidor moram em `widgets/store_detail/`. Antes tudo isso — inclusive
/// o diálogo de denúncia e o formulário de avaliação — vivia neste arquivo, em
/// 1195 linhas, com quatro estados de UI (recolhida, filtro de nota, histórico,
/// rascunho) misturados aos dois carregamentos de rede que a página realmente
/// coordena.
///
/// O que sobrou aqui é exatamente isso: buscar as avaliações e o resumo da
/// loja, e decidir quais seções cada papel de usuário vê.
/// Deixa a capa da loja pronta no cache de memória antes de a tela de detalhe
/// existir.
///
/// A conta de tempo é esta: a transição de página leva ~300ms, e nesse
/// intervalo a rede fica ociosa enquanto a tela nova é montada. Disparando o
/// download no toque, ele corre **durante** a animação — e a capa costuma
/// chegar antes do primeiro quadro da tela de destino.
///
/// Sem `await` de propósito: esperar a foto para só então navegar transformaria
/// um toque instantâneo numa espera de rede, que é exatamente o defeito que
/// isto existe para evitar. Se a imagem não chegar a tempo, a tela abre como
/// sempre abriu e a foto entra com o fade normal.
void precacheCapaDaLoja(BuildContext context, StoreDto store) {
  unawaited(
    AppNetworkImage.precache(
      context,
      store.capaUrl,
      // A mesma largura que a capa usa lá dentro. Se as duas divergirem, o
      // precache aquece uma entrada de cache que a tela não lê.
      displayWidth: StoreDetailHero.larguraDaCapa(context),
    ),
  );
}

/// Abre a tela de detalhe de [store], pré-carregando a capa no caminho.
///
/// É o jeito padrão de chegar em [MoreInfoStorePage] — use no lugar de montar
/// o `Navigator.push` à mão, para o pré-carregamento não ficar de fora de um
/// ponto de entrada novo.
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

  /// Quantas avaliações a loja tem, segundo o dado que **já chegou junto com
  /// ela**. Começa em `widget.store.totalAvaliacoes` e é corrigido pelo resumo
  /// do backend.
  ///
  /// Existe porque nem toda tela de origem entrega esse número: quem abre o
  /// detalhe a partir de "Minhas avaliações" ou do perfil do comerciante passa
  /// por `GET /lojas/{id}`, que devolve a entidade pura, sem a agregação. Ali
  /// `totalAvaliacoes` vem 0 — e a tela exibia "0 Avaliações" no topo enquanto
  /// listava cinco logo abaixo.
  int _totalConhecido = 0;

  /// O número a exibir: a lista carregada é a fonte mais confiável; até ela
  /// chegar, vale o que já se sabia.
  int get _totalExibido => _isLoadingRatings ? _totalConhecido : _avaliacoes.length;

  // Agregação de avaliação vinda do backend (Fase 4) — não é calculada no
  // cliente. Começa com o que já veio em `widget.store` (pode já estar
  // populado se a tela de origem usou o endpoint completo) e é atualizada com
  // o dado mais fresco assim que a busca abaixo responde.
  double? _mediaAvaliacao;

  /// Papel do usuário, lido do [SessionStore] — síncrono, sem I/O e sem
  /// `setState`.
  String get _userRole => SessionStore.instance.role;

  bool get _podeAvaliar => _userRole == 'CONSUMIDOR' || _userRole == 'GUEST';

  // Guard de "sair sem salvar": true enquanto o usuário tiver nota/comentário
  // digitados na seção de avaliação sem enviar — a página inteira precisa
  // saber disso porque a avaliação é só uma seção dela, não uma tela própria.
  // ValueNotifier (não bool + setState) pra não reconstruir a página inteira
  // a cada tecla digitada — o rebuild fica isolado no UnsavedChangesGuard.
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
    // Spinner só quando não há nada na tela para olhar — primeira carga ou
    // "Tentar novamente" depois de um erro. Recarregar após enviar uma
    // avaliação mantém a lista visível: trocá-la por um spinner faria a
    // seção inteira saltar logo depois do toque em "Enviar".
    final mostrarCarregando = _ratingsError != null || _avaliacoes.isEmpty;
    if (mostrarCarregando && !_isLoadingRatings) {
      setState(() => _isLoadingRatings = true);
    }
    try {
      final ratings = await _avaliacaoService.buscarAvaliacoesDaLoja(widget.store.id);
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

  /// Busca a agregação de avaliação pronta do backend — garante o selo de
  /// nota correto independente de `widget.store` ter vindo de uma tela que
  /// já usa o endpoint novo ou de uma que ainda não (ex: Favoritos).
  Future<void> _carregarResumoLoja() async {
    try {
      final resumo = await _storeService.getResumo(widget.store.id);
      if (!mounted) return;
      setState(() {
        _mediaAvaliacao = resumo.avaliacao;
        // O total vinha junto e era descartado — é o que conserta o "0
        // Avaliações" nas telas que abrem o detalhe sem a agregação.
        _totalConhecido = resumo.totalAvaliacoes;
      });
    } catch (_) {
      // Mantém o que já tinha (de widget.store, ou "Novo") se a busca falhar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final colors = context.mapColors;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedReview,
      child: Scaffold(
        backgroundColor: colors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            StoreDetailHero(store: store),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.lg,
                Spacing.lg,
                // Respiro de rodapé: a tela termina numa área de digitação
                // (o comentário da avaliação), que precisa de espaço para
                // subir acima do teclado.
                Spacing.xxxl,
              ),
              sliver: SliverList.list(
                children: [
                  StoreStatsRow(store: store, media: _mediaAvaliacao, total: _totalExibido),
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
                    style: AppText.body(context).copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
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

                  // Visitante também vê o formulário, mas em modo vitrine:
                  // qualquer toque abre a parede de login (ver
                  // ConsumerReviewSection).
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
    );
  }
}
