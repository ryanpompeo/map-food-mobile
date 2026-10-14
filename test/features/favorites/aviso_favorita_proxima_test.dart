import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/storage/aviso_proximidade_storage.dart';
import 'package:map_food/features/favorites/presentation/controllers/aviso_favorita_proxima.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/api_falsa.dart';
import '../../support/fonte_posicao_falsa.dart';

const _praca = (latitude: -22.6050, longitude: -47.4172);

StoreDto _favorita({
  int id = 5,
  String nome = 'Salgado do Zissimopulos',
  String status = 'ATIVA',
  double? latitude = -22.6050,
  double? longitude = -47.4172,
}) =>
    StoreDto(
      id: id,
      nome: nome,
      statusLoja: status,
      categoria: 'Salgados',
      latitude: latitude,
      longitude: longitude,
    );

String _favoritaJson(StoreDto loja) =>
    '{"id": ${loja.id}, "nome": "${loja.nome}", "statusLoja": "${loja.statusLoja}", '
    '"latitude": ${loja.latitude}, "longitude": ${loja.longitude}}';

void main() {
  late ApiFalsa api;
  late List<String> avisos;
  late DateTime agora;

  Future<void> comFavoritas(List<StoreDto> lojas) async {
    api.responder(
      'GET',
      '/favoritos/completo',
      200,
      '[${lojas.map(_favoritaJson).join(',')}]',
    );
    FavoritesManager.instance.service = api.servicoFavoritos;
    await FavoritesManager.instance.load();
  }

  AvisoFavoritaProxima criar() => AvisoFavoritaProxima(
        avisar: (motivo) async => avisos.add(motivo),
        agora: () => agora,
      );

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    api = ApiFalsa();
    avisos = [];
    agora = DateTime(2026, 10, 13, 12);
  });

  tearDown(() {
    FavoritesManager.instance.clear();
  });

  test('favorita aberta dentro de 1 km avisa com a distância', () async {
    await comFavoritas([_favorita()]);

    await criar().avaliar(posicaoDeTeste(
      latitude: _praca.latitude + 0.004,
      longitude: _praca.longitude,
    ));

    expect(avisos.single, contains('Salgado do Zissimopulos'));
    expect(avisos.single, contains('m de você agora'));
  });

  test('favorita longe não avisa', () async {
    await comFavoritas([_favorita()]);

    await criar().avaliar(posicaoDeTeste(
      latitude: _praca.latitude + 0.05,
      longitude: _praca.longitude,
    ));

    expect(avisos, isEmpty);
  });

  test('favorita fechada não avisa, mesmo colada em você', () async {
    await comFavoritas([_favorita(status: 'INATIVA')]);

    await criar().avaliar(posicaoDeTeste(
      latitude: _praca.latitude,
      longitude: _praca.longitude,
    ));

    expect(avisos, isEmpty);
  });

  test('favorita sem localização é ignorada', () async {
    await comFavoritas([_favorita(latitude: null, longitude: null)]);

    await criar().avaliar(posicaoDeTeste(
      latitude: _praca.latitude,
      longitude: _praca.longitude,
    ));

    expect(avisos, isEmpty);
  });

  test('avisa uma vez por dia, mesmo passando perto de novo', () async {
    await comFavoritas([_favorita()]);
    final aviso = criar();
    final emCima = posicaoDeTeste(latitude: _praca.latitude, longitude: _praca.longitude);

    await aviso.avaliar(emCima);
    await aviso.avaliar(emCima);
    agora = agora.add(const Duration(hours: 6));
    await aviso.avaliar(emCima);

    expect(avisos, hasLength(1));
  });

  test('no dia seguinte volta a avisar', () async {
    await comFavoritas([_favorita()]);
    final aviso = criar();
    final emCima = posicaoDeTeste(latitude: _praca.latitude, longitude: _praca.longitude);

    await aviso.avaliar(emCima);
    agora = agora.add(const Duration(days: 1));
    await aviso.avaliar(emCima);

    expect(avisos, hasLength(2));
  });

  test('entre duas favoritas perto, avisa a mais próxima', () async {
    await comFavoritas([
      _favorita(id: 5, nome: 'Mais longe', latitude: _praca.latitude + 0.006),
      _favorita(id: 6, nome: 'Mais perto', latitude: _praca.latitude + 0.001),
    ]);

    await criar().avaliar(posicaoDeTeste(
      latitude: _praca.latitude,
      longitude: _praca.longitude,
    ));

    expect(avisos.single, contains('Mais perto'));
  });

  test('o dia avisado fica guardado no aparelho', () async {
    await comFavoritas([_favorita()]);

    await criar().avaliar(posicaoDeTeste(
      latitude: _praca.latitude,
      longitude: _praca.longitude,
    ));

    expect(await AvisoProximidadeStorage.ultimoDia(), '2026-10-13');
    expect(await AvisoProximidadeStorage.ultimaLoja(), 5);
  });
}
