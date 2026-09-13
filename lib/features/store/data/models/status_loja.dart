enum StatusLoja {
  ativa('ATIVA'),
  inativa('INATIVA'),
  suspensa('SUSPENSA'),
  desconhecido('');

  const StatusLoja(this.valor);

  final String valor;

  static StatusLoja de(String? valor) {
    for (final status in values) {
      if (status != desconhecido && status.valor == valor) return status;
    }
    return desconhecido;
  }
}
