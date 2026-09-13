import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:map_food/features/store/data/loja_fora_de_ronda_exception.dart';

typedef Transmissor = Future<void> Function(Position posicao);

class RondaUplink {
  RondaUplink({
    required Transmissor transmitir,
    required List<Duration> esperas,
    required void Function(Position posicao) aoEnviar,
    required void Function(int falhasSeguidas) aoFalhar,
    required void Function(LojaForaDeRondaException recusa) aoSerRecusado,
  })  : _transmitir = transmitir,
        _esperas = esperas,
        _aoEnviar = aoEnviar,
        _aoFalhar = aoFalhar,
        _aoSerRecusado = aoSerRecusado;

  final Transmissor _transmitir;
  final List<Duration> _esperas;
  final void Function(Position posicao) _aoEnviar;
  final void Function(int falhasSeguidas) _aoFalhar;
  final void Function(LojaForaDeRondaException recusa) _aoSerRecusado;

  Position? _pendente;
  bool _emVoo = false;
  bool _encerrado = false;
  int _falhasSeguidas = 0;
  Timer? _novaTentativa;

  bool get ocioso => !_emVoo && _pendente == null && _novaTentativa == null;

  void enviar(Position posicao) {
    if (_encerrado) return;
    _pendente = posicao;
    if (_emVoo || _novaTentativa != null) return;
    unawaited(_despachar());
  }

  void encerrar() {
    _encerrado = true;
    _pendente = null;
    _novaTentativa?.cancel();
    _novaTentativa = null;
  }

  Future<void> _despachar() async {
    final posicao = _pendente;
    if (posicao == null || _encerrado) return;
    _pendente = null;
    _emVoo = true;
    final seguir = await _tentar(posicao);
    _emVoo = false;
    if (seguir) unawaited(_despachar());
  }

  Future<bool> _tentar(Position posicao) async {
    try {
      await _transmitir(posicao);
      _falhasSeguidas = 0;
      if (!_encerrado) _aoEnviar(posicao);
      return !_encerrado;
    } on LojaForaDeRondaException catch (recusa) {
      encerrar();
      _aoSerRecusado(recusa);
      return false;
    } catch (_) {
      _pendente ??= posicao;
      _agendarNovaTentativa();
      return false;
    }
  }

  void _agendarNovaTentativa() {
    if (_encerrado) return;
    _falhasSeguidas++;
    _aoFalhar(_falhasSeguidas);
    final espera = _esperas[math.min(_falhasSeguidas - 1, _esperas.length - 1)];
    _novaTentativa = Timer(espera, () {
      _novaTentativa = null;
      unawaited(_despachar());
    });
  }
}
