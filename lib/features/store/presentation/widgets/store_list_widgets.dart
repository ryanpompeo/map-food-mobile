import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/rating_format.dart';
import 'package:map_food/features/favorites/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class VerticalDestaqueSliverWidget extends StatelessWidget {
  final List<StoreDto> items;

  const VerticalDestaqueSliverWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(child: Text("Nenhum comércio encontrado para esta categoria", style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText))),
        ),
      );
    }

    // Lista "corrida", sem card individual — itens separados por um divisor
    // fino em vez de cada um virar sua própria caixa com sombra (inspirado
    // num layout de lista de reserva/hospedagem: miniatura + coração
    // sobreposto, título, linha de detalhe, pill + nota na base).
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final isLast = index == items.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
            child: Column(
              children: [
                StoreListItemWidget(store: items[index]),
                if (!isLast) ...[
                  const SizedBox(height: AppSpacing.md),
                  Divider(height: 1, thickness: 1, color: context.mapColors.border),
                ],
              ],
            ),
          );
        }, childCount: items.length),
      ),
    );
  }
}

class StoreListItemWidget extends StatelessWidget {
  final StoreDto store;

  const StoreListItemWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final endereco = store.enderecoCompleto;

    return InkWell(
      onTap: () => Navigator.push(context, appPageRoute(builder: (context) => MoreInfoStorePage(store: store))),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84.0, height: 84.0,
                // Um tom abaixo do mainBackground da página, senão o
                // placeholder fica invisível antes da imagem carregar.
                decoration: BoxDecoration(
                  color: context.mapColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppElevation.soft,
                ),
                child: resolveImagemUrl(store.capaUrl) != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image.network(
                          resolveImagemUrl(store.capaUrl)!, fit: BoxFit.cover,
                          // Decorativa: o nome da loja já aparece como texto no card.
                          excludeFromSemantics: true,
                          // Só cacheWidth: com os dois definidos o decoder
                          // ignora a proporção original e estica a imagem.
                          cacheWidth: (84.0 * MediaQuery.devicePixelRatioOf(context)).round(),
                          errorBuilder: (context, error, stackTrace) => Icon(AppIcons.image, size: 24.0, color: context.mapColors.iconMuted),
                        ),
                      )
                    : Icon(AppIcons.image, size: 24.0, color: context.mapColors.iconMuted),
              ),
              Positioned(
                top: 6.0, left: 6.0,
                child: FavoriteButtonWidget(store: store, iconSize: 14, frosted: true),
              ),
              // O selo redondo com a cor da categoria saiu daqui. Ele
              // transbordava a miniatura (bottom/right negativos), colidia
              // com o divisor da lista e repetia uma informação que a pessoa
              // já escolheu no filtro logo acima — dentro de "Espetinhos",
              // um ícone de espetinho em cada item não informa nada.
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // O nome é o que identifica o item da lista: em escala alta,
                // uma linha só o reduziria a "Padaria do Se…". O card não tem
                // altura fixa, então a segunda linha cabe sem quebrar nada.
                Text(
                  store.nome,
                  style: AppText.corpo(context).copyWith(fontSize: 15, fontWeight: FontWeight.w800, color: context.mapColors.primaryText),
                  maxLines: linhasParaRotulo(context),
                  overflow: TextOverflow.ellipsis,
                ),
                if (endereco != null) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    // Com o endereço em duas linhas, `center` (o padrão)
                    // descolaria o pin do começo do texto.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        AppIcons.mapPin,
                        size: escalaIcone(context, 12),
                        color: context.mapColors.secondaryText,
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          endereco,
                          style: AppText.legenda(context).copyWith(fontSize: 12),
                          maxLines: linhasParaRotulo(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Icon(AppIcons.star, color: ColorsPalette.ratingStar, size: escalaIcone(context, 14)),
                    const SizedBox(width: 4.0),
                    Text(
                      formatRating(store.avaliacao),
                      style: AppText.legenda(context).copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
