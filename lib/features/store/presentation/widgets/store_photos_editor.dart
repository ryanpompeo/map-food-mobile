import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/core/ui/widgets/xfile_image.dart';

/// Capa + galeria da loja, em um único bloco, usado tanto no cadastro quanto
/// na edição.
///
/// As duas telas mantinham cópias do mesmo editor com valores diferentes
/// (capa de 160 contra 180 de altura, tile de 100 contra 110, raio `md`
/// contra `lg`, um com sombra e outro não) — vistas em sequência, davam a
/// impressão de duas telas de produtos diferentes.
///
/// Distinção que a API preserva de propósito: **foto salva** no servidor
/// (`String` de URL) e **foto escolhida agora** (`XFile`) apagam de formas
/// diferentes — a primeira faz DELETE e precisa de confirmação, a segunda é
/// só descartar da lista local. Uma lista só de "fotos" esconderia isso e
/// levaria a chamar DELETE em arquivo que nunca subiu.
class StorePhotosEditor extends StatelessWidget {
  /// Fora de edição, os controles de escolher/remover não aparecem.
  final bool editando;

  /// Caminho da capa já salva (relativo, resolvido por `resolveImagemUrl`).
  final String? capaUrl;

  /// Capa escolhida nesta sessão e ainda não enviada. Tem precedência sobre
  /// [capaUrl] na exibição — é o que a pessoa acabou de escolher.
  final XFile? novaCapa;

  final bool removendoCapa;

  /// Mostra o selo "Obrigatório" ao lado do título (fluxo de cadastro).
  final bool capaObrigatoria;

  final List<String> galeriaSalva;
  final List<XFile> novasFotos;

  /// URL da foto de galeria com DELETE em andamento — mostra spinner no lugar
  /// do X daquele tile.
  final String? removendoGaleriaUrl;

  final int maxFotos;

  final VoidCallback onEscolherCapa;
  final VoidCallback onRemoverCapaSalva;
  final VoidCallback onDescartarNovaCapa;
  final VoidCallback onAdicionarFoto;
  final ValueChanged<String> onRemoverFotoSalva;
  final ValueChanged<XFile> onDescartarNovaFoto;

  const StorePhotosEditor({
    super.key,
    required this.editando,
    required this.capaUrl,
    required this.novaCapa,
    required this.galeriaSalva,
    required this.novasFotos,
    required this.onEscolherCapa,
    required this.onRemoverCapaSalva,
    required this.onDescartarNovaCapa,
    required this.onAdicionarFoto,
    required this.onRemoverFotoSalva,
    required this.onDescartarNovaFoto,
    this.removendoCapa = false,
    this.capaObrigatoria = false,
    this.removendoGaleriaUrl,
    this.maxFotos = 10,
  });

  int get _totalGaleria => galeriaSalva.length + novasFotos.length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Cabecalho(
          titulo: 'Foto de destaque',
          apoio: 'É a primeira imagem que o cliente vê da sua loja.',
          selo: capaObrigatoria ? 'Obrigatório' : null,
        ),
        const SizedBox(height: Spacing.md),
        _Capa(
          editando: editando,
          capaUrl: capaUrl,
          novaCapa: novaCapa,
          removendo: removendoCapa,
          onEscolher: onEscolherCapa,
          onRemoverSalva: onRemoverCapaSalva,
          onDescartarNova: onDescartarNovaCapa,
        ),
        const SizedBox(height: Spacing.xl),
        _Cabecalho(
          titulo: 'Galeria',
          apoio: 'Mostre o cardápio, o ponto e o que você vende.',
          contador: '$_totalGaleria/$maxFotos',
        ),
        const SizedBox(height: Spacing.md),
        if (_totalGaleria == 0 && !editando)
          EmptyState(
            dense: true,
            icon: AppIcons.imagesSquare,
            title: 'Sem fotos na galeria',
            description: 'Lojas com fotos recebem mais visitas — toque em '
                '"Editar" para adicionar.',
          )
        else
          _TiraGaleria(
            editando: editando,
            galeriaSalva: galeriaSalva,
            novasFotos: novasFotos,
            removendoGaleriaUrl: removendoGaleriaUrl,
            podeAdicionar: editando && _totalGaleria < maxFotos,
            onAdicionar: onAdicionarFoto,
            onRemoverSalva: onRemoverFotoSalva,
            onDescartarNova: onDescartarNovaFoto,
          ),
      ],
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final String titulo;
  final String apoio;
  final String? selo;
  final String? contador;

  const _Cabecalho({
    required this.titulo,
    required this.apoio,
    this.selo,
    this.contador,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(titulo, style: AppText.h2(context)),
            if (selo != null) ...[
              const SizedBox(width: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: MfColor.brand.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Text(
                  selo!,
                  style: AppText.overline(context).copyWith(
                    color: MfColor.brand,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (contador != null) ...[
              const Spacer(),
              Text(
                contador!,
                // Tabular: o contador não empurra o layout ao passar de 9
                // para 10 fotos.
                style: AppText.numeric(context).copyWith(
                  color: context.mapColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(apoio, style: AppText.secondary(context)),
      ],
    );
  }
}

class _Capa extends StatelessWidget {
  final bool editando;
  final String? capaUrl;
  final XFile? novaCapa;
  final bool removendo;
  final VoidCallback onEscolher;
  final VoidCallback onRemoverSalva;
  final VoidCallback onDescartarNova;

  const _Capa({
    required this.editando,
    required this.capaUrl,
    required this.novaCapa,
    required this.removendo,
    required this.onEscolher,
    required this.onRemoverSalva,
    required this.onDescartarNova,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final urlSalva = resolveImagemUrl(capaUrl);
    final temFoto = novaCapa != null || urlSalva != null;

    return SemanticTapArea(
      label: temFoto ? 'Foto de capa' : 'Adicionar foto de capa',
      onTap: editando && !temFoto ? onEscolher : null,
      child: Container(
        height: 170.0,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: colors.border),
        ),
        child: temFoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (novaCapa != null)
                    XFileImage(novaCapa!)
                  else
                    // Decorativa (sem `semanticLabel`): o título "Foto de
                    // destaque" já dá o contexto.
                    AppNetworkImage(
                      path: urlSalva,
                      displayWidth: MediaQuery.sizeOf(context).width,
                      fallback: Center(
                        child: Icon(
                          AppIcons.image,
                          color: colors.textTertiary,
                          size: AppIconSize.xl,
                        ),
                      ),
                    ),
                  if (editando)
                    Positioned(
                      top: Spacing.sm,
                      right: Spacing.sm,
                      child: Row(
                        children: [
                          _BotaoSobreFoto(
                            icone: AppIcons.pencilSimple,
                            rotulo: 'Trocar foto de destaque',
                            onTap: removendo ? null : onEscolher,
                          ),
                          const SizedBox(width: Spacing.sm),
                          _BotaoSobreFoto(
                            icone: AppIcons.trash,
                            rotulo: 'Remover foto de destaque',
                            destrutivo: true,
                            carregando: removendo,
                            onTap: removendo
                                ? null
                                : (novaCapa != null ? onDescartarNova : onRemoverSalva),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.imagesSquare,
                    color: colors.textTertiary,
                    size: AppIconSize.xl,
                  ),
                  if (editando) ...[
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Adicionar capa',
                      style: AppText.title(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'JPG ou PNG',
                      style: AppText.caption(context),
                    ),
                  ] else ...[
                    const SizedBox(height: Spacing.sm),
                    Text('Sem foto de destaque', style: AppText.secondary(context)),
                  ],
                ],
              ),
      ),
    );
  }
}

class _TiraGaleria extends StatelessWidget {
  final bool editando;
  final List<String> galeriaSalva;
  final List<XFile> novasFotos;
  final String? removendoGaleriaUrl;
  final bool podeAdicionar;
  final VoidCallback onAdicionar;
  final ValueChanged<String> onRemoverSalva;
  final ValueChanged<XFile> onDescartarNova;

  const _TiraGaleria({
    required this.editando,
    required this.galeriaSalva,
    required this.novasFotos,
    required this.removendoGaleriaUrl,
    required this.podeAdicionar,
    required this.onAdicionar,
    required this.onRemoverSalva,
    required this.onDescartarNova,
  });

  static const _lado = 100.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return SizedBox(
      height: _lado,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          if (podeAdicionar) ...[
            _TileAdicionar(lado: _lado, onTap: onAdicionar),
            const SizedBox(width: Spacing.md),
          ],
          for (final path in galeriaSalva) ...[
            _TileFoto(
              lado: _lado,
              editando: editando,
              removendo: removendoGaleriaUrl == path,
              onRemover: () => onRemoverSalva(path),
              child: _ImagemSalva(url: resolveImagemUrl(path), lado: _lado, colors: colors),
            ),
            const SizedBox(width: Spacing.md),
          ],
          for (final foto in novasFotos) ...[
            _TileFoto(
              lado: _lado,
              editando: editando,
              // Ainda não subiu: descartar é local e instantâneo, não há
              // estado de "removendo".
              removendo: false,
              onRemover: () => onDescartarNova(foto),
              child: XFileImage(foto),
            ),
            const SizedBox(width: Spacing.md),
          ],
        ],
      ),
    );
  }
}

class _ImagemSalva extends StatelessWidget {
  final String? url;
  final double lado;
  final MapFoodColors colors;

  const _ImagemSalva({required this.url, required this.lado, required this.colors});

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      path: url,
      displayWidth: lado,
      fallback: Center(
        child: Icon(AppIcons.image, color: colors.textTertiary, size: AppIconSize.xl),
      ),
    );
  }
}

class _TileAdicionar extends StatelessWidget {
  final double lado;
  final VoidCallback onTap;

  const _TileAdicionar({required this.lado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Semantics(
      button: true,
      label: 'Adicionar foto à galeria',
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.lg),
          child: SizedBox(
            height: lado,
            width: lado,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.camera, color: MfColor.brand, size: AppIconSize.lg),
                const SizedBox(height: Spacing.xs + 2),
                Text(
                  'Adicionar',
                  style: AppText.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileFoto extends StatelessWidget {
  final double lado;
  final bool editando;
  final bool removendo;
  final VoidCallback onRemover;
  final Widget child;

  const _TileFoto({
    required this.lado,
    required this.editando,
    required this.removendo,
    required this.onRemover,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return SizedBox(
      height: lado,
      width: lado,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.lg),
              child: ColoredBox(color: colors.surfaceAlt, child: child),
            ),
          ),
          if (editando)
            Positioned(
              top: Spacing.xs,
              right: Spacing.xs,
              child: _BotaoSobreFoto(
                icone: AppIcons.x,
                rotulo: 'Remover foto',
                compacto: true,
                carregando: removendo,
                onTap: removendo ? null : onRemover,
              ),
            ),
        ],
      ),
    );
  }
}

/// Botão circular sobre uma foto. Fundo de superfície (não branco literal)
/// para continuar legível no tema escuro, e sombra própria porque a foto
/// atrás pode ser de qualquer cor.
class _BotaoSobreFoto extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final VoidCallback? onTap;
  final bool destrutivo;
  final bool compacto;
  final bool carregando;

  const _BotaoSobreFoto({
    required this.icone,
    required this.rotulo,
    required this.onTap,
    this.destrutivo = false,
    this.compacto = false,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final cor = destrutivo ? MfColor.danger : colors.textPrimary;
    final tamanho = compacto ? 26.0 : 34.0;
    final tamanhoIcone = compacto ? 14.0 : 18.0;

    return Semantics(
      button: true,
      label: rotulo,
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: tamanho,
            height: tamanho,
            child: Center(
              child: carregando
                  ? SizedBox(
                      width: tamanhoIcone,
                      height: tamanhoIcone,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cor),
                    )
                  : Icon(icone, size: tamanhoIcone, color: cor),
            ),
          ),
        ),
      ),
    );
  }
}
