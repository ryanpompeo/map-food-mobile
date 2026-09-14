class ConfiguracaoRonda {
  const ConfiguracaoRonda({
    this.precisaoMaximaMetros = 35,
    this.deslocamentoMinimoMetros = 25,
    this.janelaPrecisaoBaixa = const Duration(minutes: 2),
    this.heartbeat = const Duration(minutes: 5),
    this.watchdog = const Duration(minutes: 2),
    this.intervaloDeVerificacao = const Duration(seconds: 30),
    this.esperasDeReenvio = const [
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 16),
      Duration(seconds: 30),
    ],
    this.falhasAteAvisar = 3,
    this.limiteSemSinal = const Duration(minutes: 15),
  });

  final double precisaoMaximaMetros;
  final double deslocamentoMinimoMetros;
  final Duration janelaPrecisaoBaixa;
  final Duration heartbeat;
  final Duration watchdog;
  final Duration intervaloDeVerificacao;
  final List<Duration> esperasDeReenvio;
  final int falhasAteAvisar;
  final Duration limiteSemSinal;
}
