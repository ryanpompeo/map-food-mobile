import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/storage/prazo_abertura_storage.dart';
import 'package:map_food/features/merchant/presentation/controllers/agenda_de_fechamento.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/aguardar.dart';
import '../../support/api_falsa.dart';

StoreDto _loja(int id, {String status = 'ATIVA'}) =>
    StoreDto(id: id, nome: 'Loja $id', statusLoja: status, categoria: 'Lanches');

String _corpo(int id, {String status = 'ATIVA'}) =>
    '{"id": $id, "nome": "Loja $id", "statusLoja": "$status"}';

void main() {
  late ApiFalsa api;
  late DateTime agora;
  late AgendaDeFechamento agenda;

  AgendaDeFechamento criar({Duration maximo = const Duration(milliseconds: 500)}) =>
      AgendaDeFechamento(
        storeService: api.servico,
        agora: () => agora,
        minimo: Duration.zero,
        maximo: maximo,
      );

  List<String> fechamentos() =>
      api.doMetodo('PUT').map((chamada) => chamada.path).toList();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    api = ApiFalsa();
    api.responder('GET', '/lojas/7/completa', 200, _corpo(7));
    api.responder('PUT', '/lojas/7', 200, _corpo(7, status: 'INATIVA'));
    agora = DateTime(2026, 9, 21, 14);
    agenda = criar();
  });

  tearDown(() => agenda.esquecerTudo());

  test('quando o prazo chega, a loja é fechada e o prazo some', () async {
    await agenda.agendar(7, agora.add(const Duration(milliseconds: 60)));
    expect(agenda.prazoDe(7).value, isNotNull);

    await aguardarAte(() => fechamentos().isNotEmpty);
    await aguardarAte(() => agenda.prazoDe(7).value == null);

    expect(fechamentos(), ['/lojas/7']);
    expect(await PrazoAberturaStorage.ler(), isEmpty);
  });

  test('encerrar antes da hora cancela o fechamento automático', () async {
    await agenda.agendar(7, agora.add(const Duration(milliseconds: 60)));
    await agenda.cancelar(7);

    await escoar();
    await escoar();

    expect(fechamentos(), isEmpty);
    expect(agenda.prazoDe(7).value, isNull);
  });

  test('o prazo nunca passa do teto, mesmo pedindo mais', () async {
    final escolhido = await agenda.agendar(7, agora.add(const Duration(hours: 5)));

    expect(escolhido, agora.add(const Duration(milliseconds: 500)));
  });

  test('prorrogar respeita o teto contado a partir de agora', () async {
    await agenda.agendar(7, agora.add(const Duration(milliseconds: 100)));
    final novo = await agenda.prorrogar(7, const Duration(hours: 2));

    expect(novo, agora.add(const Duration(milliseconds: 500)));
  });

  group('ao reabrir o app', () {
    void guardar(DateTime quando, {int lojaId = 7}) => SharedPreferences.setMockInitialValues({
          'loja_prazo_abertura': jsonEncode({'$lojaId': quando.toIso8601String()}),
        });

    test('prazo vencido com o app fechado fecha a loja', () async {
      guardar(agora.subtract(const Duration(hours: 1)));
      agenda = criar();

      await agenda.retomar([_loja(7)]);

      expect(fechamentos(), ['/lojas/7']);
      expect(await PrazoAberturaStorage.ler(), isEmpty);
    });

    test('prazo ainda de pé religa o relógio e fecha na hora certa', () async {
      guardar(agora.add(const Duration(milliseconds: 60)));
      agenda = criar();

      await agenda.retomar([_loja(7)]);
      expect(fechamentos(), isEmpty);
      expect(agenda.prazoDe(7).value, isNotNull);

      await aguardarAte(() => fechamentos().isNotEmpty);
    });

    test('loja que já não está aberta só limpa o prazo, sem chamar a API', () async {
      guardar(agora.add(const Duration(hours: 1)));
      agenda = criar();

      await agenda.retomar([_loja(7, status: 'INATIVA')]);

      expect(api.chamadas, isEmpty);
      expect(await PrazoAberturaStorage.ler(), isEmpty);
    });
  });
}
