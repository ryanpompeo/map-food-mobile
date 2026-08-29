import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/charts/chart_data.dart';
import 'package:map_food/core/ui/charts/distribution_donut_chart.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/core/ui/widgets/delta_badge.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:map_food/features/analytics/presentation/widgets/analytics_scope_selector.dart';
import 'package:map_food/features/analytics/presentation/widgets/analytics_section_card.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Painel de estatísticas do comerciante.
///
/// Substitui os cards de cor sólida que existiam no topo de "Minha loja" e do
/// Perfil. Aqueles respondiam "quantos?"; nenhum respondia "está subindo?" —
/// que é a pergunta que faz o lojista abrir o app duas vezes no mesmo dia.
///
/// O desenho segue o painel de atividade do consumidor: superfície neutra com
/// borda de 1px e sem sombra, `Spacing.lg` nas laterais, número grande em
/// `display` e período em `AppChoiceChip`. Cor só onde ela **significa** algo —
/// a direção da variação, e a identidade de cada fatia das roscas.
class MerchantAnalyticsPage extends StatefulWidget {
  /// Lojas do comerciante, vindas da página que já as carregou
  /// (`MerchantHomePage`) — esta tela não repete a busca.
  final List<StoreDto> lojas;

  /// `true` enquanto esta é a aba exibida. A página vive num `IndexedStack` —
  /// construída uma vez e nunca descartada —, então o `initState` não serve
  /// como gatilho de atualização: sem este aviso, os números ficariam parados
  /// no retrato do momento em que o app abriu. Mesmo mecanismo do painel de
  /// atividade do consumidor.
  final ValueListenable<bool>? visivel;

  const MerchantAnalyticsPage({super.key, required this.lojas, this.visivel});

  @override
  State<MerchantAnalyticsPage> createState() => _MerchantAnalyticsPageState();
}

class _MerchantAnalyticsPageState extends State<MerchantAnalyticsPage> {
  late final AnalyticsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnalyticsController(
      lojas: widget.lojas,
      // Denúncias são consultadas por comerciante, não por loja — a rota
      // devolve 403 para qualquer id que não seja o do próprio token.
      comercianteId: SessionStore.instance.userId,
    );
    _controller.carregar();
    widget.visivel?.addListener(_aoMudarVisibilidade);
  }

  /// Cada volta para esta aba refaz a busca. É o que faz uma visita recebida
  /// há pouco aparecer sem precisar reiniciar o app — o dado de acesso muda
  /// por fora, sem nenhuma ação do comerciante que pudesse servir de gatilho.
  void _aoMudarVisibilidade() {
    if (widget.visivel?.value ?? false) _controller.carregar();
  }

  @override
  void didUpdateWidget(covariant MerchantAnalyticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A página vive num IndexedStack e nunca é recriada: quando o pai troca a
    // lista (loja criada, excluída, renomeada), é por aqui que ela chega. A
    // assinatura inclui o nome porque ele é o rótulo do seletor de escopo —
    // quem decide se isso vale uma rebusca é o controller.
    String assinatura(List<StoreDto> lojas) =>
        lojas.map((l) => '${l.id}:${l.nome}').join('|');

    if (assinatura(oldWidget.lojas) != assinatura(widget.lojas)) {
      _controller.atualizarLojas(widget.lojas);
    }
  }

  @override
  void dispose() {
    widget.visivel?.removeListener(_aoMudarVisibilidade);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        titleSpacing: Spacing.lg,
        // Aba não tem "voltar". O `AppBar` desenha a seta sozinho sempre que
        // existe rota abaixo na pilha, e aqui ela sairia da home do lojista
        // inteira — não desta tela.
        automaticallyImplyLeading: false,
        title: Text(
          'Estatísticas',
          style: AppText.subtitulo(context).copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => AnalyticsScopeSelector(
              lojas: _controller.lojas,
              lojaSelecionadaId: _controller.lojaSelecionadaId,
              onSelecionar: _controller.selecionarLoja,
            ),
          ),
          const SizedBox(width: Spacing.md),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildCorpo(context),
      ),
    );
  }

  Widget _buildCorpo(BuildContext context) {
    final state = _controller.state;

    // Erro tem precedência sobre o dado velho só quando não há nada para
    // mostrar — com um snapshot anterior em mãos, trocar a tela inteira por
    // uma mensagem apagaria o que a pessoa estava lendo.
    if (state.errorMessage != null && state.data == null) {
      return Center(
        child: EmptyState(
          icon: AppIcons.wifiSlash,
          title: 'Não foi possível carregar',
          description: state.errorMessage,
          actionLabel: 'Tentar novamente',
          onAction: _controller.carregar,
          tone: EmptyStateTone.error,
        ),
      );
    }

    final snapshot = state.data;
    if (snapshot == null) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsPalette.redComponents),
      );
    }

    if (_controller.lojas.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: AppIcons.storefront,
          title: 'Nenhuma loja cadastrada',
          description: 'Cadastre sua loja para começar a acompanhar os acessos.',
        ),
      );
    }

    return RefreshIndicator(
      // Puxar para atualizar: além da volta para a aba, é o gesto que a pessoa
      // já tenta por instinto quando quer saber se chegou visita agora.
      onRefresh: _controller.carregar,
      color: ColorsPalette.redComponents,
      child: ListView(
        // `AlwaysScrollable`: sem isso o gesto de puxar não existe quando o
        // conteúdo cabe na tela — justamente o caso da loja sem movimento,
        // que é quem mais quer conferir se algo mudou.
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(
          top: Spacing.sm,
          bottom: AppBottomBar.spaceFor(context) + Spacing.lg,
        ),
        children: [
          _buildPeriodos(context),
          const SizedBox(height: Spacing.lg),
          _buildCardAvaliacoes(context, snapshot),
          const SizedBox(height: Spacing.lg),
          _buildCardDenuncias(context, snapshot.denuncias),
        ],
      ),
    );
  }

  Widget _buildPeriodos(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        children: [
          for (final range in AnalyticsRange.values) ...[
            if (range != AnalyticsRange.values.first) const SizedBox(width: Spacing.sm),
            AppChoiceChip(
              label: range.label,
              selected: _controller.range == range,
              onTap: () => _controller.definirPeriodo(range),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardAvaliacoes(BuildContext context, AnalyticsSnapshot snapshot) {
    final colors = context.mapColors;

    if (snapshot.semAvaliacoes) {
      return AnalyticsSectionCard(
        titulo: 'Como te avaliam',
        child: Text(
          'Nenhuma avaliação ainda. Elas aparecem aqui assim que o primeiro '
          'cliente avaliar sua loja.',
          style: AppText.secondary(context).copyWith(height: 1.4),
        ),
      );
    }

    return AnalyticsSectionCard(
      titulo: 'Como te avaliam',
      child: DistributionDonutChart(
        slices: [
          for (final bucket in snapshot.distribuicaoNotas)
            DonutSlice(
              label: '${bucket.nota} estrela${bucket.nota > 1 ? 's' : ''}',
              value: bucket.quantidade.toDouble(),
              color: _corDaNota(bucket.nota),
            ),
        ],
        centro: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              snapshot.mediaAvaliacao!.toStringAsFixed(1).replaceAll('.', ','),
              style: AppText.numeric(context, size: 20).copyWith(
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
              ),
            ),
            Text(
              '${snapshot.totalAvaliacoes}',
              style: AppText.legenda(context).copyWith(fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }

  /// Denúncias do período.
  ///
  /// Sem nenhuma, o card **não** mostra um "0": mostra um selo de que está
  /// tudo certo. Um zero grande num card de denúncia lê como alerta à
  /// distância — a pessoa vê o rótulo "Denúncias" em destaque e o coração
  /// dispara antes de ela ler o número. O selo diz a mesma coisa sem o susto.
  ///
  /// Com denúncias, o que importa não é só quantas, mas **por quê** (a rosca
  /// de motivos, que é o acionável) e **quantas ainda estão de pé** — caso
  /// arquivado pela moderação não é dívida do comerciante, e somá-lo ao total
  /// transformaria um problema encerrado em cobrança permanente.
  Widget _buildCardDenuncias(BuildContext context, DenunciaResumo denuncias) {
    final colors = context.mapColors;

    if (denuncias.indisponivel) {
      return AnalyticsSectionCard(
        titulo: 'Denúncias',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(AppIcons.wifiSlash, size: AppIconSize.md, color: colors.textTertiary),
            const SizedBox(width: Spacing.md),
            Expanded(
              // Nunca "Nada por aqui" quando a busca falhou: seria dar uma
              // tranquilidade que não foi apurada.
              child: Text(
                'Não foi possível carregar as denúncias agora. Puxe para atualizar.',
                style: AppText.secondary(context).copyWith(height: 1.45),
              ),
            ),
          ],
        ),
      );
    }

    if (denuncias.limpo) {
      return AnalyticsSectionCard(
        titulo: 'Denúncias',
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: MfColor.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.shieldCheck,
                color: colors.successContent,
                size: AppIconSize.md,
              ),
            ),
            const SizedBox(width: Spacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nada por aqui',
                    style: AppText.title(context).copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Nenhuma denúncia neste período.',
                    style: AppText.secondary(context).copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AnalyticsSectionCard(
      titulo: 'Denúncias no período',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${denuncias.total}',
                style: AppText.display(context).copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              if (denuncias.deltaPercentual != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  // Invertido: aqui subir é a má notícia.
                  child: DeltaBadge(
                    percentual: denuncias.deltaPercentual!,
                    tone: DeltaTone.semanticoInvertido,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              if (denuncias.emAberto > 0)
                _PastilhaStatus(
                  icone: AppIcons.warningCircle,
                  texto: '${denuncias.emAberto} em análise',
                  cor: colors.brandContent,
                ),
              if (denuncias.encerradas > 0)
                _PastilhaStatus(
                  icone: AppIcons.checkCircle,
                  texto: '${denuncias.encerradas} já encerrada'
                      '${denuncias.encerradas > 1 ? 's' : ''}',
                  cor: colors.successContent,
                ),
            ],
          ),
          if (denuncias.porMotivo.isNotEmpty) ...[
            const SizedBox(height: Spacing.lg),
            Text(
              'Por motivo',
              style: AppText.legenda(context).copyWith(
                fontSize: 11.0,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            DistributionDonutChart(
              slices: [
                for (var i = 0; i < denuncias.porMotivo.length; i++)
                  DonutSlice(
                    label: denuncias.porMotivo[i].label,
                    value: denuncias.porMotivo[i].quantidade.toDouble(),
                    color: _paletaMotivos[i % _paletaMotivos.length],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Escala de nota: verde no 5, vermelho no 1, âmbar no meio. É a mesma
  /// leitura de "bom → ruim" da direção do delta, então as duas cores do card
  /// significam a mesma coisa.
  static Color _corDaNota(int nota) => switch (nota) {
    5 => MfColor.success,
    4 => const Color(0xFF7CB342),
    3 => MfColor.warning,
    2 => const Color(0xFFEF6C00),
    _ => MfColor.danger,
  };

  /// Motivos de denúncia. Tons quentes, sem verde: aqui **nenhuma** fatia é
  /// boa notícia, e um motivo pintado de verde sugeriria o contrário. São
  /// cinco, o número exato de motivos que a API aceita.
  static const _paletaMotivos = [
    Color(0xFFDC2626),
    Color(0xFFEA580C),
    Color(0xFFD97706),
    Color(0xFF9333EA),
    Color(0xFF64748B),
  ];
}

/// Pastilha de status das denúncias ("2 em análise", "5 já encerradas").
///
/// Ícone junto do texto, e não só cor: a diferença entre o que ainda pesa e o
/// que já foi resolvido é a informação mais importante do card, e ela não pode
/// depender de distinguir vermelho de verde.
class _PastilhaStatus extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color cor;

  const _PastilhaStatus({required this.icone, required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 6.0),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14.0, color: cor),
          const SizedBox(width: 6.0),
          Text(
            texto,
            style: AppText.legenda(context).copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
