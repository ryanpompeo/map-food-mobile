import 'package:flutter_test/flutter_test.dart';

Future<void> aguardarAte(
  bool Function() condicao, {
  Duration limite = const Duration(seconds: 3),
}) async {
  final prazo = DateTime.now().add(limite);
  while (!condicao()) {
    if (DateTime.now().isAfter(prazo)) fail('condição não atingida em $limite');
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<void> escoar() => Future<void>.delayed(const Duration(milliseconds: 30));
