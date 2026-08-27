import 'package:flutter/widgets.dart';
import 'package:map_food/core/errors/exception.dart';

/// Estado imutável de uma operação assíncrona de tela: carregando, com erro,
/// ou com dado carregado. `data` pode conviver com um carregamento em
/// segundo plano (`load` chamado de novo pra dar refresh) — nesse caso
/// `isLoading` é true e `data` ainda é o valor da carga anterior, útil pra
/// telas que preferem não esconder o conteúdo já visível atrás de um spinner.
@immutable
class AsyncState<T> {
  final bool isLoading;
  final String? errorMessage;
  final T? data;

  const AsyncState({this.isLoading = false, this.errorMessage, this.data});

  const AsyncState.loading({T? data}) : this(isLoading: true, data: data);
}

/// Generaliza o padrão `_isLoading`/`_errorMessage`/try-catch-setState
/// reimplementado do zero em várias telas do app (ver auditoria de
/// arquitetura: search_page.dart, merchant_home_page.dart,
/// consumer_complaints_page.dart, consumer_review_page.dart,
/// merchant_register_page.dart, login_page.dart, consumer_register_page.dart
/// — todas convergiram organicamente pro mesmo trio de campos). Preserva o
/// tratamento diferenciado de [AppException] (mensagem vinda da API) vs.
/// erro genérico, que hoje varia de tela pra tela.
///
/// Não cobre orquestrações com múltiplas fontes de dado ou efeitos colaterais
/// no meio do carregamento (ex: navegação condicional) — nesses casos, usar
/// [load] só pro recurso principal da tela e tratar o resto à parte, como em
/// `MerchantHomePage`.
mixin AsyncLoadMixin<T, W extends StatefulWidget> on State<W> {
  AsyncState<T> asyncState = const AsyncState();

  /// Mensagem padrão quando o erro não é um [AppException] (falha de rede,
  /// parse, etc.) — sobrescreva por tela quando o texto genérico não servir.
  String get genericErrorMessage =>
      'Não foi possível carregar os dados. Tente novamente.';

  /// Executa [fetch] e atualiza [asyncState]. Chamar de novo (ex: botão
  /// "Tentar novamente") recarrega — por padrão mantém o `data` anterior
  /// visível enquanto a nova busca está em voo; passe `keepDataOnReload:
  /// false` pra esconder o conteúdo velho atrás do loading a cada chamada.
  ///
  /// [onData], se informado, roda com o resultado assim que [fetch] resolve
  /// — **antes** de `asyncState` ser atualizado. Devolva `false` pra pular a
  /// atualização de `asyncState` (ex: quando o callback já navegou pra outra
  /// tela por causa do resultado — como uma lista vazia — e não faz sentido
  /// deixar esta tela renderizar esse dado por um frame antes de sair).
  /// Sem [onData], o padrão é sempre `true` (commit normal).
  Future<void> load(
    Future<T> Function() fetch, {
    bool keepDataOnReload = true,
    bool Function(T data)? onData,
  }) async {
    if (!mounted) return;
    setState(() {
      asyncState = AsyncState.loading(
        data: keepDataOnReload ? asyncState.data : null,
      );
    });
    try {
      final data = await fetch();
      if (!mounted) return;
      final commit = onData?.call(data) ?? true;
      if (!commit || !mounted) return;
      setState(() => asyncState = AsyncState(data: data));
    } on AppException catch (e) {
      if (!mounted) return;
      setState(
        () => asyncState = AsyncState(errorMessage: e.message, data: asyncState.data),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => asyncState = AsyncState(errorMessage: genericErrorMessage, data: asyncState.data),
      );
    }
  }
}
