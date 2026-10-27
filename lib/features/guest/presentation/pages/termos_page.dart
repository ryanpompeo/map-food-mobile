import 'package:flutter/material.dart';

import 'package:map_food/features/guest/presentation/pages/documento_legal_page.dart';

const String _termosMarkdown = '''
# Termos de Uso – MapFood

**Última atualização:** 27 de outubro de 2026

Bem-vindo(a) ao **MapFood**! Ao acessar e utilizar nosso aplicativo (seja como Consumidor ou Comerciante), você concorda expressamente com os presentes Termos de Uso. O tratamento dos seus dados é descrito em documento próprio, a **Política de Privacidade**, disponível na mesma tela em que você encontrou estes termos. Caso não concorde com alguma das regras aqui estabelecidas, pedimos que não utilize o aplicativo.

---

**1. Natureza do Serviço**
O MapFood atua única e exclusivamente como um **catálogo virtual (vitrine)** e uma ferramenta de roteamento geográfico. Nosso objetivo é facilitar o encontro entre consumidores e comerciantes de comida de rua.
**Não** realizamos, intermediamos ou processamos transações financeiras dentro do aplicativo. Qualquer pagamento deve ser combinado e realizado fisicamente e de forma direta entre o Consumidor e o Comerciante.

**2. Isenção de Responsabilidade**
O MapFood é uma plataforma de tecnologia e **não atua como fornecedor de alimentos**. Sendo assim:
* Não possuímos qualquer vínculo empregatício, societário ou de representação com os Comerciantes cadastrados.
* Não nos responsabilizamos pela procedência, qualidade, preparo, higiene, segurança ou preço dos alimentos anunciados.
* Qualquer dano à saúde (como intoxicações alimentares) ou prejuízo financeiro decorrente da transação é de responsabilidade única e exclusiva do Comerciante que efetuou a venda.

**3. Custos de Utilização**
Atualmente, o uso do MapFood é **100% gratuito** tanto para Consumidores quanto para Comerciantes. O MapFood reserva-se o direito de, no futuro, implementar funcionalidades pagas ou planos de assinatura para comerciantes, o que será comunicado com aviso prévio, garantindo ao usuário a opção de aderir ou encerrar sua conta.

**4. Confirmação de E-mail**
Depois do cadastro, enviamos um código de 6 dígitos para o e-mail informado. A confirmação serve para garantir que o e-mail é seu de verdade e é exigida para **avaliar** um comércio e para **registrar denúncias**. Sem confirmar, você continua navegando, vendo o mapa e as lojas normalmente.

**5. Posição da Loja Aberta (Comerciante)**
O comerciante escolhe abrir a loja como **parado** em um ponto ou **em movimento**. Enquanto a loja estiver aberta, a posição informada aparece no mapa para os consumidores. É responsabilidade do comerciante manter esse estado fiel à realidade: anunciar-se aberto sem estar atendendo, ou em um local onde não está, prejudica quem se desloca até lá e pode levar à moderação da conta.
Para evitar lojas "abertas" esquecidas, a loja fecha sozinha no prazo escolhido na abertura e também quando o aplicativo fica 15 minutos sem conseguir enviar sinal.

**6. Moderação, Avaliações e Denúncias**
Os consumidores podem avaliar e deixar comentários sobre os comércios. O MapFood repudia qualquer forma de discurso de ódio, ofensas ou informações falsas.
Em caso de violação destas regras ou recebimento de denúncias constantes, a conta infratora (seja ela de consumidor ou comerciante) passará por uma análise. O MapFood enviará um **aviso prévio** informando sobre a infração, permitindo a adequação. A exclusão ou suspensão da conta só ocorrerá caso o comportamento inadequado persista, exceto em casos de crimes previstos em lei, onde o bloqueio poderá ser imediato.

**7. Alterações e Contato**
Podemos atualizar este documento periodicamente para refletir mudanças na plataforma ou na legislação. A data no topo indica a versão mais recente, e alterações relevantes serão comunicadas antes de entrarem em vigor.
Para dúvidas, escreva para **contato.mapfood@gmail.com** ou use o formulário de contato da plataforma.
''';

class TermosPage extends StatelessWidget {
  const TermosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DocumentoLegalPage(
      titulo: 'Termos de Uso',
      markdown: _termosMarkdown,
    );
  }
}
