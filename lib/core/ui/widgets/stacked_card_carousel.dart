import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';

class StackedCardItem {
  final Object id;
  final String title;
  final String? imageUrl;

  /// Categoria principal da loja. Opcional: o carrossel do comerciante ("Minhas
  /// Lojas") não tem o que dizer aqui, e o chip simplesmente não aparece.
  final String? subtitle;

  /// Nota média, já como número — a formatação (`4.0`, `Novo`) é do card.
  final double? rating;

  const StackedCardItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.rating,
  });
}

/// Carrossel de cards empilhados (efeito "baralho"): o card da frente é
/// substituído automaticamente pelo de trás a cada [autoAdvanceInterval],
/// e o usuário pode deslizar com o dedo pra trocar na hora — o que
/// acontecer primeiro reinicia o temporizador, pra não "atropelar" o gesto
/// manual com um avanço automático logo em seguida.
///
/// O empilhamento é feito por deslocamento vertical + largura decrescente
/// (não por escala a partir do centro) — assim os cards de trás realmente
/// aparecem espiando por baixo do card da frente, em vez de só encolher
/// escondidos atrás dele.
class StackedCardCarousel extends StatefulWidget {
  final List<StackedCardItem> items;
  final ValueChanged<StackedCardItem> onTap;
  final double cardHeight;
  final Duration autoAdvanceInterval;

  /// Recuo horizontal do card da frente em relação às bordas do carrossel —
  /// aumentar isso estreita o card (os de trás recuam ainda mais a partir
  /// deste valor, ver [_passoRecuoHorizontal]).
  final double horizontalPadding;

  const StackedCardCarousel({
    super.key,
    required this.items,
    required this.onTap,
    this.cardHeight = 220.0,
    this.autoAdvanceInterval = const Duration(seconds: 4),
    this.horizontalPadding = AppSpacing.lg,
  });

  @override
  State<StackedCardCarousel> createState() => _StackedCardCarouselState();
}

class _StackedCardCarouselState extends State<StackedCardCarousel> {
  static const int _maxVisible = 3;
  static const Duration _animDuration = Duration(milliseconds: 420);
  static const double _velocidadeMinimaSwipe = 250.0;

  // Cada profundidade soma este deslocamento vertical e este acréscimo de
  // recuo horizontal em relação ao card da frente (profundidade 0).
  static const double _passoVertical = 16.0;
  static const double _passoRecuoHorizontal = 12.0;

  int _currentIndex = 0;
  Timer? _timer;

  // ValueNotifier (não campo + setState) de propósito: um drag horizontal
  // dispara onHorizontalDragUpdate a cada amostra do ponteiro (60+ vezes por
  // segundo) — setState nesse ritmo reconstruía os 3 cards empilhados (foto,
  // texto, sombra...) inteiros a cada evento, quando só a translação do card
  // da frente muda. O ValueListenableBuilder em _buildSlot isola esse
  // rebuild só na translação.
  final ValueNotifier<double> _dragDx = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant StackedCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _currentIndex = 0;
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dragDx.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;
    _timer = Timer.periodic(widget.autoAdvanceInterval, (_) => _advance());
  }

  void _advance() {
    if (!mounted || widget.items.isEmpty) return;
    setState(() => _currentIndex = (_currentIndex + 1) % widget.items.length);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    _dragDx.value = 0.0;
    if (velocity.abs() > _velocidadeMinimaSwipe) {
      _advance();
      _restartTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final count = widget.items.length;
    final visibleCount = count < _maxVisible ? count : _maxVisible;
    final extraProfundidade = (visibleCount - 1) * _passoVertical;

    return SizedBox(
      // `width: double.infinity` é necessário: todos os filhos do Stack são
      // `Positioned`, então o Stack não tem nada para se dimensionar e
      // colapsa quando o pai passa largura frouxa (uma `Column` com
      // `crossAxisAlignment.start`, por exemplo). O resultado era o card
      // quase colado nas bordas, ignorando o `horizontalPadding`.
      width: double.infinity,
      // Altura do card da frente + o quanto os cards de trás "espiam" por
      // baixo dele.
      height: widget.cardHeight + extraProfundidade,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int depth = visibleCount - 1; depth >= 0; depth--)
            _buildSlot(context, depth, count),
        ],
      ),
    );
  }

  Widget _buildSlot(BuildContext context, int depth, int count) {
    final item = widget.items[(_currentIndex + depth) % count];
    final isFront = depth == 0;

    final horizontalInset = widget.horizontalPadding + (depth * _passoRecuoHorizontal);
    final topOffset = depth * _passoVertical;
    final opacity = depth == 0 ? 1.0 : (depth == 1 ? 0.85 : 0.55);

    final conteudo = AnimatedOpacity(
      duration: _animDuration,
      curve: Curves.easeOutCubic,
      opacity: opacity,
      child: isFront
          ? _StoreStackCard(item: item, height: widget.cardHeight, onTap: () => widget.onTap(item))
          : _StackedCardBackdrop(height: widget.cardHeight),
    );

    // `AnimatedPositioned` PRECISA ser filho direto do `Stack`. Antes, o card
    // da frente vinha embrulhado em `GestureDetector` > `Transform` e o de
    // trás em `IgnorePointer`, então nenhum dos dois era filho direto: o
    // `left`/`right` era descartado, o `Stack` media os filhos com restrição
    // frouxa e o `SizedBox(width: double.infinity)` de dentro do card esticava
    // até a borda da tela. Era essa a causa do carrossel colado nas laterais —
    // o `horizontalPadding` estava correto, só nunca chegava a ser aplicado.
    // O gesto e a translação agora ficam DENTRO do Positioned.
    return AnimatedPositioned(
      key: ValueKey(item.id),
      duration: _animDuration,
      curve: Curves.easeOutCubic,
      top: topOffset,
      left: horizontalInset,
      right: horizontalInset,
      child: isFront
          ? GestureDetector(
              onHorizontalDragUpdate: (details) => _dragDx.value += details.delta.dx,
              onHorizontalDragEnd: _onDragEnd,
              // `conteudo` (foto + texto do card da frente) é passado como
              // `child` do builder — construído uma vez só, não a cada delta
              // de drag; só o Transform.translate em volta dele é reconstruído.
              child: ValueListenableBuilder<double>(
                valueListenable: _dragDx,
                builder: (context, dx, child) =>
                    Transform.translate(offset: Offset(dx * 0.3, 0), child: child),
                child: conteudo,
              ),
            )
          : IgnorePointer(child: conteudo),
    );
  }
}

/// Silhueta lisa (sem foto) dos cards atrás do card da frente — mostrar a
/// imagem deles também ficaria poluído, já que só uma fatia fina aparece.
class _StackedCardBackdrop extends StatelessWidget {
  final double height;

  const _StackedCardBackdrop({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.mapColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
    );
  }
}

/// Card da frente: foto em sangria total com as informações da loja apoiadas
/// sobre um véu escuro no rodapé.
///
/// Antes era um banner branco em cápsula com só o nome dentro. O banner
/// resolvia o contraste (texto escuro sobre superfície opaca), mas custava
/// caro: tapava um terço da foto e, principalmente, o card inteiro dizia
/// apenas *qual* loja é — nada sobre *o que* ela é nem *quanto* vale. Numa
/// pilha de favoritos, que é uma lista de escolhas, é justamente isso que
/// diferencia um item do outro.
///
/// O véu em gradiente faz o mesmo trabalho de contraste sem tapar nada: ele
/// escurece só a faixa onde o texto se apoia, e é o que garante branco legível
/// tanto sobre uma foto clara (céu, parede branca) quanto sobre uma escura.
/// Sem ele, o texto seria branco-sobre-foto-qualquer — que é sorte, não
/// contraste.
class _StoreStackCard extends StatelessWidget {
  final StackedCardItem item;
  final double height;
  final VoidCallback onTap;

  const _StoreStackCard({required this.item, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Decorativa (sem `semanticLabel`): o nome da loja aparece como
              // texto logo abaixo.
              AppNetworkImage(
                path: item.imageUrl,
                displayWidth: MediaQuery.sizeOf(context).width,
                fallback: _buildFallback(context),
              ),

              // Véu de leitura. Começa transparente na metade de cima pra não
              // "sujar" a foto e fecha em preto quase sólido no rodapé, onde o
              // texto branco se apoia.
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                      colors: [Colors.transparent, Color(0xD9000000)],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.subtitle != null || item.rating != null) ...[
                      Row(
                        children: [
                          if (item.subtitle != null)
                            Flexible(child: _SeloDeVidro(texto: item.subtitle!)),
                          if (item.subtitle != null && item.rating != null)
                            const SizedBox(width: 6.0),
                          if (item.rating != null)
                            _SeloDeVidro(
                              texto: item.rating!.toStringAsFixed(1),
                              icone: AppIcons.star,
                              corIcone: ColorsPalette.ratingStar,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            // Branco literal, não `primaryText`: o fundo aqui
                            // é o véu escuro, que é o mesmo nos dois temas —
                            // um token que inverte deixaria texto escuro sobre
                            // preto no tema claro.
                            style: AppText.corpo(context).copyWith(
                              fontSize: 18.0,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: ColorsPalette.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Afordância de "abre alguma coisa": o card inteiro é
                        // tocável, mas sem nenhuma marca disso ele lê como
                        // ilustração.
                        Container(
                          height: 36.0,
                          width: 36.0,
                          decoration: const BoxDecoration(
                            color: ColorsPalette.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            AppIcons.arrowRight,
                            size: AppIconSize.md,
                            color: MfColor.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return ColoredBox(
      color: context.mapColors.surfaceAlt,
      child: Center(
        child: Icon(AppIcons.storefront, color: context.mapColors.iconMuted, size: 40.0),
      ),
    );
  }
}

/// Selo translúcido sobre o véu do card: categoria e nota.
///
/// Branco a 22% em vez de uma cápsula opaca — o objetivo é marcar a
/// informação sem abrir mais dois blocos sólidos por cima da foto. Sobre o
/// véu (preto a 85%) o resultado é escuro o suficiente pra sustentar o texto
/// branco em negrito.
class _SeloDeVidro extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final Color? corIcone;

  const _SeloDeVidro({required this.texto, this.icone, this.corIcone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: ColorsPalette.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: ColorsPalette.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 12.0, color: corIcone ?? ColorsPalette.white),
            const SizedBox(width: 4.0),
          ],
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.legenda(context).copyWith(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: ColorsPalette.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
