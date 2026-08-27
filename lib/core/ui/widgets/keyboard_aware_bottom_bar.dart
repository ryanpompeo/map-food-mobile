import 'package:flutter/material.dart';

/// Ancora a bottom bar no rodapé e a faz deslizar para fora quando o teclado
/// abre. Use como filho direto de um `Stack` — ele já devolve um [Positioned].
///
/// ## Por que isto é um widget, e não três linhas dentro do `build` da home
///
/// Ler `MediaQuery.of(context)` cria dependência no **objeto inteiro** de
/// `MediaQueryData`. Quando o teclado sobe, `viewInsets` é animado pelo
/// sistema e um `MediaQueryData` novo é publicado **a cada frame** — ou seja,
/// quem leu `MediaQuery.of` reconstrói ~60 vezes por segundo durante a
/// animação.
///
/// Nas homes, essa leitura estava no topo do `build` da página. O `build`
/// inteiro rodava por frame e, com ele, o `IndexedStack` recebia instâncias
/// **novas** de `HomeMapExplorer`, `SearchPage`, dashboard e perfil — e como
/// widget novo não é idêntico ao anterior, o Flutter descia a árvore e
/// reconstruía o mapa com todos os pins, o gráfico de atividade e os
/// formulários, tudo isso enquanto o teclado ainda estava abrindo. Era essa a
/// queda de FPS ao focar um campo.
///
/// Os `RepaintBoundary` que já existiam ali não pegavam esse caso: eles
/// isolam **pintura**, não construção. A árvore era reconstruída do mesmo
/// jeito; só a repintura das abas paradas é que era evitada.
///
/// Com a leitura aqui dentro, a reconstrução por frame fica restrita a esta
/// folha — uma barra com três ou cinco ícones —, e a home só reconstrói
/// quando algo dela realmente muda.
class KeyboardAwareBottomBar extends StatelessWidget {
  final Widget child;

  const KeyboardAwareBottomBar({super.key, required this.child});

  /// Tempo da saída. Um pouco mais rápido que o teclado do Android (~250ms)
  /// de propósito: a barra sai da frente antes de o campo focado subir.
  static const Duration _duracao = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    // `viewInsetsOf` e não `of`: mesmo confinada aqui, a dependência específica
    // evita rebuild quando muda qualquer outra coisa do MediaQuery (rotação,
    // padding do notch, escala de texto).
    final tecladoAberto = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      // `resizeToAvoidBottomInset: false` nas homes trava o Stack no lugar (a
      // barra não sobe agarrada ao teclado); este Slide é o que dá a saída
      // suave por baixo da tela ao focar um campo.
      child: AnimatedSlide(
        duration: _duracao,
        curve: Curves.easeOutCubic,
        offset: tecladoAberto ? const Offset(0, 1) : Offset.zero,
        child: child,
      ),
    );
  }
}
