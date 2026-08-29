import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Toda imagem vinda da API passa por aqui.
///
/// Antes deste widget havia treze `Image.network` escritos à mão pelo app
/// (cards de busca, capa da loja, galeria, avatares, marcador do mapa,
/// favoritos, avaliações...), cada um repetindo o mesmo trio de cuidados —
/// `resolveImagemUrl` antes de montar, `excludeFromSemantics`, `errorBuilder`
/// com um ícone cinza — e cada um com uma variação pequena do mesmo bug.
///
/// Concentrar aqui resolve quatro coisas de uma vez:
///
/// 1. **A URL se resolve sozinha.** As telas passam o path cru que veio do
///    backend (`/uploads/lojas/x.jpg`); o `null` de "loja sem foto" deixa de
///    ser um `if` repetido em cada chamada e vira o [fallback].
/// 2. **A foto entra com fade**, em vez de ser pintada de estalo por cima do
///    fundo cinza — ver [_comFade], e a ressalva sobre imagem já em cache, que
///    **não** anima de propósito.
/// 3. **A foto sobrevive ao fechamento do app** — ver [providerFor].
/// 4. **Existe um ponto único** para mudar qualquer uma dessas decisões sem
///    voltar aos treze arquivos. Foi o que permitiu ligar o cache de disco no
///    app inteiro trocando uma linha.
class AppNetworkImage extends StatelessWidget {
  /// Path cru devolvido pela API (ex: `/uploads/lojas/x.jpg`) ou URL absoluta.
  /// `null`/vazio cai direto no [fallback], sem tentar rede.
  final String? path;

  final BoxFit fit;
  final double? width;
  final double? height;

  /// Largura **em pixels lógicos** com que a imagem aparece na tela (ex: 84
  /// para a miniatura da lista). A conversão para pixels físicos —
  /// multiplicar pelo `devicePixelRatio` — acontece aqui dentro, porque era
  /// exatamente a conta que cada chamada refazia à mão.
  ///
  /// Só a largura, nunca a altura junto: com as duas definidas o decoder
  /// ignora a proporção original e estica a imagem.
  final double? displayWidth;

  /// Descrição para leitor de tela. Deixe `null` quando a imagem for
  /// decorativa — quando o nome da loja já aparece como texto ao lado, o
  /// leitor não deve anunciá-la duas vezes.
  final String? semanticLabel;

  /// O que aparece sem imagem e em caso de erro. Sem isto, um ícone neutro do
  /// tamanho de [fallbackIconSize].
  final Widget? fallback;

  final double fallbackIconSize;

  /// Duração do fade. 200ms é o suficiente para a entrada ser percebida como
  /// suave sem atrasar a leitura da tela.
  final Duration fadeDuration;

  const AppNetworkImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.displayWidth,
    this.semanticLabel,
    this.fallback,
    this.fallbackIconSize = 24.0,
    this.fadeDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final provider = providerFor(context, path, displayWidth: displayWidth);
    if (provider == null) return _buildFallback(context);

    return Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      frameBuilder: _comFade,
      errorBuilder: (context, error, stackTrace) => _buildFallback(context),
    );
  }

  /// O provider que este widget usa para desenhar — exposto porque **quem
  /// pré-carrega precisa usar exatamente o mesmo**.
  ///
  /// A largura de decodificação entra na chave do cache de memória: aquecer
  /// `provider(url)` e depois desenhar `ResizeImage(provider(url), width:
  /// 1080)` são duas entradas distintas, e o precache viraria um download a
  /// mais em vez de uma tela mais rápida. Construir os dois por aqui é o que
  /// impede esse desencontro silencioso.
  ///
  /// ## Por que `CachedNetworkImageProvider` e não `NetworkImage`
  ///
  /// O `NetworkImage` do Flutter guarda a imagem **só em memória**: fechar o
  /// app apagava tudo, e o MapFood reabria baixando cada capa de novo — em 4G
  /// de calçada, que é onde ele é usado. O provider do `cached_network_image`
  /// grava em disco.
  ///
  /// O ganho não é só entre sessões. O cache de disco é chaveado **apenas pela
  /// URL**, enquanto o de memória inclui a largura: a mesma capa exibida a 84px
  /// na lista e em tela cheia no detalhe eram dois downloads e agora são um só,
  /// decodificado duas vezes a partir do mesmo arquivo.
  ///
  /// Fica no provider, não no widget `CachedNetworkImage` do pacote: aquele
  /// widget traz a própria API de placeholder e fade, que substituiria o
  /// comportamento construído aqui. Trocando só o transporte, o resto do app
  /// não percebe a mudança.
  ///
  /// Retenção é a padrão do `flutter_cache_manager` (200 arquivos, 30 dias).
  ///
  /// Devolve `null` quando não há imagem — o chamador cai no fallback.
  static ImageProvider? providerFor(
    BuildContext context,
    String? path, {
    double? displayWidth,
  }) {
    final url = resolveImagemUrl(path);
    if (url == null) return null;

    final provider = CachedNetworkImageProvider(url);
    if (displayWidth == null) return provider;

    // `displayWidth` é lógico; o decoder espera pixel físico do aparelho.
    // Sem a conversão a imagem sairia borrada em telas de alta densidade.
    return ResizeImage(
      provider,
      width: (displayWidth * MediaQuery.devicePixelRatioOf(context)).round(),
      allowUpscaling: false,
    );
  }

  /// Baixa e decodifica a imagem **antes** de ela ser necessária, deixando-a
  /// pronta no cache de memória.
  ///
  /// Use no toque que leva a uma tela onde a imagem é o cabeçalho: a espera
  /// passa a acontecer durante a animação de transição, e a tela nova nasce
  /// com a foto no lugar em vez de com um retângulo cinza.
  ///
  /// Não devolve erro: uma foto que falhou no pré-carregamento simplesmente
  /// será buscada de novo pela tela de destino, que já sabe lidar com falha.
  /// Deixá-la escapar aqui derrubaria uma navegação por causa de um 404.
  static Future<void> precache(
    BuildContext context,
    String? path, {
    double? displayWidth,
  }) async {
    final provider = providerFor(context, path, displayWidth: displayWidth);
    if (provider == null) return;
    await precacheImage(provider, context, onError: (_, _) {});
  }

  /// Fade de entrada — mas **só na primeira vez**.
  ///
  /// `wasSynchronouslyLoaded` é true quando a imagem já estava no cache de
  /// memória e ficou pronta no mesmo frame. Animar nesse caso faria a foto
  /// piscar a cada rebuild: a cada rolagem da lista, a cada toque no coração
  /// de favorito, a cada notificação do `ActiveStoresManager`. O fade é para
  /// mascarar espera; onde não houve espera, ele só chama atenção para si.
  ///
  /// É também o que faz o precache valer a pena: uma imagem pré-carregada
  /// antes da navegação chega por este caminho e aparece inteira no primeiro
  /// frame da tela nova, sem transição nenhuma.
  Widget _comFade(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0.0 : 1.0,
      duration: fadeDuration,
      curve: Curves.easeOut,
      child: child,
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (fallback != null) return fallback!;
    return Center(
      child: Icon(
        AppIcons.image,
        size: fallbackIconSize,
        color: context.mapColors.iconMuted,
      ),
    );
  }
}
