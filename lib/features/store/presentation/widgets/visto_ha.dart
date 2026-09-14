import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

String? rotuloVistoHa(Duration? semSinal) {
  if (semSinal == null) return null;
  final minutos = semSinal.inMinutes;
  return minutos < 1 ? 'Visto agora' : 'Visto há $minutos min';
}

class VistoHa extends StatefulWidget {
  final int lojaId;

  final Widget Function(BuildContext context, String texto) builder;

  const VistoHa({super.key, required this.lojaId, required this.builder});

  @override
  State<VistoHa> createState() => _VistoHaState();
}

class _VistoHaState extends State<VistoHa> {
  static const Duration _intervalo = Duration(seconds: 30);

  final ActiveStoresManager _manager = ActiveStoresManager.instance;
  Timer? _relogio;
  String? _texto;

  @override
  void initState() {
    super.initState();
    _texto = _calcular();
    _manager.addListener(_atualizar);
    _relogio = Timer.periodic(_intervalo, (_) => _atualizar());
  }

  @override
  void didUpdateWidget(covariant VistoHa oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lojaId != widget.lojaId) _texto = _calcular();
  }

  @override
  void dispose() {
    _relogio?.cancel();
    _manager.removeListener(_atualizar);
    super.dispose();
  }

  String? _calcular() => rotuloVistoHa(_manager.semSinalHa(widget.lojaId));

  void _atualizar() {
    final novo = _calcular();
    if (novo != _texto && mounted) setState(() => _texto = novo);
  }

  @override
  Widget build(BuildContext context) {
    final texto = _texto;
    return texto == null ? const SizedBox.shrink() : widget.builder(context, texto);
  }
}
