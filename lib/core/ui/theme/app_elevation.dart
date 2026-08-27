import 'package:flutter/material.dart';

class AppElevation {
  const AppElevation._();

  /// Nível 1 — card em lista, item destacado dentro da página.
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Nível 2 — o que flutua sobre outro conteúdo: barra de busca sobre o
  /// mapa, bottom bar, botão de recentralizar, bottom sheet.
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Nível 3 — card imersivo de foto, onde a sombra precisa segurar uma
  /// superfície grande e visualmente pesada.
  static const List<BoxShadow> hero = [
    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x29000000), blurRadius: 32, offset: Offset(0, 12)),
  ];
}
