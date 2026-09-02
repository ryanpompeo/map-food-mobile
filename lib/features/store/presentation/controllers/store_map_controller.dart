import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StoreMapController {
  MapController? _map;

  final ValueNotifier<bool> rotacaoTravada = ValueNotifier(false);

  final ValueNotifier<double> zoom = ValueNotifier(14.0);

  void attach(MapController controller) => _map = controller;
  void detach() => _map = null;

  void alternarTravaDeRotacao() {
    rotacaoTravada.value = !rotacaoTravada.value;
    if (rotacaoTravada.value) _map?.rotate(0);
  }

  void dispose() {
    rotacaoTravada.dispose();
    zoom.dispose();
  }

  bool get isAttached => _map != null;

  double get zoomAtual => _map?.camera.zoom ?? zoom.value;

  static const double zoomMinimo = 3.0;
  static const double zoomMaximo = 18.0;

  static const double passoZoom = 1.0;

  int get nivelZoom => (zoom.value - zoomMinimo).round() + 1;
  int get totalNiveisZoom => (zoomMaximo - zoomMinimo).round() + 1;

  void ampliar() => _aplicarZoom(passoZoom);
  void reduzir() => _aplicarZoom(-passoZoom);

  void _aplicarZoom(double delta) {
    final map = _map;
    if (map == null) return;
    final camera = map.camera;
    final destino = (camera.zoom + delta).clamp(zoomMinimo, zoomMaximo);
    if (destino == camera.zoom) return;
    map.move(camera.center, destino);
  }

  void focarEm(
    LatLng alvo, {
    required double alturaVisivel,
    double biasVertical = 0.3,
    double? zoom,
  }) {
    final map = _map;
    if (map == null) return;

    final zoomAlvo = zoom ?? math.max(map.camera.zoom, 15.5);

    final deslocamentoPx = alturaVisivel * (0.5 - biasVertical);

    final metrosPorPixel = 156543.03392 *
        math.cos(alvo.latitude * math.pi / 180) /
        math.pow(2, zoomAlvo);
    final deslocamentoMetros = deslocamentoPx * metrosPorPixel;

    final centro = LatLng(
      alvo.latitude - (deslocamentoMetros / 111320.0),
      alvo.longitude,
    );

    map.move(centro, zoomAlvo);
  }

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
