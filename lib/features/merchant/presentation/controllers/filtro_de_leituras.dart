import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:map_food/features/merchant/presentation/controllers/configuracao_ronda.dart';

class FiltroDeLeituras {
  FiltroDeLeituras(this._config);

  final ConfiguracaoRonda _config;

  Position? _ultimaAceita;
  Position? _melhorDaJanela;
  DateTime? _inicioDaJanela;
  bool _precisaoBaixa = false;

  Position? get ultimaAceita => _ultimaAceita;

  bool get precisaoBaixa => _precisaoBaixa;

  Position? avaliar(Position leitura, DateTime agora) {
    if (_imprecisa(leitura)) return _avaliarImprecisa(leitura, agora);
    _fecharJanela();
    if (!_deslocouOSuficiente(leitura)) return null;
    return _aceitar(leitura, precisaoBaixa: false);
  }

  void semear(Position posicao) => _aceitar(posicao, precisaoBaixa: _imprecisa(posicao));

  void reiniciar() {
    _ultimaAceita = null;
    _precisaoBaixa = false;
    _fecharJanela();
  }

  Position? _avaliarImprecisa(Position leitura, DateTime agora) {
    _inicioDaJanela ??= agora;
    final melhor = _melhorDaJanela;
    if (melhor == null || leitura.accuracy < melhor.accuracy) _melhorDaJanela = leitura;
    if (agora.difference(_inicioDaJanela!) < _config.janelaPrecisaoBaixa) return null;
    final escolhida = _melhorDaJanela!;
    _fecharJanela();
    if (!_deslocouOSuficiente(escolhida)) return null;
    return _aceitar(escolhida, precisaoBaixa: true);
  }

  bool _imprecisa(Position leitura) =>
      leitura.accuracy < 0 || leitura.accuracy > _config.precisaoMaximaMetros;

  bool _deslocouOSuficiente(Position leitura) {
    final anterior = _ultimaAceita;
    if (anterior == null) return true;
    final distancia = Geolocator.distanceBetween(
      anterior.latitude,
      anterior.longitude,
      leitura.latitude,
      leitura.longitude,
    );
    return distancia > math.max(_config.deslocamentoMinimoMetros, leitura.accuracy);
  }

  Position _aceitar(Position leitura, {required bool precisaoBaixa}) {
    _ultimaAceita = leitura;
    _precisaoBaixa = precisaoBaixa;
    return leitura;
  }

  void _fecharJanela() {
    _melhorDaJanela = null;
    _inicioDaJanela = null;
  }
}
