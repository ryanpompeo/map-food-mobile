import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:map_food/core/ui/theme/app_icons.dart';

import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class TermosPage extends StatelessWidget {
  const TermosPage({super.key});

  final String _termosMarkdown = '''
# Termos de Uso e Política de Privacidade – MapFood

**Última atualização:** 30 de agosto de 2026

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

O MapFood leva sua privacidade a sério e trata seus dados em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018). Para os fins da LGPD, o MapFood atua como **controlador** dos dados pessoais tratados por meio do aplicativo.

**1. Dados Coletados e Finalidade**
Para o funcionamento adequado da plataforma, coletamos os seguintes dados:
* **Consumidor:** nome, e-mail, senha (armazenada de forma criptografada), CPF, celular e, opcionalmente, foto de perfil.
* **Comerciante:** nome, e-mail, senha (armazenada de forma criptografada), CPF, celular, telefone, CNPJ e, opcionalmente, foto de perfil.
* **Loja:** nome, descrição, endereço, cidade, estado, CEP, categorias e imagens (foto de capa e galeria) cadastradas pelo próprio comerciante.
* **Conteúdo gerado por você:** avaliações (nota e comentário), denúncias registradas e mensagens enviadas pelo formulário de contato.
* **CPF:** solicitado estritamente como chave de identificação única do usuário e como medida de **prevenção contra fraudes** (por exemplo, a criação de múltiplas contas falsas para manipular avaliações de lojas).

**2. Base Legal do Tratamento**
Tratamos seus dados com base na execução do contrato firmado ao criar sua conta (art. 7º, V), no consentimento fornecido em formulários específicos, como o de contato (art. 7º, I), no cumprimento de obrigação legal (art. 7º, II) e no legítimo interesse do MapFood em manter a plataforma segura e funcional (art. 7º, IX).

**3. Uso de Geolocalização (GPS)**
A base do MapFood é a localização. Coletamos seus dados de GPS sob as seguintes regras rígidas:
* **Para Consumidores:** A localização só é rastreada **em primeiro plano** (quando o aplicativo está aberto e em uso). O aplicativo atualiza sua posição conforme você se move para recalcular e exibir os comerciantes mais próximos em tempo real. Sua posição é usada **apenas no seu aparelho** para desenhar o mapa e calcular distâncias — ela não é enviada nem armazenada nos nossos servidores.
* **Para Comerciantes ("Em Ronda"):** Enquanto o interruptor de "Loja Aberta" estiver ativado e o aplicativo estiver aberto, sua posição é atualizada conforme você se movimenta, para que os consumidores encontrem sua loja no mapa. **Garantia de Privacidade:** Não armazenamos histórico de trajeto — apenas a posição mais recente da loja é mantida. Ao alterar o status para "Fechado", a loja deixa de ser exibida no mapa e sua posição para de ser atualizada.

**4. O que é Público e o que é Restrito**
O MapFood **não vende, não aluga e não compartilha** seus dados pessoais com terceiros para fins publicitários.
* **Visível para outros usuários:** o nome da loja, sua descrição, fotos, categorias, avaliações recebidas e a localização enquanto a loja estiver aberta. Nas avaliações, aparecem o **nome e a foto de perfil** de quem avaliou.
* **Não exibido em nenhuma tela do aplicativo:** CPF, CNPJ, senha, e-mail e telefone.
* Seguimos revisando nossos controles de acesso para que essa separação valha também nas interfaces técnicas da plataforma, e não apenas nas telas.
* **Denúncias:** o comerciante denunciado recebe o motivo e a descrição, nunca a identidade de quem denunciou.

**5. Uso de Inteligência Artificial**
Para gerar o resumo das avaliações de um comércio e para responder no assistente de dúvidas, enviamos o **texto dos comentários e das perguntas** a um provedor de modelos de linguagem contratado, cujos servidores ficam **fora do Brasil**. Não enviamos junto seu nome, e-mail, CPF ou localização. Esse envio caracteriza transferência internacional de dados (art. 33 da LGPD) e ocorre para a execução do serviço. Recomendamos não incluir dados pessoais no texto livre de avaliações e perguntas.

**6. Métricas de Acesso**
Registramos que uma loja foi visitada — no máximo uma vez por visitante por dia — para compor o painel de estatísticas do comerciante. Para visitantes não identificados, esse registro é derivado do endereço de IP. O comerciante enxerga **apenas números totais**, nunca quem visitou.

**7. Armazenamento no seu Aparelho**
Guardamos no próprio aparelho, e não em nossos servidores: o token que mantém você conectado, suas preferências (como o tema claro/escuro) e o histórico de buscas recentes. Sair da conta apaga esses dados.

**8. Segurança**
Adotamos medidas técnicas e organizacionais para proteger seus dados contra acesso não autorizado, perda, alteração ou vazamento, incluindo criptografia de senhas e controle de acesso por perfil (consumidor, comerciante e administrador). Nenhum sistema é absolutamente seguro; caso identifique qualquer incidente, entre em contato imediatamente pelo canal da seção 12.

**9. Retenção e Exclusão**
Mantemos seus dados enquanto sua conta estiver ativa ou pelo tempo necessário para cumprir finalidades legais, contratuais ou regulatórias. Ao solicitar a exclusão da conta, seus dados cadastrais são removidos ou anonimizados, exceto quando a lei exigir sua conservação por prazo determinado.

**10. Seus Direitos**
A qualquer momento, você pode solicitar:
* A visualização dos dados que temos sobre você.
* A alteração ou correção de dados incorretos — a maior parte pode ser ajustada direto na tela de Perfil.
* A exclusão total e definitiva da sua conta e dos seus dados.

**11. Uso por Menores de Idade**
O MapFood não é direcionado a menores de 18 anos, e o cadastro requer CPF próprio, pressupondo capacidade civil. Caso identifiquemos uma conta criada por menor sem a devida representação legal, ela poderá ser suspensa até a regularização.

**12. Alterações e Contato**
Podemos atualizar este documento periodicamente para refletir mudanças na plataforma ou na legislação. A data no topo indica a versão mais recente, e alterações relevantes serão comunicadas antes de entrarem em vigor.
Para dúvidas ou para exercer seus direitos como titular, escreva para **contato.mapfood@gmail.com** ou use o formulário de contato da plataforma.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        backgroundColor: context.mapColors.mainBackground,
        foregroundColor: context.mapColors.primaryText,
        surfaceTintColor: context.mapColors.mainBackground,
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
            AppIcons.caretLeft,
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
            p: AppText.corpo(context).copyWith(height: 1.5),
            strong: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.mapColors.primaryText,
            ),
            listBullet: const TextStyle(color: ColorsPalette.redComponents),
          ),
        ),
      ),
    );
  }
}
