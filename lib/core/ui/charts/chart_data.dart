import 'package:flutter/painting.dart' show Color;

/// Contrato entre quem **agrega** os números e quem os **desenha**.
///
/// Os widgets de gráfico (`core/ui/charts/`) recebem só estes tipos — nunca um
/// DTO, um service ou um controller. É o que os mantém testáveis sem API no ar
/// e reutilizáveis por qualquer tela que já tenha os números em mãos.

/// Uma fatia de rosca/pizza.
///
/// A cor entra aqui, e não na agregação, de propósito: numa rosca a cor **é**
/// a legenda, e escolhê-la depende do tema (claro/escuro) — ou seja, é decisão
/// de quem constrói a tela, com um `BuildContext` em mãos.
class DonutSlice {
  final String label;
  final double value;
  final Color color;

  const DonutSlice({required this.label, required this.value, required this.color});
}
