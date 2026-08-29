import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/category_icons.dart';
import 'package:map_food/core/ui/utils/rating_format.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/store_map_page.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/report_store_dialog.dart';

/// Ações da loja: ver no mapa e denunciar.
///
/// As duas eram tratadas como coisas de naturezas diferentes — "Visualizar no
/// mapa" era um `FloatingActionButton` fixo no rodapé, cobrindo o conteúdo
/// durante toda a rolagem, e "Denunciar" era um pill vermelho colado ao lado do
/// nome da loja, disputando atenção com o título. Aqui elas viram o que são:
/// duas ações, numa linha, com pesos diferentes.
class StoreActionsRow extends StatelessWidget {
  final StoreDto store;

  /// 'CONSUMIDOR', 'GUEST', 'COMERCIANTE' ou 'ADMINISTRADOR' — só os dois
  /// primeiros veem "Denunciar" (o visitante cai na parede de login ao tocar,
  /// mas **vê** que a ação existe).
  final String userRole;

  const StoreActionsRow({super.key, required this.store, required this.userRole});

  bool get _podeDenunciar => userRole == 'CONSUMIDOR' || userRole == 'GUEST';

  void _denunciar(BuildContext context) {
    if (userRole == 'GUEST') {
      LoginWallHelper.showLoginWallBottomSheet(
        context,
        icon: AppIcons.flag,
        title: 'Viu algo errado neste comércio?',
        description:
            'Crie uma conta gratuita em segundos para denunciar e acompanhar a situação da sua denúncia.',
      );
      return;
    }
    showReportStoreDialog(context, lojaId: store.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Ver no mapa',
                icon: AppIcons.mapTrifold,
                size: AppButtonSize.sm,
                // Sem coordenadas não há o que mostrar: o mapa abria vazio e
                // a rota nem chegava a ser calculada. Desabilitado, o botão
                // ainda comunica que a função existe.
                onPressed: store.temLocalizacao
                    ? () => Navigator.push(
                          context,
                          appPageRoute(builder: (_) => StoreMapPage(store: store)),
                        )
                    : null,
              ),
            ),
            if (_podeDenunciar) ...[
              const SizedBox(width: Spacing.sm),
              AppButton(
                label: 'Denunciar',
                icon: AppIcons.flag,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                expand: false,
                onPressed: () => _denunciar(context),
              ),
            ],
          ],
        ),
        if (!store.temLocalizacao) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            'Este comércio ainda não informou a localização no mapa.',
            style: AppText.caption(context),
          ),
        ],
      ],
    );
  }
}

/// Resumo numérico da loja: nota, avaliações, fotos.
///
/// Eram quatro colunas, e a quarta era "No mapa: Sim/Não" — um dado que não é
/// métrica e que agora vive onde importa, no estado do botão "Ver no mapa".
/// Quatro colunas dividindo 360dp era também o aperto que fazia os rótulos
/// competirem por espaço assim que a fonte do sistema crescia.
class StoreStatsRow extends StatelessWidget {
  final StoreDto store;

  /// Nota média mais fresca (vem do resumo do backend), com fallback para a
  /// que veio junto da loja.
  final double? media;

  /// Total de avaliações mais fresco, pelo mesmo motivo de [media].
  ///
  /// Ler `store.totalAvaliacoes` direto daqui era o bug: quem chega ao detalhe
  /// por `GET /lojas/{id}` (entidade pura, sem agregação) via "0 Avaliações"
  /// neste resumo enquanto a seção logo abaixo listava várias.
  final int? total;

  const StoreStatsRow({super.key, required this.store, this.media, this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final stats = <(IconData, String, String)>[
      (AppIcons.starFill, formatRating(media), 'Nota média'),
      (AppIcons.chatCircle, '${total ?? store.totalAvaliacoes}', 'Avaliações'),
      (AppIcons.image, '${store.galeria.length}', 'Fotos'),
    ];

    return AppCard(
      elevation: AppCardElevation.flat,
      bordered: false,
      padding: const EdgeInsets.symmetric(vertical: Spacing.base, horizontal: Spacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              // O divisor acompanha a altura do conteúdo ao lado; parado em 32
              // ele viraria um risco curto no meio de uma coluna alta.
              Container(
                width: 1,
                height: escalaComTeto(context, 34.0),
                color: colors.border,
              ),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    stats[i].$1,
                    size: escalaIcone(context, AppIconSize.md),
                    color: colors.brandContent,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    stats[i].$2,
                    style: AppText.numeric(context, size: 15.0),
                    maxLines: linhasParaRotulo(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    stats[i].$3,
                    style: AppText.caption(context),
                    textAlign: TextAlign.center,
                    maxLines: linhasParaRotulo(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Categorias da loja, cada uma com a cor e o ícone que o app já usa para ela
/// nos filtros e nos cards de lista — antes eram chips só de texto, sem
/// relação visual nenhuma com a mesma categoria vista na busca.
class StoreCategoryChips extends StatelessWidget {
  final StoreDto store;

  const StoreCategoryChips({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final nomes = store.categoriaNomes.isNotEmpty
        ? store.categoriaNomes
        : [store.categoria.isNotEmpty ? store.categoria : 'Geral'];

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final nome in nomes)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 6.0),
            decoration: BoxDecoration(
              color: corParaCategoria(nome).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(color: corParaCategoria(nome).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconeParaCategoria(nome),
                  size: escalaIcone(context, 14.0),
                  color: corParaCategoria(nome),
                ),
                const SizedBox(width: 6.0),
                Text(
                  nome,
                  style: AppText.caption(context).copyWith(
                    color: corParaCategoria(nome),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
