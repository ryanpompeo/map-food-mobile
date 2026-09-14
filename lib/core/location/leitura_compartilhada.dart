import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/fonte_posicao.dart';
import 'package:map_food/core/location/perfil_localizacao.dart';

class LeituraCompartilhada {
  LeituraCompartilhada(this._fonte, this._esperas);

  final FontePosicao _fonte;
  final List<Duration> _esperas;
  final Map<PerfilLocalizacao, _Canal> _canais = {};
  StreamSubscription<Position>? _assinatura;
  PerfilLocalizacao? _perfilAtual;
  Timer? _religamento;
  int _tentativa = 0;

  Stream<Position> streamDe(PerfilLocalizacao perfil) => _canalDe(perfil).stream;

  void reiniciar(PerfilLocalizacao perfil) {
    if (_perfilAtual == perfil) _assinar(perfil);
  }

  void descartar() => _parar();

  _Canal _canalDe(PerfilLocalizacao perfil) =>
      _canais.putIfAbsent(perfil, () => _Canal(perfil, _reavaliar));

  void _reavaliar() {
    final desejado = _perfilMaisExigente();
    if (desejado == _perfilAtual) return;
    _parar();
    if (desejado != null) _assinar(desejado);
  }

  PerfilLocalizacao? _perfilMaisExigente() {
    for (final perfil in perfisPorExigencia) {
      if (_canais[perfil]?.ativo ?? false) return perfil;
    }
    return null;
  }

  void _assinar(PerfilLocalizacao perfil) {
    _cancelarLeitura();
    _perfilAtual = perfil;
    _assinatura = _fonte.posicoes(configuracaoPara(perfil, defaultTargetPlatform)).listen(
          _distribuir,
          onError: _distribuirErro,
          onDone: _aoTerminar,
        );
  }

  void _distribuir(Position posicao) {
    _tentativa = 0;
    for (final canal in _canais.values) {
      canal.entregar(posicao);
    }
  }

  void _distribuirErro(Object erro, StackTrace pilha) {
    for (final canal in _canais.values) {
      canal.falhar(erro, pilha);
    }
  }

  void _aoTerminar() {
    _assinatura = null;
    final perfil = _perfilAtual;
    if (perfil == null) return;
    final espera = _esperas[math.min(_tentativa, _esperas.length - 1)];
    _tentativa++;
    _religamento = Timer(espera, () => _assinar(perfil));
  }

  void _cancelarLeitura() {
    _religamento?.cancel();
    _religamento = null;
    _assinatura?.cancel();
    _assinatura = null;
  }

  void _parar() {
    _cancelarLeitura();
    _perfilAtual = null;
    _tentativa = 0;
  }
}

class _Canal {
  _Canal(this._perfil, VoidCallback aoMudar) {
    _saida = StreamController<Position>.broadcast(
      onListen: aoMudar,
      onCancel: () {
        _ultimaEntregue = null;
        aoMudar();
      },
    );
  }

  final PerfilLocalizacao _perfil;
  late final StreamController<Position> _saida;
  Position? _ultimaEntregue;

  bool get ativo => _saida.hasListener;

  Stream<Position> get stream => _saida.stream;

  void entregar(Position posicao) {
    if (!ativo || !_andouOSuficiente(posicao)) return;
    _ultimaEntregue = posicao;
    _saida.add(posicao);
  }

  void falhar(Object erro, StackTrace pilha) {
    if (ativo) _saida.addError(erro, pilha);
  }

  bool _andouOSuficiente(Position posicao) {
    final anterior = _ultimaEntregue;
    if (anterior == null) return true;
    final metros = Geolocator.distanceBetween(
      anterior.latitude,
      anterior.longitude,
      posicao.latitude,
      posicao.longitude,
    );
    return metros >= distanciaMinimaDe(_perfil);
  }
}
