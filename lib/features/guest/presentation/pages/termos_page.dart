import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

class TermosPage extends StatelessWidget {
  const TermosPage({super.key});

  final String _termosMarkdown = '''
# Termos de Uso e Política de Privacidade – MapFood

**Última atualização:** Junho de 2026

Bem-vindo(a) ao **MapFood**! Ao acessar e utilizar nosso aplicativo (seja como Consumidor ou Comerciante), você concorda expressamente com os presentes Termos de Uso e Política de Privacidade. Caso não concorde com alguma das regras aqui estabelecidas, pedimos que não utilize o aplicativo.

---

## PARTE 1: TERMOS DE USO

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

**4. Moderação, Avaliações e Denúncias**
Os consumidores podem avaliar e deixar comentários sobre os comércios. O MapFood repudia qualquer forma de discurso de ódio, ofensas ou informações falsas.
Em caso de violação destas regras ou recebimento de denúncias constantes, a conta infratora (seja ela de consumidor ou comerciante) passará por uma análise. O MapFood enviará um **aviso prévio** informando sobre a infração, permitindo a adequação. A exclusão ou suspensão da conta só ocorrerá caso o comportamento inadequado persista, exceto em casos de crimes previstos em lei, onde o bloqueio poderá ser imediato.

---

## PARTE 2: POLÍTICA DE PRIVACIDADE E TRATAMENTO DE DADOS (LGPD)

O MapFood leva sua privacidade a sério e trata seus dados em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018).

**1. Dados Coletados e Finalidade**
Para o funcionamento adequado da plataforma, coletamos os seguintes dados:
* **Nome, E-mail e Telefone:** Utilizados para a criação da conta, login, contato em caso de suporte e exibição no perfil.
* **CPF:** Solicitado estritamente como chave de identificação única do usuário no sistema e como medida de segurança e **prevenção contra fraudes** (como a criação de múltiplas contas falsas para manipular avaliações de lojas).

**2. Uso de Geolocalização (GPS)**
A base do MapFood é a localização. Coletamos seus dados de GPS sob as seguintes regras rígidas:
* **Para Consumidores:** A localização só é rastreada **em primeiro plano** (quando o aplicativo está aberto e em uso). O aplicativo atualiza sua posição conforme você se move para recalcular e exibir os comerciantes mais próximos em tempo real.
* **Para Comerciantes ("Em Ronda"):** Enquanto o interruptor de "Loja Aberta" estiver ativado e o aplicativo estiver aberto, sua posição é atualizada conforme você se movimenta, para que os consumidores encontrem sua loja no mapa. **Garantia de Privacidade:** Não armazenamos histórico de trajeto — apenas a posição mais recente da loja é mantida. Ao alterar o status para "Fechado", a loja deixa de ser exibida no mapa e sua posição para de ser atualizada.

**3. Compartilhamento de Dados**
O MapFood **não vende, não aluga e não compartilha** seus dados pessoais com terceiros para fins publicitários. Os dados do Comerciante (Nome da Loja, Foto, Avaliações e Localização Ativa) são públicos dentro da plataforma para que os consumidores possam encontrá-lo. Dados sensíveis, como CPF e E-mail de Consumidores, são mantidos em sigilo no nosso banco de dados.

**4. Seus Direitos**
A qualquer momento, você pode solicitar através das configurações do aplicativo:
* A visualização dos dados que temos sobre você.
* A alteração ou correção de dados incorretos.
* A exclusão total e definitiva da sua conta e de todos os seus dados do nosso banco de dados.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.black,
        surfaceTintColor: ColorsPalette.whiteBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Termos e Privacidade",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            PhosphorIconsRegular.caretLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
          ),
        ),
      ),

      body: SafeArea(
        child: Markdown(
          padding: EdgeInsets.all(AppSpacing.lg),
          data: _termosMarkdown,
          physics: const BouncingScrollPhysics(),
          styleSheet: MarkdownStyleSheet(
            h1: AppText.titulo(
              context,
            ).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
            h2: AppText.subtitulo(context).copyWith(
              fontSize: 18,
              color: ColorsPalette.redComponents,
              fontWeight: FontWeight.bold,
            ),
            p: AppText.corpo(
              context,
            ).copyWith(color: ColorsPalette.greyText, height: 1.5),
            strong: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorsPalette.black,
            ),
            listBullet: const TextStyle(color: ColorsPalette.redComponents),
          ),
        ),
      ),
    );
  }
}
