import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/notificacoes/notificacoes.dart';

void main() {
  late List<MethodCall> chamadas;
  Object? resposta;

  void responder(Object? valor) => resposta = valor;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    chamadas = [];
    resposta = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(Notificacoes.canal, (chamada) async {
      chamadas.add(chamada);
      if (resposta is Exception) throw resposta!;
      return resposta;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(Notificacoes.canal, null);
  });

  test('manda titulo, texto e id para o lado Android', () async {
    final mostrou = await Notificacoes.mostrar(
      titulo: 'Você saiu do mapa',
      texto: 'Sua loja parou de aparecer para os clientes',
    );

    expect(mostrou, isTrue);
    expect(chamadas.single.method, 'mostrar');
    expect(chamadas.single.arguments, {
      'id': Notificacoes.avisoDaLoja,
      'titulo': 'Você saiu do mapa',
      'texto': 'Sua loja parou de aparecer para os clientes',
    });
  });

  test('avisos de assuntos diferentes usam ids diferentes e não se apagam', () async {
    await Notificacoes.mostrar(titulo: 'a', texto: 'a');
    await Notificacoes.mostrar(titulo: 'b', texto: 'b', id: 7302);

    final ids = chamadas
        .map((chamada) => (chamada.arguments as Map)['id'])
        .toList();
    expect(ids, [Notificacoes.avisoDaLoja, 7302]);
  });

  test('falha do lado Android não derruba quem chamou', () async {
    responder(PlatformException(code: 'sem_permissao'));

    final mostrou = await Notificacoes.mostrar(titulo: 'a', texto: 'a');

    expect(mostrou, isFalse);
  });

  test('Android sem suporte responde falso sem quebrar', () async {
    responder(false);

    expect(await Notificacoes.mostrar(titulo: 'a', texto: 'a'), isFalse);
  });
}
