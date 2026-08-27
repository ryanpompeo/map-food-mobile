import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Permite que a tela dona do mapa comande a câmera sem conhecer o
/// `MapController` do flutter_map — quem monta o `StoreMapView` cria um
/// destes, passa adiante e chama [focarEm] / [centralizarNoUsuario].
///
/// Existe por causa da home: lá os controles de câmera são desenhados **fora**
/// do mapa (para ficarem ancorados acima da bottom bar flutuante), e precisam
/// de um jeito de falar com ele.
class StoreMapController {
  MapController? _map;

  /// Trava de rotação do mapa. Fica aqui (e não só dentro do `StoreMapView`)
  /// porque na home o botão que a alterna vive fora do mapa.
  final ValueNotifier<bool> rotacaoTravada = ValueNotifier(false);

  /// Zoom da câmera, realimentado pelo [StoreMapView] a cada movimento do
  /// mapa. `ValueNotifier` e não um getter simples porque os botões de
  /// ampliar/reduzir precisam se apagar ao encostar no limite — e ler isso
  /// via `setState` reconstruiria o mapa a cada quadro de arrasto e de pinça.
  final ValueNotifier<double> zoom = ValueNotifier(14.0);

  /// Chamado pelo [StoreMapView] ao montar/desmontar.
  void attach(MapController controller) => _map = controller;
  void detach() => _map = null;

  void alternarTravaDeRotacao() {
    rotacaoTravada.value = !rotacaoTravada.value;
    // Travar "torto" não faz sentido: ao travar, volta o norte para cima.
    if (rotacaoTravada.value) _map?.rotate(0);
  }

  void dispose() {
    rotacaoTravada.dispose();
    zoom.dispose();
  }

  bool get isAttached => _map != null;

  double get zoomAtual => _map?.camera.zoom ?? zoom.value;

  /// Limites de zoom do app. Os mesmos valores alimentam o `MapOptions` do
  /// [StoreMapView], para que os botões de ampliar/reduzir e o gesto de pinça
  /// parem no mesmo lugar — botão que continua clicável sem fazer nada é
  /// exatamente o que confunde quem navega por leitor de tela.
  static const double zoomMinimo = 3.0;
  static const double zoomMaximo = 18.0;

  /// Um nível por toque: é o passo dos apps de mapa, e cada toque dobra (ou
  /// divide por dois) a escala — grande o bastante pra ser perceptível sem
  /// exigir uma sequência longa de toques.
  static const double passoZoom = 1.0;

  /// Nível anunciado ao leitor de tela: "3 de 15" é legível, "14.7" não.
  int get nivelZoom => (zoom.value - zoomMinimo).round() + 1;
  int get totalNiveisZoom => (zoomMaximo - zoomMinimo).round() + 1;

  /// Alternativa por toque ao gesto de pinça, que exige dois dedos e um
  /// movimento preciso — impossível com uma mão só, com mobilidade reduzida
  /// ou navegando por leitor de tela.
  void ampliar() => _aplicarZoom(passoZoom);
  void reduzir() => _aplicarZoom(-passoZoom);

  void _aplicarZoom(double delta) {
    final map = _map;
    if (map == null) return;
    final camera = map.camera;
    final destino = (camera.zoom + delta).clamp(zoomMinimo, zoomMaximo);
    if (destino == camera.zoom) return;
    // Mantém o centro: o zoom por botão não pode arrastar o mapa junto, senão
    // a pessoa perde a referência do que estava olhando.
    map.move(camera.center, destino);
  }

  /// Enquadra [alvo] deixando-o a [biasVertical] da altura visível, medida do
  /// topo (0.5 = centro da tela, 0.3 = um terço abaixo do topo).
  ///
  /// Serve para enquadrar um ponto fora do centro geométrico quando algo
  /// flutua sobre o mapa. Em vez de mexer na projeção interna do mapa, o
  /// deslocamento é convertido de pixels para graus de latitude pela
  /// resolução do zoom atual — a mesma conta que o Web Mercator usa.
  void focarEm(
    LatLng alvo, {
    required double alturaVisivel,
    double biasVertical = 0.3,
    double? zoom,
  }) {
    final map = _map;
    if (map == null) return;

    final zoomAlvo = zoom ?? math.max(map.camera.zoom, 15.5);

    // Quantos pixels o alvo precisa subir em relação ao centro da tela.
    final deslocamentoPx = alturaVisivel * (0.5 - biasVertical);

    // Resolução do Web Mercator no paralelo atual: metros por pixel.
    final metrosPorPixel = 156543.03392 *
        math.cos(alvo.latitude * math.pi / 180) /
        math.pow(2, zoomAlvo);
    final deslocamentoMetros = deslocamentoPx * metrosPorPixel;

    // Centro ao sul do alvo → alvo sobe na tela. 111320 m ≈ 1 grau de latitude.
    final centro = LatLng(
      alvo.latitude - (deslocamentoMetros / 111320.0),
      alvo.longitude,
    );

    map.move(centro, zoomAlvo);
  }

  /// Centraliza na posição do usuário mantendo o zoom atual — ou subindo para
  /// um zoom de "rua" se o mapa estiver muito afastado.
  void centralizarNoUsuario(
    LatLng posicao, {
    required double alturaVisivel,
    double biasVertical = 0.5,
  }) {
    final map = _map;
    if (map == null) return;
    final zoom = map.camera.zoom < 15.0 ? 16.0 : map.camera.zoom;
    focarEm(posicao, alturaVisivel: alturaVisivel, biasVertical: biasVertical, zoom: zoom);
  }
}
