import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// "Puxe para atualizar" — o gesto padrão do app.
///
/// Existe porque um `RefreshIndicator` cru erra duas coisas com facilidade, e
/// as duas já tinham sido acertadas à mão em telas isoladas antes de virarem
/// regra aqui:
///
/// 1. **A cor.** O indicador nasce com o roxo do Material, que não é nenhuma
///    cor do MapFood.
/// 2. **A física da rolagem.** Sem `AlwaysScrollableScrollPhysics`, o gesto
///    simplesmente não existe quando o conteúdo cabe na tela — e a lista curta
///    (nenhum favorito ainda, nenhuma avaliação ainda) é justamente onde a
///    pessoa mais puxa para conferir se algo mudou. O `parent` preserva o
///    `BouncingScrollPhysics` que o app usa em todas as listas.
///
/// A física precisa ser aplicada **na lista filha**, não aqui — por isso
/// [physics] é exposta como constante para quem monta o scrollable:
///
/// ```dart
/// AppRefresh(
///   onRefresh: _carregar,
///   child: ListView(physics: AppRefresh.physics, children: [...]),
/// )
/// ```
class AppRefresh extends StatelessWidget {
  /// Recarga. Só termina quando o dado novo chegou — é o que segura a
  /// animação até valer a pena soltar.
  final Future<void> Function() onRefresh;

  /// O scrollable. Deve usar [physics], senão o gesto some em lista curta.
  final Widget child;

  const AppRefresh({super.key, required this.onRefresh, required this.child});

  /// Física a aplicar no scrollable filho.
  static const ScrollPhysics physics =
      AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  /// Embrulha um conteúdo que **não é uma lista** — um estado vazio, uma
  /// mensagem de erro — num scrollable de altura cheia, centralizado.
  ///
  /// `RefreshIndicator` só reage a um filho que rola, e um `Center` solto não
  /// rola: sem isto o gesto desapareceria justamente nos dois estados em que a
  /// pessoa mais quer tentar de novo ("nada aqui ainda", "falha de rede").
  static Widget centralizado(Widget child) {
    return CustomScrollView(
      physics: physics,
      slivers: [
        SliverFillRemaining(hasScrollBody: false, child: Center(child: child)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ColorsPalette.redComponents,
      // O disco atrás do indicador acompanha o tema: no escuro, o branco
      // padrão do Material vira uma pastilha clara sobre o fundo escuro.
      backgroundColor: context.mapColors.cardSurface,
      child: child,
    );
  }
}
