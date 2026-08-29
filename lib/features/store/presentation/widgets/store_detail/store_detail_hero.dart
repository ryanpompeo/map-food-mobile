import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/favorites/presentation/widgets/favorite_button_widget.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Capa da loja como cabeçalho colapsável da tela de detalhe.
///
/// Antes a tela tinha uma `SliverAppBar` **vazia** e, logo abaixo, um bloco de
/// 260px com a capa. Rolar a página levava a foto embora e deixava no topo uma
/// barra sem nada além de dois botões — em nenhum momento da rolagem dava para
/// saber de qual comércio era aquela tela.
///
/// Agora a foto é o próprio cabeçalho: expandida, carrega o nome e o endereço
/// sobre um scrim; colapsada, entrega o nome à barra. A troca é comandada pela
/// altura real do `flexibleSpace` (via [LayoutBuilder]), não por um
/// `ScrollController` paralelo — o sliver já sabe o quanto encolheu.
class StoreDetailHero extends StatelessWidget {
  final StoreDto store;

  /// Altura da capa aberta. 280 é o ponto em que a foto ainda é o assunto da
  /// tela e o conteúdo abaixo já se anuncia — acima disso, a primeira dobra
  /// vira só imagem.
  static const double alturaExpandida = 280.0;

  /// Largura com que a capa é decodificada.
  ///
  /// É um método estático, e não um número solto dentro de [_Capa], porque o
  /// precache disparado antes da navegação (ver `abrirDetalheDaLoja`) precisa
  /// usar **exatamente** este valor: a largura entra na chave do cache de
  /// imagem, e divergir aqui faria o pré-carregamento aquecer uma entrada que
  /// esta tela nunca leria — sem erro nenhum aparecendo, só a lentidão de
  /// volta.
  static double larguraDaCapa(BuildContext context) => MediaQuery.sizeOf(context).width;

  const StoreDetailHero({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: alturaExpandida,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // A barra fixa não escurece ao ter conteúdo por baixo: ela já muda de
      // estado ao colapsar (ganha o nome da loja), e o tint do Material 3
      // por cima disso lê como uma terceira cor de fundo aparecendo do nada.
      scrolledUnderElevation: 0,
      leadingWidth: 60.0,
      leading: Center(
        child: _HeroCircleButton(
          icon: AppIcons.caretLeft,
          label: 'Voltar',
          onTap: () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Spacing.xs),
          child: FavoriteButtonWidget(store: store, iconSize: AppIconSize.md),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // A barra "colapsada" é a altura da toolbar mais o recorte do
          // sistema; a margem de 8 evita que o nome pisque no último pixel
          // da animação.
          final alturaColapsada = kToolbarHeight + MediaQuery.paddingOf(context).top;
          final colapsado = constraints.maxHeight <= alturaColapsada + 8.0;

          return FlexibleSpaceBar(
            // O título não escala junto com a barra: ele só aparece quando ela
            // já está colapsada, e crescer nesse instante pareceria um salto.
            expandedTitleScale: 1.0,
            // Abre espaço para o botão de voltar e para o de favoritar — sem
            // isso o nome nasce por baixo dos dois.
            titlePadding: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 60.0,
              bottom: 14.0,
            ),
            title: AnimatedOpacity(
              duration: Motion.fast,
              opacity: colapsado ? 1.0 : 0.0,
              child: Text(
                store.nome,
                style: AppText.title(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            stretchModes: const [StretchMode.zoomBackground],
            background: _Capa(store: store, visivel: !colapsado),
          );
        },
      ),
    );
  }
}

class _Capa extends StatelessWidget {
  final StoreDto store;

  /// O bloco de texto sobre a foto some quando a barra colapsa — a partir daí
  /// quem carrega o nome é o título da própria barra.
  final bool visivel;

  const _Capa({required this.store, required this.visivel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppNetworkImage(
          path: store.capaUrl,
          semanticLabel: 'Foto de capa de ${store.nome}',
          displayWidth: StoreDetailHero.larguraDaCapa(context),
          fallback: const _CapaVazia(),
        ),

        // Scrim só na metade de baixo, que é onde o texto cai. Um véu no
        // quadro inteiro escureceria a foto sem necessidade — e a foto do
        // comércio é o motivo de este cabeçalho existir.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xB3000000)],
            ),
          ),
        ),

        Positioned(
          left: Spacing.lg,
          right: Spacing.lg,
          bottom: Spacing.lg,
          child: AnimatedOpacity(
            duration: Motion.fast,
            opacity: visivel ? 1.0 : 0.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.nome,
                  style: AppText.h1(context).copyWith(color: ColorsPalette.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (store.enderecoCompleto != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: [
                      const Icon(
                        AppIcons.mapPin,
                        size: AppIconSize.sm,
                        color: ColorsPalette.white,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          store.enderecoCompleto!,
                          // Branco a 85%: um degrau abaixo do nome, sem cair
                          // no cinza (que sobre foto some).
                          style: AppText.secondary(context).copyWith(
                            color: ColorsPalette.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder da loja sem capa.
///
/// Gradiente da marca, e não a superfície cinza de antes: o texto do cabeçalho
/// é branco: sobre cinza-claro ele sumiria, e o hero perderia justamente a
/// função de dizer onde você está.
class _CapaVazia extends StatelessWidget {
  const _CapaVazia();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MfColor.ink, MfColor.brand],
        ),
      ),
      child: Center(
        child: Icon(
          AppIcons.storefront,
          size: 72.0,
          color: ColorsPalette.white.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

/// Botão circular sobre a capa. Superfície do tema (não vidro translúcido) de
/// propósito: ele continua na tela depois que a barra colapsa, e um círculo
/// translúcido sobre a superfície opaca da barra desapareceria.
class _HeroCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SemanticTapArea(
      label: label,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: context.mapColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorsPalette.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: AppIconSize.md,
              color: context.mapColors.brandContent,
            ),
          ),
        ),
      ),
    );
  }
}
