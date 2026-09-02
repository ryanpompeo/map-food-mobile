import 'package:flutter/material.dart';

class SemanticTapArea extends StatefulWidget {
  final String label;

  final String? hint;

  final bool? selected;
  final VoidCallback? onTap;
  final Widget child;

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
        onTap: widget.onTap,
        onTapDown: comFeedback ? (_) => _marcar(true) : null,
        onTapUp: comFeedback ? (_) => _marcar(false) : null,
        onTapCancel: comFeedback ? () => _marcar(false) : null,
        behavior: HitTestBehavior.opaque,
        child: conteudo,
      ),
    );
  }
}
