import 'package:flutter/cupertino.dart';

/// Transição padrão de navegação do app. Usa CupertinoPageRoute em vez do
/// PageRouteBuilder fade+slide anterior para herdar o gesto nativo de
/// swipe-to-go-back (arrastar da borda esquerda) em Android e iOS — um
/// PageRouteBuilder genérico não implementa esse reconhecedor de gesto.
/// Mesma assinatura de MaterialPageRoute (parâmetro nomeado `builder`), pra
/// servir como substituto direto nos `Navigator.push(context, ...)` do app.
PageRoute<T> appPageRoute<T>({required WidgetBuilder builder}) {
  return CupertinoPageRoute<T>(builder: builder);
}
