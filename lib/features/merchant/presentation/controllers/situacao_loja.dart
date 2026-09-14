enum SituacaoLoja { fechada, suspensa, fixa, iniciando, transmitindo, semSinal }

extension SituacaoLojaX on SituacaoLoja {
  bool get aberta => this != SituacaoLoja.fechada && this != SituacaoLoja.suspensa;
}
