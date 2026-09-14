import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/features/merchant/presentation/controllers/configuracao_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/estado_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/ronda_manager.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

import '../../support/aguardar.dart';
import '../../support/api_falsa.dart';
import '../../support/fonte_posicao_falsa.dart';

StoreDto _loja(int id, {String status = 'ATIVA'}) =>
    StoreDto(id: id, nome: 'Loja $id', statusLoja: status, categoria: 'Lanches');

String _resumo(int id, {int? segundosSemSinal}) =>
    '{"id": $id, "nome": "Loja $id", "statusLoja": "ATIVA", "segundosSemSinal": ${segundosSemSinal ?? 'null'}}';

void main() {
  late FontePosicaoFalsa fonte;
  late ApiFalsa api;
  late DateTime agora;
  late RondaManager ronda;

  final abertura = posicaoDeTeste();
  final cemMetrosAdiante = posicaoDeTeste(latitude: -22.9058);

  EstadoRonda estado(int id) => ronda.estadoDe(id).value;

  Future<void> aguardarEnvio(int id) => aguardarAte(() => estado(id).ultimoEnvioEm != null);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    fonte = FontePosicaoFalsa();
    LocationService.substituirFonte(fonte, esperas: const [Duration(milliseconds: 1)]);
    api = ApiFalsa();
    agora = DateTime(2026, 9, 13, 10);
    ronda = RondaManager(
      storeService: api.servico,
      configuracao: const ConfiguracaoRonda(esperasDeReenvio: [Duration(milliseconds: 1)]),
      agora: () => agora,
    );
  });

  tearDown(() async {
    ronda.encerrar();
    LocationService.restaurarFonte();
    await fonte.fechar();
  });

  group('transmissão', () {
    test('abrir com a posição do GPS transmite na hora e liga a leitura contínua', () async {
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarEnvio(7);

      expect(api.patches, ['/lojas/7/posicao']);
      expect(estado(7).fase, FaseRonda.ativa);
      expect(estado(7).ultimoEnvioEm, agora);
      expect(fonte.lendo, isTrue);
    });

    test('uma leitura boa vai para todas as lojas em ronda do comerciante', () async {
      ronda.acompanhar(_loja(7));
      ronda.acompanhar(_loja(8));
      await aguardarAte(() => fonte.lendo);

      fonte.atual.add(abertura);
      await aguardarAte(() => api.patches.length == 2);

      expect(api.patches, unorderedEquals(['/lojas/7/posicao', '/lojas/8/posicao']));
    });

    test('duas lojas em ronda dividem uma única leitura do GPS', () async {
      ronda.acompanhar(_loja(7));
      ronda.acompanhar(_loja(8));
      await aguardarAte(() => fonte.lendo);

      expect(fonte.pedidos, hasLength(1));
    });

    test('comerciante parado não gera envio além do inicial', () async {
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarEnvio(7);

      fonte.atual.add(abertura);
      await escoar();

      expect(api.patches, hasLength(1));
    });

    test('falhas de rede são contadas e o próximo sucesso as zera', () async {
      api.responder('PATCH', '/lojas/7/posicao', 500, '{}');
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarAte(() => estado(7).falhasSeguidas > 0);

      api.responder('PATCH', '/lojas/7/posicao', 204);
      await aguardarEnvio(7);

      expect(estado(7).falhasSeguidas, 0);
    });
  });

  group('sincronização ao abrir o app', () {
    test('retoma só as lojas que o servidor diz estarem em ronda; loja fixa fica de fora', () async {
      api.responder('GET', '/lojas/7/completa', 200, _resumo(7, segundosSemSinal: 90));
      api.responder('GET', '/lojas/8/completa', 200, _resumo(8));

      await ronda.sincronizar([_loja(7), _loja(8), _loja(9, status: 'INATIVA')]);

      expect(ronda.acompanha(7), isTrue);
      expect(ronda.acompanha(8), isFalse);
      expect(ronda.acompanha(9), isFalse);
      expect(api.chamadas.any((c) => c.path == '/lojas/9/completa'), isFalse);
    });

    test('loja fechada enquanto a sincronização espera a API não é retomada por ela', () async {
      api.responder('GET', '/lojas/7/completa', 200, _resumo(7, segundosSemSinal: 90));
      final sincronia = ronda.sincronizar([_loja(7)]);
      ronda.soltar(7);
      await sincronia;

      expect(ronda.acompanha(7), isFalse);
    });
  });

  group('encerramento', () {
    test('soltar a última loja desliga o GPS', () async {
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarAte(() => fonte.lendo);

      ronda.soltar(7);

      expect(fonte.lendo, isFalse);
      expect(estado(7).fase, FaseRonda.parada);
    });

    test('recusa da API encerra a ronda daquela loja e guarda o motivo', () async {
      api.responder('PATCH', '/lojas/7/posicao', 409,
          '{"statusLoja": "SUSPENSA", "message": "Sua loja foi suspensa pela moderação"}');

      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarAte(() => estado(7).fase == FaseRonda.recusada);

      expect(estado(7).recusa?.status, StatusLoja.suspensa);
      expect(ronda.acompanha(7), isFalse);
      expect(fonte.lendo, isFalse);
    });

    test('a recusa de uma loja não derruba a ronda das outras', () async {
      api.responder('PATCH', '/lojas/7/posicao', 409, '{"statusLoja": "INATIVA"}');

      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      ronda.acompanhar(_loja(8));
      await aguardarAte(() => estado(7).fase == FaseRonda.recusada);

      expect(ronda.acompanha(8), isTrue);
      expect(fonte.lendo, isTrue);
    });

    test('soltar uma loja que já saiu não apaga o motivo da recusa', () async {
      api.responder('PATCH', '/lojas/7/posicao', 409, '{"statusLoja": "INATIVA"}');
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarAte(() => estado(7).fase == FaseRonda.recusada);

      ronda.soltar(7);

      expect(estado(7).fase, FaseRonda.recusada);
    });

    test('logout encerra todas as rondas e o GPS', () async {
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      ronda.acompanhar(_loja(8));
      await aguardarAte(() => fonte.lendo);

      ronda.encerrar();

      expect(ronda.acompanha(7), isFalse);
      expect(ronda.acompanha(8), isFalse);
      expect(fonte.lendo, isFalse);
    });
  });

  group('saúde da ronda', () {
    test('parado há 5 min, o heartbeat reenvia a última posição', () async {
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarEnvio(7);

      agora = agora.add(const Duration(minutes: 4));
      ronda.verificarSaude();
      await escoar();
      expect(api.patches, hasLength(1));

      agora = agora.add(const Duration(minutes: 1));
      ronda.verificarSaude();
      await aguardarAte(() => api.patches.length == 2);
    });

    test('2 min sem nenhuma leitura, o watchdog religa o GPS', () async {
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarAte(() => fonte.lendo);
      expect(fonte.pedidos, hasLength(1));

      agora = agora.add(const Duration(minutes: 2));
      ronda.verificarSaude();

      expect(fonte.pedidos, hasLength(2));
    });

    test('com o app em segundo plano, o watchdog não religa o GPS, mas o heartbeat segue', () async {
      final binding = TestWidgetsFlutterBinding.instance;
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarEnvio(7);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      addTearDown(() => binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));

      agora = agora.add(const Duration(minutes: 5));
      ronda.verificarSaude();
      await aguardarAte(() => api.patches.length == 2);

      expect(fonte.pedidos, hasLength(1));
    });

    test('GPS desligado no meio da ronda muda a fase, e religá-lo retoma a leitura', () async {
      ronda.acompanhar(_loja(7), posicaoInicial: abertura);
      await aguardarAte(() => fonte.lendo);

      fonte.atual.addError(const LocationServiceDisabledException());
      await aguardarAte(() => estado(7).fase == FaseRonda.gpsDesligado);

      fonte.servico.add(ServiceStatus.enabled);
      await aguardarAte(() => fonte.pedidos.length == 2);

      fonte.atual.add(cemMetrosAdiante);
      await aguardarAte(() => estado(7).fase == FaseRonda.ativa);
    });

    test('sem permissão, nenhuma leitura do GPS é aberta', () async {
      fonte.acesso = AcessoLocalizacao.negado;

      ronda.acompanhar(_loja(7));
      await aguardarAte(() => estado(7).fase == FaseRonda.semPermissao);

      expect(fonte.pedidos, isEmpty);
    });

    test('loja solta enquanto a permissão é pedida não deixa o GPS ligado', () async {
      fonte.acessoPendente = Completer<AcessoLocalizacao>();

      ronda.acompanhar(_loja(7));
      ronda.soltar(7);
      fonte.acessoPendente!.complete(AcessoLocalizacao.liberado);
      await escoar();

      expect(fonte.pedidos, isEmpty);
    });
  });
}
