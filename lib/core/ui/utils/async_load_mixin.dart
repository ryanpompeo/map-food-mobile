import 'package:flutter/widgets.dart';
import 'package:map_food/core/errors/exception.dart';

@immutable
class AsyncState<T> {
  final bool isLoading;
  final String? errorMessage;
  final T? data;

  const AsyncState({this.isLoading = false, this.errorMessage, this.data});

  const AsyncState.loading({T? data}) : this(isLoading: true, data: data);
}

mixin AsyncLoadMixin<T, W extends StatefulWidget> on State<W> {
  AsyncState<T> asyncState = const AsyncState();

  String get genericErrorMessage =>
      'Não foi possível carregar os dados. Tente novamente.';

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
