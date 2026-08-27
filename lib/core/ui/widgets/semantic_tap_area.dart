import 'package:flutter/material.dart';

/// Substitui `GestureDetector` cru nos controles icon-only do app (favoritar,
/// chips de categoria, etc.) — sem isso, esses controles não têm nenhum nó
/// de semântica (diferente de `InkWell`/`IconButton`/`ElevatedButton`, que
/// geram semântica de botão automaticamente), então leitores de tela
/// (TalkBack/VoiceOver) os ignoram ou não anunciam como interativos.
///
/// ## Cancelamento de toque
///
/// A ação **nunca** dispara no toque-baixa: ela vive no `onTap`, que só
/// acontece quando o dedo levanta **dentro** do alvo. Arrastar pra fora antes
/// de soltar aborta — é o que permite desistir de um toque errado, e é o que o
/// critério 2.5.2 do WCAG (*Pointer Cancellation*) exige.
///
/// Isso já valia com o `GestureDetector` cru, mas era **invisível**: sem
/// mudança de aparência ao pressionar, ninguém descobre que dá pra desistir.
/// Por isso [pressFeedback] existe — `onTapDown`/`onTapUp`/`onTapCancel` aqui
/// mudam **só a aparência**, jamais executam a ação. Ao arrastar pra fora, o
/// controle volta ao normal antes de soltar, mostrando que o toque foi
/// descartado.
///
/// [onTap] nulo desativa o toque (ex: chip em modo somente-leitura) — nesse
/// caso o nó de semântica também não é anunciado como botão, pra não sugerir
/// uma ação que não existe, e o feedback de pressão não roda.
class SemanticTapArea extends StatefulWidget {
  final String label;

  /// Complemento lido depois do rótulo pelo leitor de tela — o *resultado* da
  /// ação quando ele não é óbvio pelo rótulo ("abre o mapa em tela cheia").
  /// Não repita a palavra "botão": os leitores já anunciam o papel sozinhos.
  final String? hint;

  final bool? selected;
  final VoidCallback? onTap;
  final Widget child;

  /// Esmaece e encolhe levemente enquanto pressionado. Desligue apenas quando
  /// o próprio [child] já reagir ao toque (ex: um `InkWell` com ripple por
  /// dentro), pra não empilhar dois feedbacks.
  final bool pressFeedback;

  const SemanticTapArea({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.selected,
    this.hint,
    this.pressFeedback = true,
  });

  @override
  State<SemanticTapArea> createState() => _SemanticTapAreaState();
}

class _SemanticTapAreaState extends State<SemanticTapArea> {
  /// Curto de propósito: acima disso a resposta ao toque parece atrasada.
  static const _duracao = Duration(milliseconds: 90);

  bool _pressionado = false;

  void _marcar(bool valor) {
    if (_pressionado == valor) return;
    setState(() => _pressionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.onTap != null;
    final comFeedback = habilitado && widget.pressFeedback;

    // "Reduzir movimento" (iOS e Android): quem liga essa opção do sistema
    // sente enjoo/desconforto com elementos que se mexem. O esmaecimento
    // continua — ele é a informação; a escala é só o enfeite.
    final semMovimento = MediaQuery.disableAnimationsOf(context);

    Widget conteudo = widget.child;
    if (comFeedback) {
      conteudo = AnimatedScale(
        duration: _duracao,
        scale: _pressionado && !semMovimento ? 0.97 : 1.0,
        child: AnimatedOpacity(
          duration: _duracao,
          opacity: _pressionado ? 0.6 : 1.0,
          child: conteudo,
        ),
      );
    }

    return Semantics(
      button: habilitado,
      enabled: habilitado,
      label: widget.label,
      hint: widget.hint,
      selected: widget.selected,
      child: GestureDetector(
        // A ação fica só aqui: `onTap` = dedo levantou dentro do alvo.
        onTap: widget.onTap,
        // Os três abaixo mexem exclusivamente no visual.
        onTapDown: comFeedback ? (_) => _marcar(true) : null,
        onTapUp: comFeedback ? (_) => _marcar(false) : null,
        onTapCancel: comFeedback ? () => _marcar(false) : null,
        behavior: HitTestBehavior.opaque,
        child: conteudo,
      ),
    );
  }
}
