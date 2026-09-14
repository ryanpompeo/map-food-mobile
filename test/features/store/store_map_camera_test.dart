import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/controllers/store_map_controller.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

import '../../support/map_test_tiles.dart';

const _usuario = LatLng(-22.9068, -43.1729);
const _usuarioAdiante = LatLng(-22.9168, -43.1829);

StoreDto _lojaEm(LatLng ponto) => StoreDto(
      id: 7,
      nome: 'Carrinho do Zé',
      statusLoja: 'ATIVA',
      categoria: 'Lanches',
      latitude: ponto.latitude,
      longitude: ponto.longitude,
    );

class _Palco extends StatefulWidget {
  const _Palco({
    super.key,
    this.controlador,
    this.posicao,
    this.loja,
    this.controles = false,
  });

  final StoreMapController? controlador;
  final ValueNotifier<LatLng?>? posicao;
  final StoreDto? loja;
  final bool controles;

  @override
  State<_Palco> createState() => _PalcoState();
}

class _PalcoState extends State<_Palco> {
  late StoreDto? _loja = widget.loja;
  List<LatLng>? _rota;

  void moverLoja(LatLng ponto) => setState(() => _loja = _lojaEm(ponto));

  void trocarRota(List<LatLng> rota) => setState(() => _rota = rota);

  @override
  Widget build(BuildContext context) {
    final loja = _loja;
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StoreMapView(
          stores: [?loja],
          focusedStore: loja,
          controller: widget.controlador,
          userPosition: widget.posicao,
          initialLatitude: widget.posicao?.value?.latitude,
          initialLongitude: widget.posicao?.value?.longitude,
          routePoints: _rota,
          showFloatingControls: widget.controles,
        ),
      ),
    );
  }
}

LatLng _centroDoMapa(WidgetTester tester) =>
    MapCamera.of(tester.element(find.byType(MarkerLayer).first)).center;

Matcher _perto(LatLng alvo) => predicate<LatLng>(
      (c) => (c.latitude - alvo.latitude).abs() < 0.0005 && (c.longitude - alvo.longitude).abs() < 0.0005,
      'perto de $alvo',
    );

Future<void> _arrastar(WidgetTester tester) async {
  await tester.drag(find.byType(FlutterMap), const Offset(160, 40));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(usarTilesOffline);

  group('mapa do consumidor', () {
    late StoreMapController controlador;
    late ValueNotifier<LatLng?> posicao;

    setUp(() {
      controlador = StoreMapController();
      posicao = controlador.posicaoUsuario..value = _usuario;
    });

    tearDown(() => controlador.dispose());

    Future<void> montar(WidgetTester tester, {bool controles = false}) async {
      await tester.pumpWidget(_Palco(controlador: controlador, posicao: posicao, controles: controles));
      await tester.pump();
    }

    testWidgets('começa seguindo a posição do usuário', (tester) async {
      await montar(tester);

      expect(controlador.modo.value, ModoCamera.seguindoUsuario);
    });

    testWidgets('seguindo, a posição nova leva a câmera junto', (tester) async {
      await montar(tester);

      posicao.value = _usuarioAdiante;
      await tester.pump();

      expect(controlador.centro, _perto(_usuarioAdiante));
    });

    testWidgets('arrastar o mapa desliga o seguimento na hora', (tester) async {
      await montar(tester);

      await _arrastar(tester);

      expect(controlador.modo.value, ModoCamera.livre);
    });

    testWidgets('com o seguimento desligado, a posição nova não puxa a câmera', (tester) async {
      await montar(tester);
      await _arrastar(tester);
      final centroDepoisDoArraste = controlador.centro!;

      posicao.value = _usuarioAdiante;
      await tester.pump();

      expect(controlador.centro, _perto(centroDepoisDoArraste));
    });

    testWidgets('zoom pelos botões não desliga o seguimento', (tester) async {
      await montar(tester);

      controlador.ampliar();
      await tester.pump();

      expect(controlador.modo.value, ModoCamera.seguindoUsuario);
    });

    testWidgets('Recentralizar religa o seguimento e volta para o usuário', (tester) async {
      await montar(tester, controles: true);
      await _arrastar(tester);
      expect(controlador.modo.value, ModoCamera.livre);

      await tester.tap(find.byTooltip('Recentralizar'));
      await tester.pump();

      expect(controlador.modo.value, ModoCamera.seguindoUsuario);
      expect(controlador.centro, _perto(_usuario));
    });

    testWidgets('home: o botão da própria tela também religa o seguimento', (tester) async {
      await montar(tester);
      await _arrastar(tester);

      controlador.seguirUsuario(alturaVisivel: 800);
      await tester.pump();

      expect(controlador.modo.value, ModoCamera.seguindoUsuario);
    });
  });

  group('mapa de uma loja', () {
    const lojaNoInicio = _usuario;
    const lojaAdiante = _usuarioAdiante;

    testWidgets('segue a loja focada quando ela se move', (tester) async {
      final palco = GlobalKey<_PalcoState>();
      await tester.pumpWidget(_Palco(key: palco, loja: _lojaEm(lojaNoInicio)));
      await tester.pump();

      palco.currentState!.moverLoja(lojaAdiante);
      await tester.pump();

      expect(_centroDoMapa(tester), _perto(lojaAdiante));
    });

    testWidgets('depois de arrastar, a loja andando não puxa a câmera', (tester) async {
      final palco = GlobalKey<_PalcoState>();
      await tester.pumpWidget(_Palco(key: palco, loja: _lojaEm(lojaNoInicio)));
      await tester.pump();
      await _arrastar(tester);
      final centroDepoisDoArraste = _centroDoMapa(tester);

      palco.currentState!.moverLoja(lojaAdiante);
      await tester.pump();

      expect(_centroDoMapa(tester), _perto(centroDepoisDoArraste));
    });
  });

  group('mapa de rota', () {
    const rotaCurta = [_usuario, LatLng(-22.9100, -43.1760)];
    const rotaNova = [_usuario, LatLng(-22.9500, -43.2200)];

    testWidgets('rota recalculada reenquadra enquanto o usuário não mexeu', (tester) async {
      final palco = GlobalKey<_PalcoState>();
      await tester.pumpWidget(_Palco(key: palco, loja: _lojaEm(rotaCurta.last)));
      await tester.pump();

      palco.currentState!.trocarRota(rotaCurta);
      await tester.pump();
      final centroDaRotaCurta = _centroDoMapa(tester);

      palco.currentState!.trocarRota(rotaNova);
      await tester.pump();

      expect(_centroDoMapa(tester), isNot(_perto(centroDaRotaCurta)));
    });

    testWidgets('rota recalculada não reenquadra se o usuário arrastou', (tester) async {
      final palco = GlobalKey<_PalcoState>();
      await tester.pumpWidget(_Palco(key: palco, loja: _lojaEm(rotaCurta.last)));
      await tester.pump();
      palco.currentState!.trocarRota(rotaCurta);
      await tester.pump();
      await _arrastar(tester);
      final centroDepoisDoArraste = _centroDoMapa(tester);

      palco.currentState!.trocarRota(rotaNova);
      await tester.pump();

      expect(_centroDoMapa(tester), _perto(centroDepoisDoArraste));
    });
  });
}
