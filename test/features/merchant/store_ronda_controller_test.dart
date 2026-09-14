import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/merchant/presentation/controllers/configuracao_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/estado_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/ronda_manager.dart';
import 'package:map_food/features/merchant/presentation/controllers/situacao_loja.dart';
import 'package:map_food/features/merchant/presentation/controllers/store_ronda_controller.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/aguardar.dart';
import '../../support/api_falsa.dart';
import '../../support/fonte_posicao_falsa.dart';

const _comerciante = AuthResponse(
  token: 'token',
  tipo: 'COMERCIANTE',
  id: 3,
  nome: 'Zé',
  email: 'ze@mapfood.test',
);

StoreDto _loja({String status = 'ATIVA'}) => StoreDto(
      id: 7,
      nome: 'Carrinho do Zé',
      statusLoja: status,
      categoria: 'Lanches',
      categoriaIds: const [3],
      cep: '00000-000',
    );

const _lojaAberta = '{"id": 7, "nome": "Carrinho do Zé", "statusLoja": "ATIVA"}';
const _lojaFechada = '{"id": 7, "nome": "Carrinho do Zé", "statusLoja": "INATIVA"}';
const _recusaFechada =
    '{"statusLoja": "INATIVA", "message": "Sua loja está fechada — abra de novo para voltar ao mapa"}';

void main() {
  late FontePosicaoFalsa fonte;
  late ApiFalsa api;
  late RondaManager ronda;
  final criados = <StoreRondaController>[];

  StoreRondaController tela(
    StoreDto loja, {
    void Function(StoreDto)? aoAtualizar,
    DateTime Function()? agora,
  }) {
    final controller = StoreRondaController(
      store: loja,
      onStoreUpdated: aoAtualizar,
      storeService: api.servico,
      ronda: ronda,
      agora: agora,
    );
    criados.add(controller);
    return controller;
  }

  Future<void> rondaEmAndamento() async {
    ronda.acompanhar(_loja(), posicaoInicial: posicaoDeTeste());
    await aguardarAte(() => ronda.estadoDe(7).value.ultimoEnvioEm != null);
  }

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SessionStore.instance.signIn(_comerciante);
    fonte = FontePosicaoFalsa();
    LocationService.substituirFonte(fonte, esperas: const [Duration(milliseconds: 1)]);
    api = ApiFalsa();
    ronda = RondaManager(
      storeService: api.servico,
      configuracao: const ConfiguracaoRonda(esperasDeReenvio: [Duration(milliseconds: 1)]),
    );
  });

  tearDown(() async {
    for (final controller in criados) {
      controller.dispose();
    }
    criados.clear();
    ronda.encerrar();
    LocationService.restaurarFonte();
    await fonte.fechar();
    await SessionStore.instance.signOut();
  });

  test('descartar a tela não para a ronda: ela pertence à sessão, não ao widget', () async {
    await rondaEmAndamento();

    tela(_loja()).dispose();
    criados.clear();

    expect(ronda.acompanha(7), isTrue);
    expect(fonte.lendo, isTrue);
  });

  test('a tela reflete a ronda que já estava acontecendo', () async {
    await rondaEmAndamento();

    final controller = tela(_loja());

    expect(controller.situacao, SituacaoLoja.transmitindo);
    expect(controller.ultimaPosicaoEm, isNotNull);
    expect(controller.precisaoMetros, 8);
  });

  test('loja aberta sem ronda é fixa e não finge que o GPS caiu', () {
    final controller = tela(_loja());

    expect(controller.situacao, SituacaoLoja.fixa);
    expect(controller.avisoPosicao, isNull);
  });

  test('loja suspensa tem situação própria, não a de fechada', () {
    expect(tela(_loja(status: 'SUSPENSA')).situacao, SituacaoLoja.suspensa);
  });

  test('acompanhar a posição de uma loja fixa liga a ronda sem mexer no status', () async {
    final controller = tela(_loja());

    final erro = await controller.acompanharPosicao();
    await aguardarAte(() => api.patches.isNotEmpty);

    expect(erro, isNull);
    expect(ronda.acompanha(7), isTrue);
    expect(api.patches, ['/lojas/7/posicao']);
    expect(api.doMetodo('PUT'), isEmpty);
    expect(controller.situacao, SituacaoLoja.transmitindo);
  });

  test('acompanhar sem GPS explica o motivo e não liga a ronda', () async {
    fonte.acesso = AcessoLocalizacao.negado;

    final erro = await tela(_loja()).acompanharPosicao();

    expect(erro, contains('acompanhar sua posição'));
    expect(ronda.acompanha(7), isFalse);
    expect(api.chamadas, isEmpty);
  });

  test('GPS desligado depois de enviar vira sem sinal, com o prazo do fechamento automático',
      () async {
    await rondaEmAndamento();
    final envio = ronda.estadoDe(7).value.ultimoEnvioEm!;
    final controller = tela(_loja(), agora: () => envio.add(const Duration(minutes: 4)));

    fonte.atual.addError(const LocationServiceDisabledException());
    await aguardarAte(() => controller.situacao == SituacaoLoja.semSinal);

    expect(controller.semSinalHa, const Duration(minutes: 4));
    expect(controller.fechaEm, const Duration(minutes: 11));
    expect(controller.avisoPosicao, contains('GPS desligado'));
  });

  test('passado o limite de 15 min, o prazo para em zero', () async {
    await rondaEmAndamento();
    final envio = ronda.estadoDe(7).value.ultimoEnvioEm!;
    final controller = tela(_loja(), agora: () => envio.add(const Duration(minutes: 20)));

    fonte.atual.addError(const LocationServiceDisabledException());
    await aguardarAte(() => controller.situacao == SituacaoLoja.semSinal);

    expect(controller.fechaEm, Duration.zero);
  });

  test('transmitindo normalmente não tem prazo de fechamento', () async {
    await rondaEmAndamento();
    final envio = ronda.estadoDe(7).value.ultimoEnvioEm!;

    final controller = tela(_loja(), agora: () => envio.add(const Duration(minutes: 4)));

    expect(controller.situacao, SituacaoLoja.transmitindo);
    expect(controller.fechaEm, isNull);
  });

  test('abrir loja suspensa é recusado antes de pedir GPS ou chamar a API', () async {
    final erro = await tela(_loja(status: 'SUSPENSA')).alternarStatus();

    expect(erro, contains('suspensa'));
    expect(fonte.pedidos, isEmpty);
    expect(api.chamadas, isEmpty);
  });

  test('abrir manda o PUT enxuto, sem o CEP legado, e começa a ronda', () async {
    api.responder('PUT', '/lojas/7', 200, _lojaAberta);
    final controller = tela(_loja(status: 'INATIVA'));

    final erro = await controller.alternarStatus();
    await aguardarAte(() => api.patches.isNotEmpty);

    expect(erro, isNull);
    final corpo = api.doMetodo('PUT').single.data as Map<String, dynamic>;
    expect(corpo['statusLoja'], 'ATIVA');
    expect(corpo.containsKey('cep'), isFalse);
    expect(ronda.acompanha(7), isTrue);
    expect(api.patches, ['/lojas/7/posicao']);
    expect(controller.aberta, isTrue);
  });

  test('sem GPS disponível, abrir explica o motivo e não chama a API', () async {
    fonte.acesso = AcessoLocalizacao.servicoDesligado;

    final erro = await tela(_loja(status: 'INATIVA')).alternarStatus();

    expect(erro, contains('Sem localização'));
    expect(api.chamadas, isEmpty);
  });

  test('fechar solta a ronda', () async {
    api.responder('PUT', '/lojas/7', 200, _lojaFechada);
    await rondaEmAndamento();
    final controller = tela(_loja());

    await controller.alternarStatus();

    expect(ronda.acompanha(7), isFalse);
    expect(controller.aberta, isFalse);
  });

  test('recusa do servidor fecha a loja na tela, mostra o motivo e avisa a página', () async {
    api.responder('PATCH', '/lojas/7/posicao', 409, _recusaFechada);
    StoreDto? avisada;
    final controller = tela(_loja(), aoAtualizar: (loja) => avisada = loja);

    ronda.acompanhar(_loja(), posicaoInicial: posicaoDeTeste());
    await aguardarAte(() => !controller.aberta);

    expect(controller.avisoPosicao, 'Sua loja está fechada — abra de novo para voltar ao mapa');
    expect(avisada?.status, StatusLoja.inativa);
  });

  test('a página repassando a loja já fechada não apaga o motivo da recusa', () async {
    api.responder('PATCH', '/lojas/7/posicao', 409, _recusaFechada);
    final controller = tela(_loja());
    ronda.acompanhar(_loja(), posicaoInicial: posicaoDeTeste());
    await aguardarAte(() => ronda.estadoDe(7).value.fase == FaseRonda.recusada);

    controller.atualizarStore(_loja(status: 'INATIVA'));

    expect(controller.avisoPosicao, contains('fechada'));
  });

  test('três falhas seguidas acendem o aviso de conexão', () async {
    api.responder('PATCH', '/lojas/7/posicao', 500, '{}');
    final controller = tela(_loja());

    ronda.acompanhar(_loja(), posicaoInicial: posicaoDeTeste());
    await aguardarAte(() => controller.avisoPosicao?.contains('não está subindo') ?? false);

    expect(controller.situacao, SituacaoLoja.semSinal);
  });
}
