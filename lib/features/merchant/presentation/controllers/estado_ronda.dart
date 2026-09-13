import 'package:map_food/features/store/data/loja_fora_de_ronda_exception.dart';

enum FaseRonda { parada, iniciando, ativa, gpsDesligado, semPermissao, recusada }

class EstadoRonda {
  const EstadoRonda({
    this.fase = FaseRonda.parada,
    this.ultimoEnvioEm,
    this.latitude,
    this.longitude,
    this.precisaoMetros,
    this.precisaoBaixa = false,
    this.falhasSeguidas = 0,
    this.recusa,
  });

  static const EstadoRonda parada = EstadoRonda();

  final FaseRonda fase;
  final DateTime? ultimoEnvioEm;
  final double? latitude;
  final double? longitude;
  final double? precisaoMetros;
  final bool precisaoBaixa;
  final int falhasSeguidas;
  final LojaForaDeRondaException? recusa;

  bool get transmitindo => fase == FaseRonda.ativa;

  EstadoRonda naFase(FaseRonda nova) => _copiar(fase: nova);

  EstadoRonda comEnvio({
    required DateTime em,
    required double latitude,
    required double longitude,
    required double precisaoMetros,
    required bool precisaoBaixa,
  }) =>
      EstadoRonda(
        fase: fase,
        ultimoEnvioEm: em,
        latitude: latitude,
        longitude: longitude,
        precisaoMetros: precisaoMetros,
        precisaoBaixa: precisaoBaixa,
      );

  EstadoRonda comFalhas(int falhas) => _copiar(falhasSeguidas: falhas);

  EstadoRonda _copiar({FaseRonda? fase, int? falhasSeguidas}) => EstadoRonda(
        fase: fase ?? this.fase,
        ultimoEnvioEm: ultimoEnvioEm,
        latitude: latitude,
        longitude: longitude,
        precisaoMetros: precisaoMetros,
        precisaoBaixa: precisaoBaixa,
        falhasSeguidas: falhasSeguidas ?? this.falhasSeguidas,
        recusa: recusa,
      );
}
