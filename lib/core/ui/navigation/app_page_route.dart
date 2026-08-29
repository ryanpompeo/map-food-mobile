import 'package:flutter/cupertino.dart';

/// Rota padrão do app: `CupertinoPageRoute` em vez de `MaterialPageRoute`,
/// para a navegação manter o gesto nativo de arrastar da borda para voltar.
///
/// [settings] existe para as rotas **nomeadas** (a pilha inicial montada no
/// `main`): sem o nome, a rota fica anônima e qualquer código que consulte
/// `ModalRoute.of(context)?.settings.name` deixa de reconhecê-la.
PageRoute<T> appPageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return CupertinoPageRoute<T>(builder: builder, settings: settings);
}
