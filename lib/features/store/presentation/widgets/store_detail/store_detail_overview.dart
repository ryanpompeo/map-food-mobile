import 'package:flutter/material.dart';
import 'package:map_food/core/location/rota_externa.dart';
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
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/store_map_page.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/report_store_dialog.dart';
import 'package:map_food/features/store/presentation/widgets/visto_ha.dart';

class StoreActionsRow extends StatelessWidget {
  final StoreDto store;

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
            'Crie uma conta grátis para denunciar e acompanhar sua denúncia',
      );
      return;
    }
    showReportStoreDialog(context, lojaId: store.id);
  }

  Future<void> _tracarRota(BuildContext context) async {
    final abriu = await RotaExterna.tracar(
      latitude: store.latitude!,
      longitude: store.longitude!,
      nome: store.nome,
    );
    if (!abriu && context.mounted) {
      AppToast.error(context, 'Nenhum aplicativo de mapas encontrado neste celular');
    }
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
        if (store.temLocalizacao)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: AppButton(
              label: 'Traçar rota',
              icon: AppIcons.navigationArrow,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              onPressed: () => _tracarRota(context),
            ),
          ),
        if (!store.temLocalizacao) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            'Este comércio ainda não informou a localização',
            style: AppText.caption(context),
          ),
        ],
        VistoHa(
          lojaId: store.id,
          builder: (context, texto) => Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: Row(
              children: [
                Icon(
                  AppIcons.broadcast,
                  size: escalaIcone(context, 14.0),
                  color: context.mapColors.textSecondary,
                ),
                const SizedBox(width: 6.0),
                Text(texto, style: AppText.caption(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StoreStatsRow extends StatelessWidget {
  final StoreDto store;

  final double? media;

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
