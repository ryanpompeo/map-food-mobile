import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/features/store/data/services/route_service.dart';

typedef CalcularRota = Future<RouteResult?> Function(LatLng origem, LatLng destino);

class EstadoDaRota {
  const EstadoDaRota({
    required this.destino,
    this.pontos,
    this.distanciaMetros,
    this.calculando = false,
    this.lojaIndisponivel = false,
  });

  final LatLng destino;
  final List<LatLng>? pontos;
  final double? distanciaMetros;
  final bool calculando;
  final bool lojaIndisponivel;

  bool get temRota => pontos != null;

  bool get primeiroCalculo => calculando && !temRota;

  EstadoDaRota copiar({LatLng? destino, bool? calculando, bool? lojaIndisponivel}) => EstadoDaRota(
        destino: destino ?? this.destino,
        pontos: pontos,
        distanciaMetros: distanciaMetros,
        calculando: calculando ?? this.calculando,
        lojaIndisponivel: lojaIndisponivel ?? this.lojaIndisponivel,
      );
}

class RotaReativaController {
  RotaReativaController({
    required CalcularRota calcular,
    required LatLng destinoInicial,
    this.intervaloMinimo = const Duration(seconds: 30),
    this.limiarDestinoMetros = 75,
    this.limiarOrigemMetros = 50,
  })  : _calcular = calcular,
        _destino = destinoInicial,
        estado = ValueNotifier(EstadoDaRota(destino: destinoInicial));

  static const Distance _distancia = Distance();

  final ValueNotifier<EstadoDaRota> estado;
  final Duration intervaloMinimo;
  final double limiarDestinoMetros;
  final double limiarOrigemMetros;
  final CalcularRota _calcular;

  LatLng? _origem;
  LatLng _destino;
  LatLng? _origemUsada;
  LatLng? _destinoUsado;
  Timer? _resfriamento;
  bool _emVoo = false;
  bool _descartado = false;

  void atualizarOrigem(LatLng origem) {
    _origem = origem;
    _avaliar();
  }

  void atualizarDestino(LatLng destino) {
    _destino = destino;
    _publicar(estado.value.copiar(destino: destino, lojaIndisponivel: false));
    _avaliar();
  }

  void lojaSaiu() => _publicar(estado.value.copiar(lojaIndisponivel: true));

  void dispose() {
    _descartado = true;
    _resfriamento?.cancel();
    estado.dispose();
  }

  void _avaliar() {
    if (_resfriamento != null || !_podeCalcular || !_precisaRecalcular) return;
    unawaited(_calcularAgora());
  }

  bool get _podeCalcular =>
      !_descartado && !_emVoo && _origem != null && !estado.value.lojaIndisponivel;

  bool get _precisaRecalcular {
    final origemUsada = _origemUsada;
    final destinoUsado = _destinoUsado;
    if (origemUsada == null || destinoUsado == null) return true;
    return _andou(destinoUsado, _destino, limiarDestinoMetros) ||
        _andou(origemUsada, _origem!, limiarOrigemMetros);
  }

  static bool _andou(LatLng de, LatLng para, double limiarMetros) =>
      _distancia.as(LengthUnit.Meter, de, para) >= limiarMetros;

  void _aoFimDoResfriamento() {
    _resfriamento = null;
    _avaliar();
  }

  Future<void> _calcularAgora() async {
    final origem = _origem!;
    final destino = _destino;
    _emVoo = true;
    _resfriamento = Timer(intervaloMinimo, _aoFimDoResfriamento);
    _publicar(estado.value.copiar(calculando: true));
    final resultado = await _calcular(origem, destino);
    _emVoo = false;
    if (_descartado) return;
    _aplicar(resultado, origem, destino);
    _avaliar();
  }

  void _aplicar(RouteResult? resultado, LatLng origem, LatLng destino) {
    if (resultado != null) {
      _origemUsada = origem;
      _destinoUsado = destino;
      _publicar(_comRota(resultado.pontos, resultado.distanciaMetros));
      return;
    }
    if (estado.value.temRota) {
      _publicar(estado.value.copiar(calculando: false));
      return;
    }
    _publicar(_comRota([origem, destino], _distancia.as(LengthUnit.Meter, origem, destino)));
  }

  EstadoDaRota _comRota(List<LatLng> pontos, double distanciaMetros) => EstadoDaRota(
        destino: _destino,
        pontos: pontos,
        distanciaMetros: distanciaMetros,
        lojaIndisponivel: estado.value.lojaIndisponivel,
      );

  void _publicar(EstadoDaRota novo) {
    if (!_descartado) estado.value = novo;
  }
}
