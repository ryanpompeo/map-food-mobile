import 'package:flutter/material.dart';

import 'package:map_food/features/guest/presentation/pages/documento_legal_page.dart';

const String _politicaMarkdown = '''
# Política de Privacidade – MapFood

**Última atualização:** 27 de outubro de 2026

O MapFood leva sua privacidade a sério e trata seus dados em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018). Para os fins da LGPD, o MapFood atua como **controlador** dos dados pessoais tratados por meio do aplicativo. As regras de uso do serviço estão nos **Termos de Uso**, documento separado e disponível na mesma tela em que você encontrou esta política.

---

**1. Dados Coletados e Finalidade**
Para o funcionamento adequado da plataforma, coletamos os seguintes dados:
* **Consumidor:** nome, e-mail, senha (armazenada de forma criptografada), CPF, celular e, opcionalmente, foto de perfil.
* **Comerciante:** nome, e-mail, senha (armazenada de forma criptografada), CPF, celular, telefone, CNPJ e, opcionalmente, foto de perfil.
* **Loja:** nome, descrição, endereço, cidade, estado, CEP, categorias e imagens (foto de capa e galeria) cadastradas pelo próprio comerciante.
* **Conteúdo gerado por você:** avaliações (nota e comentário), denúncias registradas e mensagens enviadas pelo formulário de contato.
* **CPF:** solicitado estritamente como chave de identificação única do usuário e como medida de **prevenção contra fraudes** (por exemplo, a criação de múltiplas contas falsas para manipular avaliações de lojas).

**2. Base Legal do Tratamento**
Tratamos seus dados com base na execução do contrato firmado ao criar sua conta (art. 7º, V), no consentimento fornecido em formulários específicos, como o de contato (art. 7º, I), no cumprimento de obrigação legal (art. 7º, II) e no legítimo interesse do MapFood em manter a plataforma segura e funcional (art. 7º, IX).

**3. Confirmação de E-mail**
Enviamos um código de 6 dígitos para o e-mail do seu cadastro, por meio de um serviço de envio de e-mails, para confirmar que o endereço é realmente seu. Guardamos o código apenas enquanto ele é válido, junto com a data da confirmação. Há limite de envios por dia e espera entre uma tentativa e outra, para evitar que seu e-mail seja usado para incomodar você. O e-mail confirmado também é o canal por onde falamos com você sobre a sua conta.

**4. Uso de Geolocalização (GPS)**
A base do MapFood é a localização. Coletamos seus dados de GPS sob as seguintes regras rígidas:
* **Para Consumidores:** a localização só é lida **em primeiro plano** (quando o aplicativo está aberto e em uso). O aplicativo atualiza sua posição conforme você se move para recalcular e exibir os comerciantes mais próximos. Sua posição é usada **apenas no seu aparelho**, para desenhar o mapa, calcular distâncias e traçar rotas — ela não é enviada nem armazenada nos nossos servidores.
* **Para Comerciantes (loja aberta):** ao abrir a loja, o comerciante escolhe entre ficar **parado** em um ponto ou seguir **em movimento**. Em movimento, a posição é atualizada conforme ele se desloca — inclusive com a tela bloqueada ou o aplicativo em segundo plano —, para que os consumidores encontrem a loja no mapa. Nesse período, o Android mostra a notificação "MapFood — loja aberta" (se as notificações estiverem permitidas) e o iPhone mostra o indicador azul de localização. Mesmo parado, o aplicativo envia um sinal de poucos em poucos minutos; se a loja ficar 15 minutos sem sinal, ela é fechada automaticamente. **Garantia de Privacidade:** não armazenamos histórico de trajeto — apenas a posição mais recente da loja e o horário desse último sinal são mantidos. Ao fechar a loja, ela deixa de ser exibida no mapa e a posição para de ser atualizada.

**5. Notificações no seu Aparelho**
As notificações são opcionais e dependem da sua permissão no aparelho. Hoje usamos três:
* **Loja aberta (comerciante):** notificação fixa, exigida pelo Android, que mostra que a loja está no ar e mantém o envio de posição funcionando com a tela bloqueada.
* **Loja fechando ou fechada (comerciante):** avisa quando o prazo escolhido na abertura está perto do fim ou quando a loja fechou sozinha.
* **Favorita por perto (consumidor):** se uma loja que você favoritou estiver aberta a menos de 1 km, o aplicativo avisa — **no máximo uma vez por dia**, e só enquanto o aplicativo está aberto. A lista das suas favoritas vem do servidor, mas a **conta da distância é feita no seu aparelho**: sua posição não é enviada para isso.
Você pode desligar as notificações do MapFood a qualquer momento nos ajustes do aparelho. Desligá-las não bloqueia nenhuma outra função, mas o comerciante perde o aviso de fechamento.

**6. O que é Público e o que é Restrito**
O MapFood **não vende, não aluga e não compartilha** seus dados pessoais com terceiros para fins publicitários.
* **Visível para outros usuários:** o nome da loja, sua descrição, fotos, categorias, avaliações recebidas e a localização enquanto a loja estiver aberta. Nas avaliações, aparecem o **nome e a foto de perfil** de quem avaliou.
* **Não exibido em nenhuma tela do aplicativo:** CPF, CNPJ, senha, e-mail e telefone.
* **Denúncias:** em nenhuma tela do aplicativo o comerciante denunciado ou outro usuário vê quem denunciou — ele recebe apenas o motivo e a descrição. A identidade de quem denuncia fica registrada para a análise da moderação.
* Seguimos revisando nossos controles de acesso para que essa separação valha também nas interfaces técnicas da plataforma, e não apenas nas telas.

**7. Uso de Inteligência Artificial**
Para gerar o resumo das avaliações de um comércio e para responder no assistente de dúvidas, enviamos o **texto dos comentários e das perguntas** a um provedor de modelos de linguagem contratado, cujos servidores ficam **fora do Brasil**. Não enviamos junto seu nome, e-mail, CPF ou localização. Esse envio caracteriza transferência internacional de dados (art. 33 da LGPD) e ocorre para a execução do serviço. Recomendamos não incluir dados pessoais no texto livre de avaliações e perguntas.

**8. Métricas de Acesso**
Registramos que uma loja foi visitada — no máximo uma vez por visitante por dia — para compor o painel de estatísticas do comerciante. Para visitantes não identificados, esse registro é derivado do endereço de IP. O comerciante enxerga **apenas números totais**, nunca quem visitou.

**9. Armazenamento no seu Aparelho**
Guardamos no próprio aparelho, e não em nossos servidores: o token que mantém você conectado, seus dados básicos de sessão (nome, tipo de conta e se o e-mail está confirmado), suas preferências (como o tema claro/escuro), o histórico de buscas recentes, o prazo de fechamento da loja aberta e a data do último aviso de favorita por perto. Esses dados ficam fora do backup automático do Android, então não são copiados para a nuvem nem transferidos para um aparelho novo. Sair da conta apaga esses dados.

**10. Segurança**
Adotamos medidas técnicas e organizacionais para proteger seus dados contra acesso não autorizado, perda, alteração ou vazamento, incluindo criptografia de senhas e controle de acesso por perfil (consumidor, comerciante e administrador). Nenhum sistema é absolutamente seguro; caso identifique qualquer incidente, entre em contato imediatamente pelo canal da seção 14.

**11. Retenção e Exclusão**
Mantemos seus dados enquanto sua conta estiver ativa ou pelo tempo necessário para cumprir finalidades legais, contratuais ou regulatórias. Ao solicitar a exclusão da conta, seus dados cadastrais são removidos ou anonimizados, exceto quando a lei exigir sua conservação por prazo determinado.

**12. Seus Direitos**
A qualquer momento, você pode solicitar:
* A visualização dos dados que temos sobre você.
* A alteração ou correção de dados incorretos — a maior parte pode ser ajustada direto na tela de Perfil.
* A exclusão total e definitiva da sua conta e dos seus dados.

**13. Uso por Menores de Idade**
O MapFood não é direcionado a menores de 18 anos, e o cadastro requer CPF próprio, pressupondo capacidade civil. Caso identifiquemos uma conta criada por menor sem a devida representação legal, ela poderá ser suspensa até a regularização.

**14. Alterações e Contato**
Podemos atualizar este documento periodicamente para refletir mudanças na plataforma ou na legislação. A data no topo indica a versão mais recente, e alterações relevantes serão comunicadas antes de entrarem em vigor.
Para dúvidas ou para exercer seus direitos como titular, escreva para **contato.mapfood@gmail.com** ou use o formulário de contato da plataforma.
''';

class PoliticaPrivacidadePage extends StatelessWidget {
  const PoliticaPrivacidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DocumentoLegalPage(
      titulo: 'Política de Privacidade',
      markdown: _politicaMarkdown,
    );
  }
}
