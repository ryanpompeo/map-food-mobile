# 🎯 VISÃO GERAL

O MapFood é um aplicativo de celular que mostra comércios de comida em um mapa.
O usuário comum encontra lojas perto dele, avalia e salva favoritos.

O dono de uma loja usa o mesmo aplicativo para cadastrar seu comércio.
Ele também acompanha quantas pessoas viram a loja dele.

O aplicativo é escrito em Flutter e conversa com um servidor pela internet.
Este manual guarda todos os comentários que foram apagados do código.

---

# 📖 GLOSSÁRIO

Esta lista explica as palavras técnicas que aparecem nos comentários originais.
Cada palavra tem uma explicação de uma frase.

- **API**: o servidor na internet que guarda e devolve os dados do aplicativo.
- **AppException**: o tipo de erro que o aplicativo sabe tratar e mostrar na tela.
- **Assets**: arquivos de imagem e fonte guardados dentro do próprio aplicativo.
- **Backend**: o programa que roda no servidor, do outro lado da internet.
- **Bottom sheet**: painel que sobe de baixo da tela com opções.
- **Build**: o método que desenha um pedaço da tela no Flutter.
- **Cache**: cópia guardada de algo já baixado, para não baixar de novo.
- **Cache de disco**: cópia guardada no armazenamento do celular, que sobrevive ao fechar o app.
- **Cache de memória**: cópia guardada na memória temporária, que some ao fechar o app.
- **Callback**: função que é entregue para outra parte do código executar depois.
- **Cascade (no banco)**: apagar um registro apaga junto tudo que dependia dele.
- **Constructor / construtor**: o comando que cria um objeto novo na memória.
- **Contraste**: a diferença de luminosidade entre a cor do texto e a cor do fundo.
- **Controller**: objeto que guarda o estado de uma tela e avisa quando ele muda.
- **CTA**: o botão principal de ação de uma tela.
- **Dart**: a linguagem de programação usada para escrever este aplicativo.
- **Deep link**: um endereço que abre direto em uma tela específica do aplicativo.
- **devicePixelRatio**: quantos pontos reais de tela existem para cada ponto medido pelo código.
- **Dio**: a biblioteca que faz os pedidos de rede neste aplicativo.
- **DTO**: objeto simples que só carrega dados de um lugar para outro.
- **Dynamic Type**: o ajuste de tamanho de letra que o usuário escolhe no sistema do celular.
- **Elevação**: o quanto um elemento parece estar acima da tela, feito com sombra.
- **Endpoint**: um endereço específico do servidor que responde a um pedido.
- **Estado (state)**: os dados que uma tela guarda e que podem mudar durante o uso.
- **Fade**: o efeito de a imagem aparecer aumentando o brilho aos poucos.
- **Fallback**: o que é usado quando a opção principal não está disponível.
- **FOUC**: o piscar de tela quando o visual certo só é aplicado depois do primeiro desenho.
- **FPS**: quantos desenhos de tela o aplicativo consegue fazer por segundo.
- **Frame**: um desenho completo da tela; o aplicativo faz muitos por segundo.
- **Geocoding**: transformar coordenadas de GPS em nome de rua e bairro.
- **Getter**: um atalho de leitura que devolve um valor calculado na hora.
- **GPS**: o sensor do celular que descobre onde o aparelho está.
- **Guard**: um trecho de código que impede uma ação de acontecer duas vezes ao mesmo tempo.
- **Hero card**: cartão grande com foto ocupando todo o espaço.
- **Hidratar**: carregar dados salvos no disco para dentro da memória.
- **Hook**: ponto onde outro código pode ser encaixado para rodar junto.
- **HTTP 401**: resposta do servidor que significa "você não está autorizado".
- **HTTP 409**: resposta do servidor que significa "isso conflita com algo que já existe".
- **Idempotente**: repetir a mesma ação não muda mais nada depois da primeira vez.
- **IndexedStack**: componente que mantém várias telas montadas e mostra só uma.
- **Interceptor**: código que examina todo pedido de rede antes de ele ir ou voltar.
- **JSON**: formato de texto usado para o servidor mandar dados para o aplicativo.
- **JWT / token**: o crachá digital que prova quem é o usuário em cada pedido ao servidor.
- **Layout**: a organização dos elementos na tela.
- **Leitor de tela**: programa que lê a tela em voz alta para pessoas cegas.
- **Listenable**: objeto que avisa outros quando alguma coisa dentro dele muda.
- **Login wall**: aviso que bloqueia uma ação e pede para o usuário entrar na conta.
- **maxLines**: número máximo de linhas que um texto pode ocupar.
- **MediaQuery**: fonte de informação sobre o tamanho da tela e as opções do sistema.
- **Mixin**: bloco de código pronto que pode ser colado dentro de várias classes.
- **Multipart**: formato de envio usado quando o pedido carrega um arquivo.
- **Nó de semântica**: a descrição invisível que o leitor de tela usa para narrar um elemento.
- **Onboarding**: as telas de boas-vindas mostradas na primeira vez que o app abre.
- **OpenStreetMap / OSM**: o serviço gratuito que fornece as imagens do mapa.
- **OSRM**: o serviço que calcula o caminho entre dois pontos do mapa.
- **Overlay**: camada desenhada por cima de toda a tela.
- **Parse**: ler um texto recebido e transformar em dados que o programa entende.
- **Path**: o caminho de um arquivo ou o pedaço final de um endereço.
- **Placeholder**: conteúdo temporário mostrado enquanto o conteúdo real não chegou.
- **Pop**: fechar a tela atual e voltar para a anterior.
- **PopScope**: componente que intercepta a tentativa de voltar para a tela anterior.
- **Precache**: baixar algo antes de precisar, para a tela abrir já pronta.
- **Provider (de imagem)**: o objeto que sabe de onde buscar uma imagem.
- **Rebuild**: refazer o desenho de um pedaço da tela.
- **RepaintBoundary**: cerca que impede que a repintura de uma área afete as outras.
- **ResizeImage**: reduzir a imagem baixada para o tamanho em que ela aparece.
- **Ripple**: a onda de cor que se espalha do ponto tocado.
- **Rota (navegação)**: uma tela dentro da pilha de telas do aplicativo.
- **Scaffold**: a estrutura básica de uma tela, com topo, corpo e rodapé.
- **Scrim**: véu escuro colocado atrás de um painel para escurecer o fundo.
- **Scroll / scrollable**: rolagem da tela e o componente que permite rolar.
- **Semântica**: as informações que descrevem a tela para tecnologias assistivas.
- **setState**: comando que avisa o Flutter que a tela precisa ser redesenhada.
- **SharedPreferences**: espaço pequeno do celular onde o app salva ajustes simples.
- **Singleton**: objeto que existe uma única vez no aplicativo inteiro.
- **Skeleton**: forma cinza mostrada no lugar do conteúdo que ainda está carregando.
- **Spinner**: círculo girando que indica carregamento.
- **Spring Boot**: a tecnologia usada no servidor deste projeto.
- **Stack (layout)**: componente que empilha elementos um sobre o outro.
- **Stream**: um fluxo de valores que chegam ao longo do tempo.
- **Superfície**: a cor de fundo de um bloco, como um cartão ou um campo.
- **Tap target**: a área que aceita o toque do dedo.
- **Tema claro / tema escuro**: as duas aparências de cor do aplicativo.
- **Tiles**: os quadradinhos de imagem que juntos formam o mapa.
- **Timeout**: tempo máximo de espera antes de desistir de um pedido.
- **Toast**: aviso pequeno que aparece e some sozinho.
- **Token (de design)**: um valor de cor, espaço ou tamanho com nome fixo.
- **TypeError**: erro que acontece quando um dado chega com o tipo errado.
- **ValueNotifier**: caixa que guarda um valor e avisa quem estiver ouvindo quando ele muda.
- **Viewport**: a parte visível da tela.
- **WCAG**: o conjunto de regras internacionais de acessibilidade para telas.
- **Widget**: cada peça visual do Flutter, como um botão ou um texto.
- **XFile**: arquivo escolhido pelo usuário, em formato que funciona em celular e navegador.

---

# 👣 TRILHA DE EXECUÇÃO (Ordem Lógica)

A ordem abaixo segue o caminho que o aplicativo percorre quando é aberto.
Primeiro a partida, depois as peças compartilhadas, depois cada funcionalidade.

---

## 🚀 PARTE 1 — A PARTIDA DO APLICATIVO

### 📂 ARQUIVO: lib/main.dart

- ⚙️ Função: É o primeiro arquivo a rodar; ele prepara o tema, a sessão e abre a primeira tela.
- 💬 Comentários Removidos:

  > "Aguarda a preferência de tema salva ANTES do runApp — sem isso, o primeiro frame nasceria sempre no ThemeMode.system e só trocaria pro tema salvo um frame depois, gerando um flash de tema errado (FOUC)."
  - 💡 Explicação Leiga: A linha lê no disco se o usuário escolheu tema claro ou escuro. Ela espera essa resposta antes de desenhar a tela, para o app não piscar na cor errada.

  > "Hidrata a sessão em memória antes do primeiro frame: a partir daqui, qualquer tela lê papel/id/nome de forma síncrona via SessionStore, sem repetir I/O em SharedPreferences."
  - 💡 Explicação Leiga: A linha carrega os dados do usuário logado para a memória. Depois disso, qualquer tela consegue saber quem está logado na hora, sem esperar.

  > "Sessão salva sempre ganha do onboarding: quem já está logado nunca deve ver a tela de boas-vindas de novo (nem depois de atualizar o app)."
  - 💡 Explicação Leiga: A linha decide qual tela abrir primeiro. Se existe alguém logado, o app pula as telas de boas-vindas.

  > "Mapa único de rotas — usado tanto pelo `routes:` quanto pela montagem da pilha inicial, para as duas nunca divergirem."
  - 💡 Explicação Leiga: A linha cria uma lista com o nome de cada tela do aplicativo. Essa mesma lista é usada em todos os lugares, para não existirem duas listas diferentes.

  > "Isolamento de rebuild: só as props de tema do MaterialApp (theme/darkTheme/themeMode) ficam dentro do builder. Trocar o tema não passa por setState na raiz nem reconstrói a árvore de rotas já montada — o MaterialApp só recebe novos valores de tema, e o Flutter reaproveita (via reconciliação de Element) tudo o que está abaixo dele."
  - 💡 Explicação Leiga: A linha faz com que apenas as cores sejam trocadas quando o usuário muda o tema. As telas já abertas continuam como estavam, sem serem desenhadas de novo.

  > "Escala de texto do app: acompanha o sistema até 2×, que é o teto do Android. Era 1,5× — um curativo sobre um layout que tinha ~30 alturas cravadas e cortaria o texto acima disso. Subiu para 2× depois que essas amarras viraram `minHeight`, os ícones que acompanham texto passaram a escalar junto e as faixas que genuinamente não podem crescer ganharam teto local via `MaxTextScale` (`core/ui/utils/text_scale.dart`). O teto que sobra aqui não é mais um curativo: acima de 2× o conteúdo continua legível, mas telas densas (o detalhe da loja, o dashboard do comerciante) passam a exigir rolagem longa demais para o que mostram. Se for para subir de novo, é caso a caso e com um caso novo em `test/dynamic_type_test.dart` para cada tela. `minScaleFactor: 0.9` continua: ninguém precisa de fonte menor por acessibilidade, e abaixo disso os rótulos de 10-11px do app ficam ilegíveis mesmo para quem escolheu reduzir."
  - 💡 Explicação Leiga: A linha permite que a letra do aplicativo cresça até o dobro do tamanho normal. Ela também impede que a letra fique menor que 90% do tamanho normal.

  > "A pilha inicial tem uma rota, sempre. O padrão do Navigator trata `initialRoute` como deep link e monta a pilha inteira do caminho: abrir em `/merchant` gerava `['/', '/merchant']`, deixando a `GuestHomePage` viva embaixo da sessão logada. O efeito era visível — o `AppBar` das abas passava a achar que havia para onde voltar, e voltar caía na home de visitante, sem conta, com o app ainda logado."
  - 💡 Explicação Leiga: A linha garante que o app abra com uma única tela na memória. Antes ficava uma tela de visitante escondida atrás da tela do usuário logado.

### 📂 ARQUIVO: lib/app/router/app_routes.dart

- ⚙️ Função: Guarda o nome de texto de cada tela, para o código não escrever esses nomes soltos.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

---

## 🧱 PARTE 2 — O NÚCLEO (peças usadas por todas as telas)

### 📂 ARQUIVO: lib/core/app_info.dart

- ⚙️ Função: Guarda o número da versão do aplicativo para mostrar na tela de Perfil.
- 💬 Comentários Removidos:

  > "Versão exibida no rodapé da tela de Perfil — mantida manualmente em sincronia com o campo `version:` do pubspec.yaml. Não usamos package_info_plus pra evitar puxar uma dependência nova só pra um rótulo."
  - 💡 Explicação Leiga: A linha guarda o texto "1.0.0 (1)" escrito à mão. Quem mudar a versão do projeto precisa mudar este texto também.

### 📂 ARQUIVO: lib/core/errors/exception.dart

- ⚙️ Função: Define os tipos de erro que o aplicativo sabe reconhecer e mostrar ao usuário.
- 💬 Comentários Removidos:

  > "A resposta chegou, mas em formato que o app não consegue interpretar. Distinta de [NetworkException] (não chegou) e [ServerException] (o servidor falhou): esta indica quebra de contrato entre cliente e API — campo obrigatório ausente, tipo trocado, corpo vazio onde se esperava uma lista. Existe porque esses casos antes viravam `TypeError` cru: por não serem [AppException], atravessavam todo `on AppException catch` do app e caíam nos `catch (_)` genéricos das telas, que os exibiam como erro de rede — ou não exibiam nada."
  - 💡 Explicação Leiga: A linha cria um tipo de erro para quando o servidor responde com dados fora do formato esperado. Sem ele, esse problema aparecia como falha de internet ou não aparecia.

### 📂 ARQUIVO: lib/core/location/location_service.dart

- ⚙️ Função: Descobre onde o celular está e transforma a posição em nome de bairro e cidade.
- 💬 Comentários Removidos:

  > "Stream de posição compartilhado por todo o app (mapa de lojas próximas, ronda do comerciante...): o hardware de GPS é assinado uma única vez, e desliga quando o último ouvinte cancela. Quem chama já deve ter verificado serviço/permissão (como os widgets fazem hoje)."
  - 💡 Explicação Leiga: A linha liga o GPS uma única vez e entrega a posição para todas as telas que precisarem. O GPS desliga sozinho quando nenhuma tela está mais escutando.

  > "Retorna 'Bairro, Cidade' (ou só 'Cidade' se não houver bairro) a partir da posição atual do dispositivo, ou o motivo pelo qual não foi possível."
  - 💡 Explicação Leiga: A função pega as coordenadas do GPS e devolve o nome do lugar em texto. Se não conseguir, ela devolve o motivo da falha.

### 📂 ARQUIVO: lib/core/network/api_client.dart

- ⚙️ Função: É o carteiro do aplicativo; todo pedido enviado ao servidor passa por aqui.
- 💬 Comentários Removidos:

  > "Construtor público com [dio] opcional: é a única costura que permite testar a camada de dados sem uma API real em `localhost:8080`. Em produção nada muda — todos os services continuam usando [instance]. O parâmetro existe para que um teste possa passar um `Dio` com `HttpClientAdapter` falso e exercitar service + model de ponta a ponta."
  - 💡 Explicação Leiga: A linha permite trocar o mecanismo de rede por um falso durante os testes. No aplicativo de verdade nada muda.

  > "Instância de produção. Continua sendo o caminho padrão de todo o app."
  - 💡 Explicação Leiga: A linha cria o carteiro único que o aplicativo inteiro usa.

  > "Substitui a instância de produção num teste. Chame `addTearDown(ApiClient.resetInstance)` para não vazar entre casos."
  - 💡 Explicação Leiga: A linha permite que um teste coloque um carteiro falso no lugar do verdadeiro. É preciso desfazer isso no fim do teste.

  > "Teto de tempo para envio de imagem (capa, galeria, foto de perfil). Fica aqui, e não repetido em cada service, porque é uma característica do transporte — os três services de upload compartilham exatamente o mesmo."
  - 💡 Explicação Leiga: A linha define quanto tempo o app espera ao enviar uma foto. O valor fica em um lugar só, usado pelos três envios de imagem.

  > "Converte o corpo da resposta em [T], ou lança [ParseException]. A versão anterior terminava em `data as T` (e `null as T` no corpo vazio): um `200 OK` sem corpo numa rota de lista, ou um payload em formato divergente, viravam `TypeError`. Como `TypeError` não é [AppException], escapava de todo `on AppException catch` do app e caía nos `catch (_)` genéricos das telas — o erro sumia ou aparecia como falha de rede."
  - 💡 Explicação Leiga: A função transforma a resposta do servidor no formato que a tela espera. Se o formato estiver errado, ela avisa com um erro que o app sabe mostrar.

  > "Corpo vazio só é resposta válida quando quem chamou espera algo anulável (`T?`) ou `dynamic` — o caso dos DELETE e dos POST de upload."
  - 💡 Explicação Leiga: A linha aceita resposta vazia apenas quando quem pediu avisou que a resposta pode vir vazia. É o caso de apagar algo ou enviar uma foto.

  > "Antes este catch era mudo e o fluxo caía no `as T` abaixo, que estourava escondendo a causa real (ex: página HTML de um proxy)."
  - 💡 Explicação Leiga: A linha lança um erro explicando o que aconteceu. Antes o erro real ficava escondido.

  > "Converte o DioException em AppException e, se for 401, dispara a limpeza de sessão global antes de relançar. [handle401] existe para as rotas em que 401 é resposta de negócio, e não sessão expirada: no login, 'senha incorreta' é um 401 legítimo, e tratá-lo como expiração desconectaria à força quem está apenas trocando de conta com uma sessão ainda válida no aparelho."
  - 💡 Explicação Leiga: A função traduz erros de rede para erros que o app entende. Quando o servidor diz "não autorizado", ela desconecta o usuário, exceto na tela de login.

  > "[options] existe para as rotas de upload, que precisam de um teto de tempo próprio (ver [ApiConstants.uploadTimeout]); [handle401] para as rotas em que 401 é resposta de negócio (ver [_throwFrom])."
  - 💡 Explicação Leiga: A função envia dados ao servidor. Ela aceita ajustes especiais para envio de fotos e para a tela de login.

### 📂 ARQUIVO: lib/core/network/api_constants.dart

- ⚙️ Função: Guarda o endereço do servidor e os tempos máximos de espera da rede.
- 💬 Comentários Removidos:

  > "Base da API, configurável em build/run: `flutter run --dart-define=API_URL=http://192.168.x.x:8080` (celular físico, IP da máquina na rede); `flutter run --dart-define=API_URL=http://10.0.2.2:8080` (emulador Android). Sem --dart-define, usa localhost (web/desktop na própria máquina)."
  - 💡 Explicação Leiga: A linha define o endereço do servidor. É possível trocar esse endereço na hora de rodar o aplicativo, sem mexer no código.

  > "Governa o envio do corpo da requisição. Sem ele, um upload multipart em rede ruim ficava pendurado indefinidamente — era o único timeout que faltava, e justamente o da operação mais longa do app."
  - 💡 Explicação Leiga: A linha define 60 segundos como limite para terminar de enviar dados. Sem esse limite, um envio em rede fraca ficava travado para sempre.

  > "Upload de imagem (capa, galeria de até 10 fotos, foto de perfil): os 15s padrão de recebimento estouram antes de o envio terminar em 4G fraco."
  - 💡 Explicação Leiga: A linha dá 90 segundos de prazo para enviar fotos. O prazo normal de 15 segundos era curto demais para isso.

### 📂 ARQUIVO: lib/core/network/cep_service.dart

- ⚙️ Função: Busca o endereço completo a partir de um CEP digitado pelo usuário.
- 💬 Comentários Removidos:

  > "Endereço resolvido a partir de um CEP."
  - 💡 Explicação Leiga: A linha cria a caixinha que guarda rua, bairro, cidade e estado encontrados.

  > "Busca endereço por CEP na API pública do ViaCEP — grátis, sem chave e com CORS liberado (funciona também no web). Usa um Dio avulso porque a URL é externa (não passa pelo ApiClient da API interna do MapFood)."
  - 💡 Explicação Leiga: A classe consulta um serviço público de CEP na internet. Ela usa uma conexão separada, porque não é o servidor do MapFood.

  > "Devolve o endereço do [cep] (8 dígitos, com ou sem hífen), ou null se o CEP não existir ou a busca falhar — quem chama segue sem autofill."
  - 💡 Explicação Leiga: A função devolve o endereço encontrado. Se o CEP não existir, ela devolve vazio e o usuário preenche à mão.

### 📂 ARQUIVO: lib/core/network/image_url_resolver.dart

- ⚙️ Função: Monta o endereço completo de uma foto a partir do pedaço que o servidor devolve.
- 💬 Comentários Removidos:

  > "Resolve um path de imagem devolvido pelo backend (ex: '/uploads/lojas/x.jpg') para uma URL completa. Devolve `null` se [path] for nulo/vazio, e devolve [path] sem alteração se já for uma URL absoluta."
  - 💡 Explicação Leiga: A função junta o endereço do servidor com o caminho da foto. Se o caminho já estiver completo, ela não muda nada.

### 📂 ARQUIVO: lib/core/network/interceptors/auth_interceptor.dart

- ⚙️ Função: Anexa o crachá digital do usuário em cada pedido enviado ao servidor.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

### 📂 ARQUIVO: lib/core/network/interceptors/error_interceptor.dart

- ⚙️ Função: Transforma erros técnicos de rede em mensagens em português para o usuário.
- 💬 Comentários Removidos:

  > "`sendTimeout` entrou junto com o `sendTimeout` do ApiClient: antes ele não estava configurado, então esse tipo nunca chegava aqui e caía no `else`, virando 'Erro desconhecido.' num upload lento."
  - 💡 Explicação Leiga: A linha reconhece o erro de "demorou demais para enviar". Antes esse caso virava uma mensagem genérica.

  > "`error` só serve quando NÃO é o corpo de erro padrão do Spring — lá essa chave carrega o nome do status em inglês ('Bad Request'), que não diz nada a quem está usando o app em português."
  - 💡 Explicação Leiga: A linha só aproveita o campo "error" quando ele traz uma mensagem útil. Quando ele traz texto em inglês do servidor, é descartado.

  > "Corpo de texto puro pode ser uma página HTML de proxy/gateway — jogar isso na tela do usuário é pior do que a mensagem genérica."
  - 💡 Explicação Leiga: A linha ignora respostas que parecem uma página de internet. Mostrar código HTML na tela seria pior que uma mensagem simples.

  > "Assinatura do `{'timestamp':..., 'status':..., 'error':..., 'path':...}` que o Spring Boot devolve quando nenhum handler tratou a exceção."
  - 💡 Explicação Leiga: A função reconhece o formato de erro padrão do servidor. Ela serve para saber quando a mensagem não é útil.

  > "Bean Validation também devolve `{'errors': {'nome': 'não pode ser vazio'}}`."
  - 💡 Explicação Leiga: A linha lê os erros de preenchimento de formulário que o servidor devolve.

  > "Não há mais fallback para `data.values.first`. O corpo de erro padrão do Spring é `{timestamp, status, error, path}` — e o primeiro valor dele é o timestamp, que era exibido ao usuário como se fosse a mensagem de erro ('2026-08-24T14:32:11.482+00:00'). Sem mensagem aqui, o texto genérico do `switch` acima entra, que é o comportamento correto."
  - 💡 Explicação Leiga: A linha devolve vazio quando não há mensagem aproveitável. Antes o app mostrava uma data e hora no lugar do erro.

### 📂 ARQUIVO: lib/core/network/json_reader.dart

- ⚙️ Função: Lê com segurança cada campo dos dados que chegam do servidor.
- 💬 Comentários Removidos:

  > "Leitura defensiva de JSON vindo da API. Antes, cada `fromJson` misturava três dialetos no mesmo objeto: `(json['id'] as num)` (estoura em null), `json['nome'] as String?` (estoura em tipo trocado) e `json['x']?.toString()` (tolerante a tudo). Os dois primeiros lançavam `TypeError` — que não é [AppException] e, por isso, atravessava todo o tratamento de erro do app. Estas extensões concentram a decisão num lugar só: campo obrigatório ausente ou inválido vira [ParseException] com o nome do campo; campo opcional ausente vira `null` sem drama. Vive fora do `ApiClient` de propósito: ler JSON não é responsabilidade do cliente HTTP, e assim os models podem ser testados sem tocar em Dio."
  - 💡 Explicação Leiga: Este bloco cria funções para ler cada campo dos dados recebidos. Se um campo obrigatório faltar, o erro diz o nome do campo.

  > "Inteiro obrigatório. Aceita `num` e string numérica (o backend devolve id como número, mas alguns agregados chegam como string)."
  - 💡 Explicação Leiga: A função lê um número obrigatório. Ela aceita tanto número quanto texto que contenha número.

  > "String obrigatória e não vazia."
  - 💡 Explicação Leiga: A função lê um texto que precisa existir e não pode estar em branco.

  > "String opcional. Devolve `null` também para string vazia — no domínio do app, '' e 'não informado' são a mesma coisa em todo campo opcional."
  - 💡 Explicação Leiga: A função lê um texto que pode faltar. Texto em branco é tratado como ausente.

  > "String opcional com padrão. Diferente de `optString(k) ?? padrao` só na legibilidade do call site, que é onde este helper mais aparece."
  - 💡 Explicação Leiga: A função lê um texto e, se ele faltar, usa um valor combinado antes.

  > "Lista opcional. Devolve lista vazia (nunca null) quando o campo falta ou não é uma lista — quem consome sempre itera."
  - 💡 Explicação Leiga: A função lê uma lista. Se a lista não vier, ela devolve uma lista vazia em vez de nada.

  > "Lista de strings, ignorando entradas vazias."
  - 💡 Explicação Leiga: A função lê uma lista de textos e joga fora os itens em branco.

### 📂 ARQUIVO: lib/core/session/session_manager.dart

- ⚙️ Função: Desconecta o usuário e volta para o login quando o crachá digital expira.
- 💬 Comentários Removidos:

  > "Reage a um 401 vindo da API limpando a sessão e voltando pro login — sem isso, um token expirado deixava o app 'logado' falhando em silêncio, já que cada tela só fazia catch(_) do erro."
  - 💡 Explicação Leiga: A classe percebe quando o servidor recusa o crachá do usuário. Ela então apaga a sessão e leva o usuário para a tela de login.

  > "signOut limpa disco E memória — sem isso o SessionStore continuaria publicando um usuário logado que a API já rejeitou."
  - 💡 Explicação Leiga: A linha apaga os dados do usuário do disco e da memória ao mesmo tempo.

  > "Sem await de propósito: este Future só completa quando a tela de login for descartada, e o `finally` abaixo precisa liberar o guard de 401 agora — aguardar aqui travaria `_handling` em true para sempre."
  - 💡 Explicação Leiga: A linha abre a tela de login sem esperar que ela feche. Esperar deixaria a trava de segurança presa para sempre.

### 📂 ARQUIVO: lib/core/session/session_store.dart

- ⚙️ Função: Guarda na memória quem está logado, para qualquer tela consultar na hora.
- 💬 Comentários Removidos:

  > "Sessão do usuário em memória — fonte única e síncrona de quem está logado e com que papel. Existe porque o papel do usuário era descoberto de duas formas ruins ao mesmo tempo: 1. `AuthStorage.getSession()` chamado em 19 lugares diferentes — I/O assíncrono em `SharedPreferences` seguido de um `setState` que reconstruía a tela inteira só para escrever uma string; e 2. `userRole` empurrado por construtor através de até 4 níveis de widget (`SearchPage` → carrossel → card → botão de favorito). [AuthStorage] continua sendo a camada de persistência; esta classe é o espelho em memória, hidratado uma vez no `main()` e atualizado nos três pontos que realmente mudam sessão: login, logout e edição de perfil."
  - 💡 Explicação Leiga: A classe guarda na memória o nome, o número e o tipo do usuário logado. Assim nenhuma tela precisa ler o disco para saber quem está usando o app.

  > "Papel do usuário no vocabulário que a UI já usa: 'CONSUMIDOR', 'COMERCIANTE' ou 'GUEST' quando não há sessão."
  - 💡 Explicação Leiga: A linha devolve o tipo do usuário. Se ninguém está logado, ela devolve "visitante".

  > "Id do usuário logado, ou `null` para visitante. Substitui o `(await AuthStorage.getSession())?.id` espalhado pelas telas."
  - 💡 Explicação Leiga: A linha devolve o número de identificação do usuário logado.

  > "Carrega a sessão persistida. Chamado uma vez no `main()`, antes do `runApp` — a partir daí toda leitura é síncrona."
  - 💡 Explicação Leiga: A função lê do disco os dados do usuário salvo. Ela roda uma vez só, quando o app abre.

  > "Persiste e publica a nova sessão (login / cadastro com login automático)."
  - 💡 Explicação Leiga: A função salva a nova sessão no disco e avisa as telas que alguém entrou.

  > "Limpa persistência e memória (logout, exclusão de conta, 401)."
  - 💡 Explicação Leiga: A função apaga tudo sobre o usuário logado, do disco e da memória.

  > "Reflete uma edição de perfil já salva no backend. Mantém token, id e tipo."
  - 💡 Explicação Leiga: A função atualiza o nome e o e-mail guardados. O crachá e o número do usuário continuam os mesmos.

### 📂 ARQUIVO: lib/core/storage/auth_storage.dart

- ⚙️ Função: Salva no disco do celular os dados da sessão para o usuário não precisar logar de novo.
- 💬 Comentários Removidos:

  > "Não faz parte da sessão (não é limpa em `clear()`/logout) — é a data do primeiro login já feito neste aparelho, usada como proxy de 'Dias no App' pra consumidor, que não tem `dataCadastro` no backend (diferente de Comerciante). Só reseta se o app for desinstalado/reinstalado."
  - 💡 Explicação Leiga: A linha guarda a data do primeiro login neste celular. Essa data não é apagada quando o usuário sai da conta.

  > "Dias desde o primeiro login neste aparelho — se a sessão já existia antes desta marca ter sido introduzida, o primeiro acesso ao perfil grava 'agora' como marco inicial (dia 0), em vez de quebrar."
  - 💡 Explicação Leiga: A função conta há quantos dias a pessoa usa o app neste aparelho. Se não houver data salva, ela começa a contar de hoje.

  > "Atualiza nome/e-mail da sessão salva localmente — chamado depois de um 'Editar Perfil' bem-sucedido. Sem isso, `getSession()` continuava devolvendo o nome antigo (o do login) até o usuário deslogar e logar de novo, mesmo com o backend já salvo com o dado novo."
  - 💡 Explicação Leiga: A função grava no disco o nome e o e-mail novos. Sem ela, o app continuava mostrando o nome antigo.

### 📂 ARQUIVO: lib/core/storage/onboarding_storage.dart

- ⚙️ Função: Lembra se o usuário já viu as telas de boas-vindas neste celular.
- 💬 Comentários Removidos:

  > "Marca de 'já viu a tela de boas-vindas' — separada de [AuthStorage] de propósito: não faz parte da sessão e não pode ser apagada no logout, senão sair da conta jogaria o usuário de volta no onboarding."
  - 💡 Explicação Leiga: A classe guarda uma marca separada dos dados de login. Sair da conta não apaga essa marca.

---

## 🎨 PARTE 3 — AS REGRAS VISUAIS (cores, letras, tamanhos)

### 📂 ARQUIVO: lib/core/ui/charts/chart_data.dart

- ⚙️ Função: Define o formato dos números que os gráficos recebem para desenhar.
- 💬 Comentários Removidos:

  > "Contrato entre quem agrega os números e quem os desenha. Os widgets de gráfico (`core/ui/charts/`) recebem só estes tipos — nunca um DTO, um service ou um controller. É o que os mantém testáveis sem API no ar e reutilizáveis por qualquer tela que já tenha os números em mãos."
  - 💡 Explicação Leiga: Este bloco define caixinhas simples com rótulo e valor. Os gráficos só aceitam essas caixinhas, nunca dados vindos direto do servidor.

  > "Uma fatia de rosca/pizza. A cor entra aqui, e não na agregação, de propósito: numa rosca a cor é a legenda, e escolhê-la depende do tema (claro/escuro) — ou seja, é decisão de quem constrói a tela, com um `BuildContext` em mãos."
  - 💡 Explicação Leiga: A classe guarda uma fatia do gráfico com nome, valor e cor. A cor é escolhida pela tela, porque depende do tema claro ou escuro.

### 📂 ARQUIVO: lib/core/ui/charts/distribution_donut_chart.dart

- ⚙️ Função: Desenha um gráfico de rosca com a legenda escrita ao lado.
- 💬 Comentários Removidos:

  > "Rosca de distribuição + legenda ao lado. Recebe só [DonutSlice] — quem chama já resolveu rótulo, valor e cor. Duas escolhas de leitura, para a rosca não virar enfeite: A legenda fica fora, com o percentual escrito. Título dentro da fatia só cabe em fatia grande; nas pequenas ele some ou vaza, e é justamente a fatia pequena que a pessoa quer identificar. Nada depende só de cor. Cada item da legenda repete o nome e o número, então a rosca continua legível para quem não distingue o par de cores (WCAG 1.4.1 — o mesmo motivo do ✓ no `AppChoiceChip`)."
  - 💡 Explicação Leiga: O gráfico escreve o nome e a porcentagem de cada fatia numa lista ao lado. Assim quem não distingue as cores ainda entende o gráfico.

  > "Conteúdo do buraco do meio (o total, a média). `null` deixa vazado."
  - 💡 Explicação Leiga: A linha permite colocar um número no centro da rosca. Se não for informado, o centro fica vazio.

  > "Fatia sob o dedo — cresce enquanto tocada. `-1` = nenhuma."
  - 💡 Explicação Leiga: A linha guarda qual fatia está sendo tocada. O valor menos um significa que nenhuma está.

  > "Tabular: os percentuais ficam alinhados na coluna mesmo com números de larguras diferentes."
  - 💡 Explicação Leiga: A linha usa um tipo de letra em que todo número ocupa a mesma largura. Isso deixa as porcentagens alinhadas uma embaixo da outra.

### 📂 ARQUIVO: lib/core/ui/navigation/app_page_route.dart

- ⚙️ Função: Define como uma tela nova entra, mantendo o gesto de arrastar para voltar.
- 💬 Comentários Removidos:

  > "Rota padrão do app: `CupertinoPageRoute` em vez de `MaterialPageRoute`, para a navegação manter o gesto nativo de arrastar da borda para voltar. [settings] existe para as rotas nomeadas (a pilha inicial montada no `main`): sem o nome, a rota fica anônima e qualquer código que consulte `ModalRoute.of(context)?.settings.name` deixa de reconhecê-la."
  - 💡 Explicação Leiga: A função abre telas de um jeito que permite voltar arrastando o dedo da borda. Ela também guarda o nome da tela para o código conseguir identificá-la.

### 📂 ARQUIVO: lib/core/ui/theme/app_colors.dart

- ⚙️ Função: Lista as cores fixas da marca, que valem igual no tema claro e no escuro.
- 💬 Comentários Removidos:

  > "Vermelho MapFood. Só para ação e estado ativo, nunca como fundo de área."
  - 💡 Explicação Leiga: A linha define o vermelho da marca. Ele só é usado em botões e itens ativos.

  > "[brand] escurecido para o estado pressionado de superfícies de marca."
  - 💡 Explicação Leiga: A linha define um vermelho mais escuro, usado enquanto o dedo está pressionando o botão.

  > "Fundo suave de marca: chip selecionado, badge, realce de seleção. No tema escuro use [brandSurfaceDark]."
  - 💡 Explicação Leiga: A linha define um rosa bem claro. Ele é usado como fundo de etiquetas selecionadas.

  > "brand @ 14%"
  - 💡 Explicação Leiga: A linha define o vermelho da marca com 14% de opacidade, para o tema escuro.

  > "Preto azulado da marca. É a cor de texto primário no tema claro e o fundo dos CTAs 'neutros fortes' (o botão preto de Sair, os pins do mapa)."
  - 💡 Explicação Leiga: A linha define um preto puxado para o azul. É a cor do texto principal e do botão preto.

  > "Amarelo de nota/estrela."
  - 💡 Explicação Leiga: A linha define o amarelo usado nas estrelas de avaliação.

  > "Variante escurecida de [rating] para texto sobre fundo amarelo suave — [rating] puro não passa em contraste nesse par."
  - 💡 Explicação Leiga: A linha define um amarelo escuro para escrever números sobre fundo amarelo claro. O amarelo normal ficaria ilegível.

  > "Azul de informação neutra. Existe porque 'info' era pintado com o vermelho da marca (`brandContent`), o que dava a um aviso sem gravidade a mesma cor de um erro."
  - 💡 Explicação Leiga: A linha define um azul para avisos comuns. Antes esses avisos apareciam em vermelho, parecendo erro.

  > "superfícies semânticas preenchidas — Para quando a cor semântica é o fundo de um bloco com texto por cima (hoje: o toast), e não um traço ou um ícone. Os tons puros acima não servem aí: `success` puro rende 3,4:1 com branco e `warning` puro, 2,0:1 — os dois reprovam no AA para texto de corpo."
  - 💡 Explicação Leiga: Este grupo define cores para usar como fundo cheio de um aviso. As cores normais não têm contraste suficiente com texto branco.

  > "Verde escurecido: 5,5:1 com branco."
  - 💡 Explicação Leiga: A linha define o verde de fundo dos avisos de sucesso. Ele foi escurecido para o texto branco ficar legível.

  > "O vermelho da marca já rende 5,4:1 com branco — o token existe para o call site declarar a intenção ('fundo de erro'), não uma cor nova."
  - 💡 Explicação Leiga: A linha dá um segundo nome ao vermelho da marca. O nome novo deixa claro que ali ele significa erro.

  > "Azul de info: 6,7:1 com branco."
  - 💡 Explicação Leiga: A linha define o azul de fundo dos avisos neutros.

  > "O amarelo puro, com texto escuro por cima ([ink], 8,7:1). É o único preenchimento semântico que não aceita texto branco: escurecer o amarelo até ele passar com branco produz um marrom que ninguém lê como 'alerta'."
  - 💡 Explicação Leiga: A linha usa o amarelo puro como fundo de alerta. O texto por cima dele precisa ser escuro.

  > "Fundo de ação destrutiva (botão 'Excluir conta')."
  - 💡 Explicação Leiga: A linha define um vermelho bem claro, usado atrás de botões que apagam coisas.

  > "Ponto de localização do usuário no mapa."
  - 💡 Explicação Leiga: A linha define o azul da bolinha que mostra onde o usuário está.

  > "Paleta legada. Continua valendo enquanto a migração para [MfColor] e `context.mapColors` acontece lote a lote — os valores abaixo já apontam para os tokens novos onde há equivalente exato, então quem ainda usa esta classe recebe as cores corretas de graça."
  - 💡 Explicação Leiga: Esta classe guarda os nomes de cor antigos. Eles agora apontam para as cores novas, para o app não mudar de aparência.

  > "Cinza de apoio no tema escuro → `textSecondary` escuro da escala nova."
  - 💡 Explicação Leiga: A linha aponta um nome antigo de cinza para a cor nova equivalente.

  > "Texto secundário no tema claro → `textSecondary` claro da escala nova. Escurecido junto com o token (era `#6B7280`, que rendia 4,39:1 sobre `surfaceAlt` e reprovava no AA) para os dois não divergirem."
  - 💡 Explicação Leiga: A linha define o cinza dos textos de apoio. Ele foi escurecido para ficar legível sobre fundo claro.

  > "Fundo de tela do tema claro. Continua branco: o degrau de contraste agora vem de `surfaceAlt` (#F3F4F5), não de escurecer o fundo."
  - 💡 Explicação Leiga: A linha mantém o fundo das telas branco. A separação entre blocos vem de outra cor cinza.

  > "`--vermelho-degrade-3` da web. Cor de apoio para gradiente de hero — nunca como fundo de superfície."
  - 💡 Explicação Leiga: A linha define um vermelho de apoio usado só em degradês.

  > "Amarelo de nota/estrela. Antes cada tela escolhia um tom do `Colors.amber` do Material (shade400 no carrossel, shade500 nos badges, shade600 na lista de avaliações...), o que deixava a mesma estrela com um amarelo diferente em cada card. Valor único do Design System."
  - 💡 Explicação Leiga: A linha define um amarelo único para todas as estrelas. Antes cada tela usava um amarelo diferente.

  > "Variante escurecida de [ratingStar] para texto sobre o fundo amarelo translúcido do pill de nota — [ratingStar] puro não passa em contraste nesse par (era `Colors.amber.shade900` antes, pelo mesmo motivo)."
  - 💡 Explicação Leiga: A linha define o amarelo escuro do número da nota. O amarelo claro não seria legível ali.

### 📂 ARQUIVO: lib/core/ui/theme/app_dimensions.dart

- ⚙️ Função: Define os espaços, os cantos arredondados e os tempos de animação do aplicativo.
- 💬 Comentários Removidos:

  > "Uso típico: [xs] entre um ícone e seu rótulo; [sm] entre linhas de um mesmo bloco; [md] padding interno de chip/campo; [base] padding de card e gutter de lista; [lg] margem lateral da tela; [xl] entre seções; [xxl]/[xxxl] respiro de topo/rodapé de tela"
  - 💡 Explicação Leiga: Esta classe lista os tamanhos de espaço em branco permitidos. Cada tamanho tem um lugar certo de uso.

  > "Raios (v2). Regra: quanto maior a superfície, maior o raio — e pílula só em chip, badge e botão circular. Pílula em tudo (botão, campo, card), como estava, achata a hierarquia: se todo elemento tem a mesma forma, nenhum se destaca."
  - 💡 Explicação Leiga: Esta classe lista quanto os cantos são arredondados. Blocos maiores têm cantos mais arredondados.

  > "Tag, badge, selo de categoria."
  - 💡 Explicação Leiga: A linha define o canto arredondado de 8 pontos, usado em etiquetas.

  > "Campo de formulário, botão secundário, thumbnail."
  - 💡 Explicação Leiga: A linha define o canto arredondado de 12 pontos, usado em campos de digitar.

  > "Botão primário, card de lista."
  - 💡 Explicação Leiga: A linha define o canto arredondado de 16 pontos, usado no botão principal.

  > "Card grande, modal."
  - 💡 Explicação Leiga: A linha define o canto arredondado de 20 pontos, usado em cartões grandes.

  > "Bottom sheet, hero card."
  - 💡 Explicação Leiga: A linha define o canto arredondado de 28 pontos, usado nos painéis que sobem de baixo.

  > "Só chip, badge e botão circular."
  - 💡 Explicação Leiga: A linha define o formato totalmente redondo, de cápsula.

  > "Duração e curva de animação. Uma escala curta evita que cada tela invente seu próprio tempo — a inconsistência de ritmo é percebida como 'lentidão' mesmo quando cada animação isolada parece boa."
  - 💡 Explicação Leiga: Esta classe define três velocidades de animação. Todas as telas usam essas mesmas três.

  > "Estados de componente: hover, seleção, cor, escala."
  - 💡 Explicação Leiga: A linha define a animação rápida, de 150 milésimos de segundo.

  > "Expansão, sheet, mudança de altura."
  - 💡 Explicação Leiga: A linha define a animação média, de 220 milésimos de segundo.

  > "Transição de página."
  - 💡 Explicação Leiga: A linha define a animação lenta, de 300 milésimos de segundo.

  > "escalas legadas — Mantidas com os valores originais enquanto a migração acontece: trocar esses números por dentro mexeria no espaçamento de todas as telas de uma vez, sem ninguém decidir tela a tela. Saem quando os lotes terminarem."
  - 💡 Explicação Leiga: Esta classe guarda os nomes de espaçamento antigos com os valores antigos. Mudá-los agora bagunçaria todas as telas de uma vez.

  > "Tamanhos canônicos de ícone. Fora desta escala, nada. [sm] inline em texto · [md] padrão de UI · [lg] navegação e ação principal · [xl] empty state."
  - 💡 Explicação Leiga: Esta classe lista os quatro tamanhos de ícone permitidos.

### 📂 ARQUIVO: lib/core/ui/theme/app_elevation.dart

- ⚙️ Função: Define os três tipos de sombra que os blocos podem ter.
- 💬 Comentários Removidos:

  > "Nível 1 — card em lista, item destacado dentro da página."
  - 💡 Explicação Leiga: A linha define a sombra mais fraca, usada em cartões de lista.

  > "Nível 2 — o que flutua sobre outro conteúdo: barra de busca sobre o mapa, bottom bar, botão de recentralizar, bottom sheet."
  - 💡 Explicação Leiga: A linha define a sombra média, usada no que fica por cima do mapa.

  > "Nível 3 — card imersivo de foto, onde a sombra precisa segurar uma superfície grande e visualmente pesada."
  - 💡 Explicação Leiga: A linha define a sombra mais forte, usada em cartões grandes com foto.

### 📂 ARQUIVO: lib/core/ui/theme/app_icons.dart

- ⚙️ Função: Dá um nome próprio a cada ícone do aplicativo, para todos virem da mesma família.
- 💬 Comentários Removidos:

  > "Coração preenchido — o estado 'favoritado'. Mesmo par de [star]/[starFill]: o contorno marca a ação disponível, o sólido marca o estado ativo. Só a cor não bastava aqui — o vermelho da marca no contorno fino lê como 'botão vermelho', não como 'já é seu favorito'."
  - 💡 Explicação Leiga: A linha escolhe o coração cheio para indicar favorito salvo. O coração vazado indica que ainda dá para favoritar.

  > "Escudo com ✓ — 'nada pesa contra você'. Marca o estado limpo do card de denúncias, onde um '0' grande leria como alerta antes de ser lido."
  - 💡 Explicação Leiga: A linha escolhe um escudo com sinal de certo. Ele mostra que a loja não tem denúncias.

  > "Conceitos sem equivalente semântico exato entre os anteriores — mantidos com nome próprio, todos já Phosphor Regular."
  - 💡 Explicação Leiga: Este grupo lista ícones que não se encaixam nas categorias acima.

  > "Transmissão ao vivo — a loja em ronda enviando posição."
  - 💡 Explicação Leiga: A linha escolhe o ícone de transmissão. Ele aparece quando uma loja móvel está enviando sua posição.

  > "Recarregar/tentar de novo."
  - 💡 Explicação Leiga: A linha escolhe a seta circular usada no botão de tentar de novo.

  > "Categorias que existiam no banco sem ícone próprio. Elas têm arte em `utils/category_images.dart`, mas a arte só é usada no filtro da busca — nos badges de card e no chip do detalhe da loja o ícone aparece sozinho, e lá todas caíam no `forkKnife` padrão. Talher num Pet Shop, numa loja de roupa ou num prestador de serviço é simplesmente errado."
  - 💡 Explicação Leiga: Este grupo dá um ícone próprio a categorias que não são comida. Antes todas apareciam com um garfo e faca.

### 📂 ARQUIVO: lib/core/ui/theme/app_theme.dart

- ⚙️ Função: Monta a aparência completa do tema claro e do tema escuro.
- 💬 Comentários Removidos:

  > "ThemeData de claro/escuro do app. [ThemeController] só escolhe QUAL destes dois usar; a definição visual de cada um vive só aqui. O que mudou na v2: Inter no lugar de Poppins, empacotada em `assets/fonts/` em vez de baixada em runtime pelo `google_fonts` (sem download no primeiro launch, sem flash de fonte trocando, funciona offline). É a mesma fonte da web (`mapfood-web/tailwind.config.ts`), então as duas pontas do produto passam a falar a mesma língua. `ColorScheme` escrito à mão em vez de `fromSeed`. O algoritmo do Material You deriva a paleta inteira a partir do vermelho da marca e tinge tudo — superfície, borda, container — de rosa. Um sistema com cor de marca forte precisa de neutros verdadeiros; a cor entra por decisão, não por derivação. Geometria: campo com raio 12 (era pílula), superfícies com os raios de [Radii], nenhuma elevação em botão."
  - 💡 Explicação Leiga: Esta classe monta as duas aparências do app. A letra usada vem de dentro do aplicativo, não da internet.

  > "Container de marca: fundo suave de chip selecionado e badge."
  - 💡 Explicação Leiga: A linha escolhe o fundo rosa claro no tema claro e o vermelho translúcido no escuro.

  > "'Secundário' aqui é o neutro forte da marca (o preto azulado), que é o que o app usa em CTA neutro e pin de mapa."
  - 💡 Explicação Leiga: A linha define a cor secundária do tema como o preto da marca.

  > "No Material 3 `outline` é o traço que identifica um componente e `outlineVariant` o decorativo — mesmo par de `borderStrong`/`border`."
  - 💡 Explicação Leiga: A linha liga os dois tipos de borda do app aos dois tipos de borda do Flutter.

  > "Registra o MapFoodColors correspondente pra esta brightness — é o que faz `context.mapColors` devolver os tokens certos em cada tema."
  - 💡 Explicação Leiga: A linha guarda as cores do MapFood dentro do tema. É isso que faz as telas pegarem a cor certa em cada tema.

  > "Material 3 tinge superfícies com a cor primária conforme a elevação ('surface tint'). Com um vermelho forte de marca isso deixa card e app bar rosados — desligado aqui e via surfaceTintColor nos temas de componente abaixo."
  - 💡 Explicação Leiga: A linha desliga um efeito do Flutter que deixava os cartões rosados.

  > "Campo de formulário: superfície rebaixada, raio 12, rótulo por fora (ver AppFormField). A borda só ganha cor e espessura no foco — em repouso ela existe apenas para separar o campo do fundo."
  - 💡 Explicação Leiga: Este bloco define a aparência dos campos de digitar. A borda fica mais forte quando o campo está selecionado.

  > "`borderStrong`, não `border`: o campo tem fundo `surfaceAlt`, que rende só 1,07:1 contra o fundo da tela — a borda é literalmente a única coisa que diz onde o campo começa e termina, então ela carrega informação e precisa dos 3:1 do WCAG 1.4.11."
  - 💡 Explicação Leiga: A linha usa a borda mais escura no campo. Sem ela não daria para ver onde o campo começa.

  > "Desabilitado segue fraco de propósito: componente inativo é isento (WCAG 1.4.3) e o apagamento é justamente o que comunica o estado."
  - 💡 Explicação Leiga: A linha deixa a borda fraca em campos desativados. O apagamento é o sinal de que o campo não funciona.

  > "Botões: altura 52, raio 16, sem elevação. Profundidade no sistema vem de superfície e sombra de container, nunca de botão levantado."
  - 💡 Explicação Leiga: A linha define a aparência padrão dos botões. Eles não têm sombra própria.

  > "Botão outline é só contorno: sem fundo próprio, a borda é o botão."
  - 💡 Explicação Leiga: A linha dá borda visível ao botão sem fundo.

  > "Traço fino: o padrão do Material (4px) fica pesado ao lado de tipografia e ícones de traço leve."
  - 💡 Explicação Leiga: A linha deixa o círculo de carregamento mais fino que o padrão.

  > "Swipe-to-go-back nativo nas duas plataformas (mesma decisão do appPageRoute, aplicada também às rotas nomeadas)."
  - 💡 Explicação Leiga: A linha habilita o gesto de arrastar para voltar em Android e iPhone.

  > "Campo com raio 12. Houve uma tentativa de levar tudo para cápsula, por 'coerência de família' com a busca; na tela, o formulário ficou pior — campo em cápsula lê como chip, e uma coluna de cápsulas empilhadas perde a leitura de bloco que o raio 12 dá. A cápsula ficou só onde ela é a forma certa: a busca (ver `SearchFieldWidget`), que é um controle solto, não um item de formulário."
  - 💡 Explicação Leiga: A função desenha a borda dos campos com canto de 12 pontos. Só a barra de busca é totalmente arredondada.

  > "Size(0, 52) e não Size.fromHeight(52): `fromHeight` produz `Size(double.infinity, 52)`, ou seja, largura mínima infinita. Num botão dentro de `Row` (o par Cancelar/Confirmar dos diálogos, por exemplo) isso vira `BoxConstraints forces an infinite width` e derruba o layout inteiro — o diálogo simplesmente não aparece. Quem quiser largura total pede explicitamente (ver `AppButton.expand`)."
  - 💡 Explicação Leiga: A linha define só a altura mínima do botão, deixando a largura livre. A forma antiga quebrava os diálogos com dois botões lado a lado.

  > "Desabilitado como superfície apagada, não como opacidade no widget inteiro: baixar a opacidade apaga a borda junto e deixa o botão 'fantasma' em vez de claramente inativo."
  - 💡 Explicação Leiga: A linha troca a cor do botão desativado em vez de deixá-lo transparente.

  > "TextTheme derivado da mesma escala de [AppText] — é o que garante que um `Text` sem estilo explícito já nasça com a tipografia certa."
  - 💡 Explicação Leiga: A função aplica a escala de letras do app em todos os textos. Um texto sem estilo definido já sai correto.

### 📂 ARQUIVO: lib/core/ui/theme/app_typography.dart

- ⚙️ Função: Define todos os tamanhos e pesos de letra usados no aplicativo.
- 💬 Comentários Removidos:

  > "Escala tipográfica do app (v2, Inter). Três regras que valem para tudo aqui: 1. Título grande tem letter-spacing negativo. Fonte grande com espaçamento padrão parece esparramada; apertar de −0.4 a −1.0 é o que dá o ar compacto de produto. 2. Botão tem letter-spacing zero. Espaçamento positivo em botão é assinatura de Material 2 e envelhece a tela na hora. 3. Estilo não carrega cor de marca. Cada estilo resolve só a cor de conteúdo (primário/secundário) a partir do tema; quem compõe decide o resto. Um estilo com `color: Colors.white` embutido obriga todo call site a sobrescrever — era o caso do `botao` antigo."
  - 💡 Explicação Leiga: Esta classe reúne todos os estilos de texto do app. Nenhum estilo traz cor de marca embutida.

  > "Família única, declarada no `pubspec.yaml`. Enquanto os arquivos não estiverem em `assets/fonts/`, o Flutter cai na fonte do sistema sem quebrar — o app roda, só não fica com o desenho certo."
  - 💡 Explicação Leiga: A linha define o nome da fonte usada. Se o arquivo da fonte faltar, o app usa a fonte do celular.

  > "display e títulos"
  - 💡 Explicação Leiga: Marca o início do grupo de estilos de título.

  > "32/38 w700 — abertura de tela (o 'Perfil', o 'Bem-vindo de volta')."
  - 💡 Explicação Leiga: A função devolve o maior estilo de título, com 32 pontos de altura.

  > "24/30 w700 — título de tela."
  - 💡 Explicação Leiga: A função devolve o estilo de título de tela, com 24 pontos.

  > "20/26 w600 — título de seção."
  - 💡 Explicação Leiga: A função devolve o estilo de título de seção, com 20 pontos.

  > "16/22 w600 — título de card e de item de lista."
  - 💡 Explicação Leiga: A função devolve o estilo de título de cartão, com 16 pontos.

  > "corpo"
  - 💡 Explicação Leiga: Marca o início do grupo de estilos de texto comum.

  > "15/22 w400 — texto corrente."
  - 💡 Explicação Leiga: A função devolve o estilo do texto normal, com 15 pontos.

  > "15/22 w600 — o mesmo corpo, com ênfase (valor ao lado de rótulo)."
  - 💡 Explicação Leiga: A função devolve o texto normal em negrito.

  > "13/18 w400 — apoio, subtítulo de item de lista."
  - 💡 Explicação Leiga: A função devolve o estilo de texto de apoio, com 13 pontos.

  > "12/16 w500 — metadado, rótulo de campo, legenda."
  - 💡 Explicação Leiga: A função devolve o estilo de legenda, com 12 pontos.

  > "11/14 w600 caixa alta — rótulo de seção ('MINHA CONTA')."
  - 💡 Explicação Leiga: A função devolve o estilo de rótulo em letras maiúsculas.

  > "15/20 w600 — rótulo de botão. Sem cor: quem monta o botão define, porque ela depende da variante (branco no primário, texto primário no secundário, marca no ghost)."
  - 💡 Explicação Leiga: A função devolve o estilo do texto de botão, sem definir a cor.

  > "números"
  - 💡 Explicação Leiga: Marca o início do grupo de estilos para números.

  > "Métrica grande (o total do gráfico, o valor de um card de estatística). `tabularFigures` deixa todo dígito com a mesma largura — sem isso o número 'pula' lateralmente quando o valor muda de 1 para 2, que é justamente o caso de um contador que atualiza."
  - 💡 Explicação Leiga: A função devolve o estilo dos números grandes. Todo dígito ocupa a mesma largura, para o número não tremer ao mudar.

  > "Número inline (nota, distância, contagem) — mesma largura de dígito, tamanho de corpo."
  - 💡 Explicação Leiga: A função devolve o estilo dos números pequenos, como notas e distâncias.

  > "nomes legados (apelidos) — O app tem centenas de chamadas a estes nomes. Apontá-los para a escala nova troca a tipografia inteira de uma vez, sem um mutirão de renomeação. Saem conforme cada tela for migrada nos lotes seguintes."
  - 💡 Explicação Leiga: Este grupo mantém os nomes antigos de estilo apontando para os novos. Assim a letra muda em todo o app sem reescrever cada tela.

  > "Mantém a cor branca embutida do estilo antigo: há botões de fundo escuro que dependem dela implicitamente. O substituto correto é [button] (sem cor) — a troca acontece junto com o `AppButton` no lote 2."
  - 💡 Explicação Leiga: A função mantém o texto branco embutido, porque alguns botões antigos dependem disso.

### 📂 ARQUIVO: lib/core/ui/theme/category_colors.dart

- ⚙️ Função: Associa uma cor a cada categoria de loja.
- 💬 Comentários Removidos:

  > "Cor de marca de cada categoria — pinta o círculo atrás da arte (a 12% de opacidade) e o rótulo quando o filtro está ativo. As chaves espelham a coluna `nome` da tabela `categoria`, igual a `utils/category_images.dart`. Sem entrada aqui a categoria cai no cinza padrão. Isso não quebra nada, mas deixa o filtro sem identidade — foi o que acontecia com as seis categorias não-comida."
  - 💡 Explicação Leiga: Esta lista liga o nome de cada categoria a uma cor. O nome precisa ser escrito igual ao que está no banco de dados.

  > "id 1..12 — comida"
  - 💡 Explicação Leiga: Marca o começo das categorias de comida na lista.

  > "id 13..18 — não-comida"
  - 💡 Explicação Leiga: Marca o começo das categorias que não são comida.

  > "Ver a nota sobre os ids 14/16 duplicados em utils/category_images.dart. As duas recebem a mesma cor de propósito: enquanto forem a mesma categoria na prática, ficar com cores diferentes só confundiria quem filtra."
  - 💡 Explicação Leiga: A linha dá a mesma cor a duas categorias repetidas no banco de dados.

### 📂 ARQUIVO: lib/core/ui/theme/map_food_colors.dart

- ⚙️ Função: Define as cores que mudam entre o tema claro e o tema escuro.
- 💬 Comentários Removidos:

  > "Tokens de superfície, conteúdo e traço — tudo que precisa mudar entre claro e escuro e não tem equivalente direto no `ColorScheme` do Material. Lidos via `context.mapColors` (ver [MapFoodColorsX] no fim do arquivo). Cor de marca e de significado (vermelho, preto da marca, estrela, sucesso) não entram aqui: valem o mesmo nos dois temas e vivem em [MfColor]. A escala de neutros (v2): Antes, no tema claro, `mainBackground` e `cardSurface` eram os dois branco puro — um card não se distinguia do fundo, e a única separação possível virava borda cinza em tudo. Agora são três degraus, que é o que permite hierarquia sem desenhar linha: [background] — o papel da tela; [surface] — o que está sobre o papel (card, sheet, app bar); [surfaceAlt] — o que está 'afundado' no papel (input, chip, skeleton). Os neutros são cinzas de viés levemente azul, conversando com o `#12172A` da marca. Nada de cinza tingido de vermelho, como no `--border: 348 40% 85%` da web: borda colorida satura a tela e rouba atenção do conteúdo."
  - 💡 Explicação Leiga: Esta classe guarda as cores de fundo, texto e borda de cada tema. Ela tem três tons de cinza para separar os blocos sem precisar de linhas.

  > "Fundo da tela."
  - 💡 Explicação Leiga: A linha define a cor de fundo geral da tela.

  > "Superfície elevada sobre [background]: card, bottom sheet, app bar."
  - 💡 Explicação Leiga: A linha define a cor dos cartões e painéis.

  > "Superfície rebaixada: campo de formulário, chip inativo, skeleton de carregamento. Um degrau de contraste em relação a [surface]."
  - 💡 Explicação Leiga: A linha define a cor dos campos de digitar e das etiquetas apagadas.

  > "Scrim de modal/bottom sheet."
  - 💡 Explicação Leiga: A linha define o véu escuro que aparece atrás dos painéis.

  > "Placeholder, texto desabilitado, chevron de item de lista."
  - 💡 Explicação Leiga: A linha define o cinza mais claro de texto, usado em dicas e setas.

  > "Traço decorativo de 1px: contorno de card, de sheet, de botão flutuante — casos em que o elemento já se identifica pela superfície e a borda só arremata a forma. Não atinge 3:1 de propósito (1,18:1 no claro): elevá-la a esse nível pintaria de cinza-médio o contorno de todo card do app. Quando a borda é a única coisa que delimita um controle — campo de formulário, chip inativo, botão outline —, use [borderStrong]: aí ela carrega informação e o 3:1 do WCAG 1.4.11 passa a valer."
  - 💡 Explicação Leiga: A linha define a borda fina e discreta dos cartões. Ela serve só para arrematar a forma.

  > "Traço funcional: o contorno que identifica um controle. Cumpre 3:1 contra as superfícies em que o app o desenha."
  - 💡 Explicação Leiga: A linha define a borda mais escura, usada quando ela é a única marca do controle.

  > "Linha entre itens de uma lista — mais fraca que [border] de propósito."
  - 💡 Explicação Leiga: A linha define a cor das linhas divisórias entre itens.

  > "Fundo do estado selecionado de um controle neutro: segmento ativo, chip escolhido, CTA de alto contraste. Inverte entre os temas, e é por isso que existe como token. No claro é o `#12172A` da marca; no escuro esse mesmo tom fica a um passo do fundo (`#0E0F12`) e o controle 'selecionado' some — lê como um azul apagado em vez de um estado ativo. No escuro, portanto, o selecionado é claro, espelhando o mesmo contraste."
  - 💡 Explicação Leiga: A linha define o fundo do item selecionado. Ele é escuro no tema claro e claro no tema escuro.

  > "Conteúdo sobre [selectedSurface]."
  - 💡 Explicação Leiga: A linha define a cor do texto que fica sobre o item selecionado.

  > "Vermelho da marca como texto ou ícone sobre uma superfície do tema. Existe porque `MfColor.brand` (`#D6011B`) rende só 3,28:1 sobre a superfície escura — reprova para texto. No claro é a cor de marca intacta; no escuro, uma versão clareada que preserva o matiz e alcança 4,5:1. Continue usando `MfColor.brand` quando o vermelho for fundo (CTA primário, badge): ali o par a medir é branco-sobre-vermelho, que já passa."
  - 💡 Explicação Leiga: A linha define o vermelho usado para escrever texto. No tema escuro ele é mais claro, para continuar legível.

  > "Verde de sucesso como texto/ícone. Mesmo motivo de [brandContent]: o `MfColor.success` rende 3,37:1 sobre o branco e reprova no tema claro."
  - 💡 Explicação Leiga: A linha define o verde usado em texto. Ele é mais escuro que o verde de fundo.

  > "compatibilidade com os nomes antigos — O app tem ~360 leituras de `context.mapColors`. Trocar os valores por dentro e manter os nomes antigos como apelidos deixa a fundação nova entrar de uma vez, sem um mutirão de renomeação que não muda nada de visual. Estes getters saem quando a migração dos lotes terminar."
  - 💡 Explicação Leiga: Este grupo mantém os nomes de cor antigos funcionando. Eles agora devolvem as cores novas.

  > "No sistema novo o ícone acompanha a cor do texto ao lado; ícone neutro é, por definição, [textSecondary]."
  - 💡 Explicação Leiga: A linha faz o nome antigo de cor de ícone apontar para a cor do texto de apoio.

  > "contraste — Os valores de texto abaixo foram medidos contra a superfície mais clara em que o app os desenha (`surfaceAlt`, #F3F4F5) — não contra o branco. Medir contra o branco aprovaria tons que reprovam dentro de um campo ou de um chip, que é justamente onde o texto fraco mais aparece."
  - 💡 Explicação Leiga: Este grupo explica como o contraste das cores foi medido. A medição usou o fundo cinza claro, não o branco.

  > "`--branco-background: #F3F4F5` da web, reaproveitado como superfície rebaixada em vez de fundo de tela."
  - 💡 Explicação Leiga: A linha usa um cinza vindo da versão web do produto como fundo de campo.

  > "ink @ 40%"
  - 💡 Explicação Leiga: A linha define o véu escuro como o preto da marca a 40% de opacidade.

  > "17,8:1"
  - 💡 Explicação Leiga: Anota que o texto principal tem contraste de 17,8 para 1 com o fundo.

  > "Era #6B7280 (4,39:1 sobre surfaceAlt — reprovava por pouco). Escurecido além do mínimo de propósito: com o terciário subindo para 4,5:1, um secundário no limite ficaria indistinguível dele e a hierarquia de texto do app viraria um tom só."
  - 💡 Explicação Leiga: A linha usa um cinza mais escuro no texto de apoio. Isso o mantém diferente do cinza mais claro.

  > "7,0:1"
  - 💡 Explicação Leiga: Anota que o texto de apoio tem contraste de 7 para 1.

  > "Era #9CA3AF — 2,54:1, o pior par da escala. É a cor do placeholder ('Buscar comércios...'), que é conteúdo, não decoração."
  - 💡 Explicação Leiga: A linha escurece o cinza da dica dentro dos campos. O tom anterior era ilegível.

  > "4,5:1"
  - 💡 Explicação Leiga: Anota que o cinza mais claro tem contraste de 4,5 para 1.

  > "3,1:1"
  - 💡 Explicação Leiga: Anota que a borda forte tem contraste de 3,1 para 1.

  > "5,4:1 — a marca passa intacta no claro"
  - 💡 Explicação Leiga: Anota que o vermelho da marca é legível no tema claro sem ajuste.

  > "era #12A150 (3,37:1)"
  - 💡 Explicação Leiga: Anota o verde anterior, que não tinha contraste suficiente.

  > "Viés azul sutil (em vez do #121212/#1E1E1E, que é o cinza padrão do Material): puxa pro mesmo lado do #12172A da marca e lê como escolha, não como default de framework."
  - 💡 Explicação Leiga: A linha define o fundo do tema escuro com um tom levemente azulado.

  > "preto @ 56%"
  - 💡 Explicação Leiga: A linha define o véu do tema escuro como preto a 56% de opacidade.

  > "16,4:1"
  - 💡 Explicação Leiga: Anota o contraste do texto principal no tema escuro.

  > "6,8:1 — já passava, mantido"
  - 💡 Explicação Leiga: Anota que o cinza de apoio no tema escuro já era legível.

  > "Era #6B7280 (3,37:1 sobre surfaceAlt). No escuro o ajuste é clarear."
  - 💡 Explicação Leiga: A linha clareia o cinza mais fraco no tema escuro.

  > "`MfColor.brand` puro rende 3,28:1 sobre `surface` — reprova para texto. Clareado o suficiente para 4,5:1 mantendo o matiz da marca."
  - 💡 Explicação Leiga: A linha define um vermelho mais claro para texto no tema escuro.

  > "5,3:1 — o verde passa intacto no escuro"
  - 💡 Explicação Leiga: Anota que o verde normal já é legível no tema escuro.

  > "Syntax sugar para não repetir `Theme.of(context).extension<MapFoodColors>()!` em toda view. O `!` é seguro aqui porque [MapFoodColors] é sempre registrada em `AppTheme.light` e `AppTheme.dark` — ver app_theme.dart."
  - 💡 Explicação Leiga: Este bloco cria o atalho `context.mapColors`. Ele evita escrever um comando longo em cada tela.

### 📂 ARQUIVO: lib/core/ui/theme/map_tiles.dart

- ⚙️ Função: Define de onde vêm as imagens do mapa e o crédito obrigatório do fornecedor.
- 💬 Comentários Removidos:

  > "A cartografia do app. Sempre clara, nos dois temas. Já houve aqui um filtro de cor (`invert(1) hue-rotate(180deg)`) que escurecia os tiles do OpenStreetMap junto com o tema do sistema. Ele saiu por decisão de produto: o mapa é a tela principal do app e sua legibilidade não deve variar com a preferência de tema do aparelho. A escolha tem custo e ele é conhecido: no tema escuro o mapa é uma superfície clara ocupando a tela inteira. Em troca, tudo que é desenhado sobre a cartografia — os pins vermelhos de marca, a rota, o ponto azul do usuário — tem um único fundo previsível para contrastar, em vez de dois. A bottom bar, os controles de câmera e o véu do topo continuam seguindo o tema normalmente: só os tiles ficam de fora."
  - 💡 Explicação Leiga: Esta classe mantém o mapa sempre claro, mesmo no tema escuro. Assim os pontos vermelhos sempre têm o mesmo fundo.

  > "Sem `{s}`: o OSM pede explicitamente que não se distribua por subdomínio (ver o aviso do próprio flutter_map)."
  - 💡 Explicação Leiga: A linha segue a regra do fornecedor do mapa sobre como buscar as imagens.

  > "Crédito obrigatório da cartografia em uso."
  - 💡 Explicação Leiga: A função devolve o texto de crédito que precisa aparecer no mapa por exigência legal.

### 📂 ARQUIVO: lib/core/ui/theme/theme_controller.dart

- ⚙️ Função: Guarda e salva a escolha de tema claro, escuro ou automático.
- 💬 Comentários Removidos:

  > "Fonte única de verdade do [ThemeMode] do app. É um [ValueNotifier] (não um [ChangeNotifier] com campos soltos) porque o único estado que existe aqui é o próprio ThemeMode — isso permite plugar direto em [ValueListenableBuilder]/[ListenableBuilder] sem precisar de um model extra. Toda a lógica de leitura/gravação em disco (SharedPreferences) fica encapsulada aqui, longe das telas: a UI só lê [value] e chama [setThemeMode]."
  - 💡 Explicação Leiga: Esta classe guarda qual tema está ativo. Ela também sabe salvar e ler essa escolha no disco.

  > "Instância única do controller, acessível globalmente sem InheritedWidget/Provider — o app inteiro (main.dart, telas de configurações, etc.) escuta o mesmo [ValueNotifier]. Só é populada de verdade depois de [load] ser aguardado no `main()`. Acessar antes disso é erro de uso: falha em debug (assert) e, em release, cai num fallback `ThemeMode.system` em vez de derrubar o app."
  - 💡 Explicação Leiga: A linha dá acesso ao controlador de tema de qualquer lugar do app. Se ele for usado antes da hora, o app usa o tema do sistema.

  > "Lê a preferência salva (se existir) e cria a instância singleton. Deve ser chamado uma única vez, com `await`, ANTES do `runApp` — é o que garante que o primeiro frame já nasce no tema certo, sem FOUC (claro piscando antes de trocar pra escuro, ou vice-versa)."
  - 💡 Explicação Leiga: A função lê do disco o tema salvo. Ela roda antes da primeira tela aparecer.

  > "Troca o tema e persiste a escolha. Idempotente: repetir o modo atual não gera notificação nem escrita em disco à toa."
  - 💡 Explicação Leiga: A função troca o tema e salva a escolha. Escolher o tema que já está ativo não faz nada.

  > "ValueNotifier.value= já dispara notifyListeners()."
  - 💡 Explicação Leiga: A linha muda o valor guardado, o que avisa todas as telas automaticamente.

---

## 🧰 PARTE 4 — AS FERRAMENTAS AUXILIARES

### 📂 ARQUIVO: lib/core/ui/utils/async_load_mixin.dart

- ⚙️ Função: Bloco pronto que qualquer tela usa para carregar dados e mostrar erro ou espera.
- 💬 Comentários Removidos:

  > "Estado imutável de uma operação assíncrona de tela: carregando, com erro, ou com dado carregado. `data` pode conviver com um carregamento em segundo plano (`load` chamado de novo pra dar refresh) — nesse caso `isLoading` é true e `data` ainda é o valor da carga anterior, útil pra telas que preferem não esconder o conteúdo já visível atrás de um spinner."
  - 💡 Explicação Leiga: Esta classe guarda três informações: se está carregando, se deu erro e qual é o dado. O dado antigo continua visível durante uma nova busca.

  > "Generaliza o padrão `_isLoading`/`_errorMessage`/try-catch-setState reimplementado do zero em várias telas do app (ver auditoria de arquitetura: search_page.dart, merchant_home_page.dart, consumer_complaints_page.dart, consumer_review_page.dart, merchant_register_page.dart, login_page.dart, consumer_register_page.dart — todas convergiram organicamente pro mesmo trio de campos). Preserva o tratamento diferenciado de [AppException] (mensagem vinda da API) vs. erro genérico, que hoje varia de tela pra tela. Não cobre orquestrações com múltiplas fontes de dado ou efeitos colaterais no meio do carregamento (ex: navegação condicional) — nesses casos, usar [load] só pro recurso principal da tela e tratar o resto à parte, como em `MerchantHomePage`."
  - 💡 Explicação Leiga: Este bloco reúne o código de carregamento que sete telas repetiam. Agora todas usam a mesma versão.

  > "Mensagem padrão quando o erro não é um [AppException] (falha de rede, parse, etc.) — sobrescreva por tela quando o texto genérico não servir."
  - 💡 Explicação Leiga: A linha define a frase de erro padrão. Cada tela pode trocar essa frase.

  > "Executa [fetch] e atualiza [asyncState]. Chamar de novo (ex: botão 'Tentar novamente') recarrega — por padrão mantém o `data` anterior visível enquanto a nova busca está em voo; passe `keepDataOnReload: false` pra esconder o conteúdo velho atrás do loading a cada chamada. [onData], se informado, roda com o resultado assim que [fetch] resolve — antes de `asyncState` ser atualizado. Devolva `false` pra pular a atualização de `asyncState` (ex: quando o callback já navegou pra outra tela por causa do resultado — como uma lista vazia — e não faz sentido deixar esta tela renderizar esse dado por um frame antes de sair). Sem [onData], o padrão é sempre `true` (commit normal)."
  - 💡 Explicação Leiga: A função busca os dados e atualiza a tela. Ela permite reagir ao resultado antes de a tela ser redesenhada.

### 📂 ARQUIVO: lib/core/ui/utils/category_icons.dart

- ⚙️ Função: Associa um ícone a cada categoria de loja.
- 💬 Comentários Removidos:

  > "Ícone representativo de cada categoria de loja — mapeamento por nome porque a API não tem campo de ícone pra categoria. Compartilhado entre os filtros de categoria da Search Page e os badges de categoria dos cards de loja. Sem entrada aqui, cai no ícone padrão. As chaves espelham a coluna `nome` da tabela `categoria`, igual a `utils/category_images.dart` e `theme/category_colors.dart` — os três mapas precisam ser atualizados juntos quando o banco ganha uma categoria."
  - 💡 Explicação Leiga: Esta lista liga o nome de cada categoria a um ícone. Existem três listas parecidas que precisam ser atualizadas juntas.

  > "id 1..12 — comida"
  - 💡 Explicação Leiga: Marca o começo das categorias de comida.

  > "id 13..18 — não-comida"
  - 💡 Explicação Leiga: Marca o começo das categorias que não são comida.

  > "Ver a nota sobre os ids 14/16 duplicados em utils/category_images.dart."
  - 💡 Explicação Leiga: Aponta que duas categorias do banco de dados são a mesma coisa escrita de dois jeitos.

### 📂 ARQUIVO: lib/core/ui/utils/category_images.dart

- ⚙️ Função: Associa um desenho colorido a cada categoria de loja.
- 💬 Comentários Removidos:

  > "Arte 3D de cada categoria de loja — mapeamento por nome, na mesma linha de `core/ui/utils/category_icons.dart` (a API não tem campo de imagem pra categoria). Quem não tem entrada aqui devolve `null` e cai no ícone da paleta — nunca num placeholder quebrado ou num quadrado vazio. Todas as artes são PNG 1024×1024 com fundo transparente e bastante margem no canvas (o objeto ocupa pouco mais da metade da largura), então elas precisam ser desenhadas maiores que o ícone que substituem para ter o mesmo peso visual dentro do círculo colorido. As chaves espelham exatamente a coluna `nome` da tabela `categoria` — o casamento é por string, então qualquer divergência de acento ou espaço faz a categoria cair no ícone de fallback silenciosamente."
  - 💡 Explicação Leiga: Esta lista liga o nome de cada categoria a um arquivo de imagem. Um acento errado no nome faz a imagem sumir sem aviso.

  > "id 1..12 — comida"
  - 💡 Explicação Leiga: Marca o começo das categorias de comida.

  > "id 13..18 — não-comida"
  - 💡 Explicação Leiga: Marca o começo das categorias que não são comida.

  > "ATENÇÃO: os ids 14 e 16 são a mesma coisa cadastrada duas vezes no banco ('Vestuario e Acessórios', sem acento, e 'Vestuário'). Enquanto as duas linhas existirem, ambas precisam de entrada aqui — senão uma das duas aparece sem arte, e qual delas depende de qual o comerciante escolheu."
  - 💡 Explicação Leiga: A linha cobre uma categoria cadastrada duas vezes no banco de dados. As duas versões precisam de imagem.

  > "Caminho da arte da categoria, ou `null` quando ela ainda não tem uma."
  - 💡 Explicação Leiga: A função devolve o endereço da imagem da categoria. Se não houver imagem, devolve vazio.

### 📂 ARQUIVO: lib/core/ui/utils/rating_format.dart

- ⚙️ Função: Transforma a nota da loja em texto para aparecer na tela.
- 💬 Comentários Removidos:

  > "Nota média para exibição. `null` e `0` são loja sem avaliação — zero é uma nota ruim, ausência de nota não é. Separador decimal em vírgula, como o `RatingScorePill` já fazia: a mesma nota aparecia como '4.5' no card da busca e '4,5' no selo da loja."
  - 💡 Explicação Leiga: A função escreve a nota com vírgula, como "4,5". Uma loja sem avaliação não aparece com nota zero.

### 📂 ARQUIVO: lib/core/ui/utils/text_scale.dart

- ⚙️ Função: Faz ícones e caixas crescerem junto quando o usuário aumenta a letra do celular.
- 💬 Comentários Removidos:

  > "Ferramentas para o app acompanhar o tamanho de fonte escolhido no sistema (Dynamic Type no iOS, 'Tamanho da fonte' no Android). O problema que elas resolvem: O Flutter escala texto sozinho, e mais nada. Três consequências, que são exatamente as três formas de um layout quebrar em escala alta: 1. `Icon(size: 20)` continua com 20 logo ao lado de um texto que dobrou — o ícone parece ter encolhido. Use [escalaIcone]. 2. Uma caixa de altura fixa (`height: 52`) não cresce junto com o texto que ela contém, e o texto vaza. A correção é `minHeight`. 3. Alguns lugares não podem crescer — uma faixa horizontal de chips sobre o mapa, a bottom bar. Para esses, [MaxTextScale] limita a escala só ali dentro, em vez de limitar o app inteiro. O ponto do item 3 é esse: o app hoje trava a escala em 1,5× globalmente (`main.dart`), o que impede quem precisa de 2× de chegar lá em qualquer tela. Trocar esse teto global por tetos locais nos poucos pontos que realmente não esticam é o que permite liberar o resto."
  - 💡 Explicação Leiga: Este arquivo reúne funções que fazem ícones e caixas crescerem junto com a letra. Sem elas, o texto grande vaza para fora dos blocos.

  > "Fator de escala de texto atualmente em vigor."
  - 💡 Explicação Leiga: A função devolve quantas vezes a letra está maior que o normal.

  > "Escala [base] junto com o texto, sem passar de `base * teto`. Serve para qualquer dimensão que precise acompanhar o texto sem poder crescer indefinidamente — altura de faixa horizontal, diâmetro de círculo de ilustração, lado de um cartão numa lista horizontal."
  - 💡 Explicação Leiga: A função aumenta um tamanho junto com a letra, mas com um limite.

  > "Tamanho de ícone que acompanha a escala do texto, com teto. O teto existe porque ícone não é texto: dobrar um ícone de 24 numa linha com ícone + rótulo + caret come a largura que o rótulo precisa, e o resultado é pior do que o ícone ficar um pouco menor que o texto. 1,6× é o ponto em que o ícone ainda acompanha visualmente sem dominar a linha. Use apenas em ícones que acompanham texto. Ícone solto dentro de um botão circular (controles do mapa, bottom bar) não deve escalar: ele não tem texto ao lado para acompanhar, e crescer só quebraria o círculo."
  - 💡 Explicação Leiga: A função aumenta o ícone junto com a letra, até no máximo 1,6 vezes. Ícones sozinhos dentro de botões redondos não devem usar isso.

  > "Número de linhas para um rótulo curto que hoje cabe em uma. Em escala alta, manter `maxLines: 1` só troca o vazamento por um '…' — a informação some do mesmo jeito. Soltar uma segunda linha preserva o rótulo, e a caixa acompanha porque passou a usar `minHeight`."
  - 💡 Explicação Leiga: A função libera uma segunda linha de texto quando a letra está grande. Assim a palavra não é cortada.

  > "Limita a escala de texto dentro desta subárvore. Para superfícies que genuinamente não podem crescer: faixas horizontais de altura fixa, barras de navegação, sobreposições ancoradas ao mapa. É o substituto cirúrgico do teto global — em vez de negar 2× ao app inteiro, nega só onde crescer quebraria de verdade. Não use para fugir de um layout que dá para consertar. Todo uso deste widget é uma dívida assumida, e merece um comentário dizendo por quê."
  - 💡 Explicação Leiga: Este componente limita o tamanho da letra apenas dentro de um pedaço da tela. Ele é usado só onde crescer quebraria o desenho.

### 📂 ARQUIVO: lib/core/ui/utils/ui_utils.dart

- ⚙️ Função: Atalho para mostrar uma mensagem de erro na tela.
- 💬 Comentários Removidos:

  > "Mostra um erro como pop-up (ver [AppToast]) em vez de um dialog modal — mantido com esse nome para não precisar tocar em cada call site."
  - 💡 Explicação Leiga: A função mostra o erro como um aviso que some sozinho. O nome antigo foi mantido para não mexer em todas as telas.

### 📂 ARQUIVO: lib/core/ui/validators/form_validator.dart

- ⚙️ Função: Confere se e-mail, senha, CPF e outros campos foram preenchidos corretamente.
- 💬 Comentários Removidos:

  > "0 até 4"
  - 💡 Explicação Leiga: A linha devolve a força da senha como um número de zero a quatro.

---

## 🧩 PARTE 5 — AS PEÇAS VISUAIS COMPARTILHADAS

Estas peças são usadas por várias telas ao mesmo tempo.
Mudar uma delas muda todas as telas que a usam.

### 📂 ARQUIVO: lib/core/ui/widgets/app_bottom_bar.dart

- ⚙️ Função: Desenha a barra de ícones flutuante no rodapé, usada para trocar de aba.
- 💬 Comentários Removidos:

  > "Nome da aba para o leitor de tela. Obrigatório: os itens são icon-only, então sem ele a navegação principal do app é anunciada como um punhado de botões sem nome — e era exatamente esse o estado antes."
  - 💡 Explicação Leiga: A linha guarda o nome falado de cada aba. O nome não aparece na tela, só é lido em voz alta.

  > "Bottom bar flutuante em glass, compartilhada entre guest/consumer/merchant — só a lista de ícones muda entre os três papéis. A cápsula descolada da borda é o que deixa o mapa (a tela principal do app) respirar por baixo dela: uma faixa opaca de ponta a ponta comeria uma tira inteira da cartografia. No claro ela é vidro fosco sobre o que passa embaixo; no escuro, superfície sólida — branco translúcido sobre fundo escuro não lê. Icon-only. O rótulo existe só para o leitor de tela: desenhá-lo sob cada ícone (como já se tentou) engorda a cápsula e o texto nasce pequeno demais para compensar o que rouba do mapa. Por isso o indicador que desliza por trás do item selecionado é um círculo, e não uma pílula."
  - 💡 Explicação Leiga: Esta classe desenha a barra de navegação do rodapé. Ela é a mesma para visitante, consumidor e comerciante, mudando só os ícones.

  > "Área de toque de cada item (56x56, padrão ergonômico Material/Apple) e diâmetro do indicador de seleção que desliza por trás dos ícones."
  - 💡 Explicação Leiga: A linha define que cada ícone tem 56 pontos de área tocável. Esse é o tamanho mínimo confortável para o dedo.

  > "Padding vertical interno da cápsula (vale nos dois temas: `GlassContainer` no claro, container sólido no escuro) e margem entre a barra e a borda inferior da tela."
  - 💡 Explicação Leiga: A linha define o espaço interno e a distância da barra até a borda da tela.

  > "Espaço que a barra ocupa no rodapé, da borda da tela ao topo da cápsula. 56 do item + 16 de padding + 32 de margem + 4 de folga para a borda de 1px e a sombra."
  - 💡 Explicação Leiga: A linha soma a altura total que a barra ocupa. Esse número é 108 pontos.

  > "[reservedSpace] mais a área segura do aparelho. Quem desenha conteúdo por baixo da barra (o mapa da home, as listas do comerciante) reserva isto no rodapé, em vez de repetir um número mágico por arquivo — era assim que a barra acabava cobrindo conteúdo: cada tela chutava a própria folga. A cápsula em si não desce com a área segura (os 32 de margem já a mantêm acima da barra de gestos); a folga extra entra só aqui, do lado de quem reserva espaço, onde sobrar é inofensivo e faltar não é."
  - 💡 Explicação Leiga: A função devolve quanto espaço as telas devem deixar livre no rodapé. Antes cada tela chutava esse valor e a barra cobria o conteúdo.

  > "Indicador claro (cardSurface) + ícone vermelho de marca."
  - 💡 Explicação Leiga: A linha desenha a barra no tema claro, com o círculo de seleção claro.

  > "Tema escuro: sem o vidro fosco (branco translúcido não lê bem sobre fundo escuro) — superfície sólida, distinta do fundo do app (`cardSurface` já é o tom 'elevado' do tema escuro)."
  - 💡 Explicação Leiga: A função desenha a barra no tema escuro com fundo sólido, sem efeito de vidro.

  > "Indicador claro sobre a barra escura — mesmo alto contraste do lado claro, espelhado."
  - 💡 Explicação Leiga: A linha usa um círculo branco no tema escuro para marcar a aba ativa.

  > "Indicador único que desliza de um ícone pro outro — em vez de cada item ligar/desligar seu próprio fundo, só um deles se move, o que lê como transição contínua ao trocar de aba."
  - 💡 Explicação Leiga: A linha faz um único círculo escorregar até a aba escolhida. O movimento mostra que a aba mudou.

  > "O indicador que desliza por trás do ícone já responde ao toque; encolher o item junto brigaria com essa animação."
  - 💡 Explicação Leiga: A linha desliga o efeito de encolher no toque, para não atrapalhar o círculo que desliza.

  > "Claro: vermelho de marca sobre o indicador claro. Escuro: cinza escuro sobre o indicador branco."
  - 💡 Explicação Leiga: A linha escolhe a cor do ícone ativo em cada tema.

### 📂 ARQUIVO: lib/core/ui/widgets/app_button.dart

- ⚙️ Função: É o único botão do aplicativo; todas as telas usam este componente.
- 💬 Comentários Removidos:

  > "Papel do botão na hierarquia da tela — não é 'cor', é intenção. Uma tela tem no máximo um [primary]. Se duas ações disputam o mesmo destaque, nenhuma se destaca."
  - 💡 Explicação Leiga: Esta lista define os tipos de botão pela importância. Cada tela só pode ter um botão principal.

  > "Ação principal. Fundo de marca."
  - 💡 Explicação Leiga: A linha define o botão principal, com fundo vermelho.

  > "Ação alternativa de mesmo peso funcional (ex: 'Cancelar' ao lado de 'Salvar'). Superfície neutra."
  - 💡 Explicação Leiga: A linha define o botão secundário, com fundo cinza.

  > "Ação terciária, ainda com forma de botão (ex: 'Denunciar')."
  - 💡 Explicação Leiga: A linha define o botão só com contorno, sem fundo.

  > "Ação de texto, sem caixa (ex: 'ver tudo', 'pular')."
  - 💡 Explicação Leiga: A linha define o botão que parece apenas um texto clicável.

  > "Ação destrutiva (ex: 'Excluir conta')."
  - 💡 Explicação Leiga: A linha define o botão vermelho de apagar.

  > "CTA neutro forte: preto sólido da marca. É o 'Sair da conta' e o 'Começar' sobre fundo claro, onde o vermelho seria agressivo demais."
  - 💡 Explicação Leiga: A linha define o botão preto, usado quando o vermelho seria forte demais.

  > "Botão sobre uma superfície de marca (card preto ou vermelho sólido): branco sólido com texto escuro. Não muda com o tema — a superfície que o contém também não muda."
  - 💡 Explicação Leiga: A linha define o botão branco, usado em cima de blocos coloridos.

  > "44px — dentro de card, ao lado de outro botão, em barra de ação."
  - 💡 Explicação Leiga: A linha define a altura mínima do botão pequeno.

  > "52px — CTA de tela e de formulário."
  - 💡 Explicação Leiga: A linha define a altura mínima do botão grande.

  > "Botão único do app. Decisões que valem para todas as variantes: `elevation: 0` sempre. Profundidade no sistema vem de superfície e sombra de container; botão levantado é vocabulário de Material 2. Estado pressionado é um véu, não outra cor. Trocar a cor de fundo no toque faz o botão 'piscar'; um overlay preserva a identidade. Desabilitado é superfície apagada, não opacidade no widget inteiro — baixar a opacidade apaga a borda junto e deixa o botão fantasma. Carregando preserva a largura: o rótulo some, o botão não pula. A altura é mínima, não fixa. Com a fonte do sistema em 2×, um `height: 52` cravado corta o rótulo pela metade. Aqui 52 é o piso: o botão cresce com o texto, e o alvo de toque nunca fica menor que o mínimo — só maior, o que não é problema."
  - 💡 Explicação Leiga: Esta classe desenha todos os botões do app. O botão cresce quando o texto cresce, em vez de cortar a palavra.

  > "`null` desabilita o botão (mesma convenção do Flutter)."
  - 💡 Explicação Leiga: A linha desativa o botão quando nenhuma ação é informada.

  > "Ícone à esquerda do rótulo. Use quando o ícone acrescenta informação ('Ver rota' + seta de navegação), não como decoração."
  - 💡 Explicação Leiga: A linha permite colocar um ícone antes do texto do botão.

  > "Troca o rótulo por um spinner e bloqueia o toque."
  - 💡 Explicação Leiga: A linha mostra um círculo girando no lugar do texto enquanto a ação acontece.

  > "`true` (padrão) ocupa a largura disponível — o certo para CTA de tela e de formulário. `false` encolhe até o conteúdo, para botão em linha."
  - 💡 Explicação Leiga: A linha decide se o botão ocupa toda a largura ou apenas o tamanho do texto.

  > "Piso de altura (ver nota na descrição da classe), não altura fixa."
  - 💡 Explicação Leiga: A linha define a altura mínima do botão, permitindo que ele cresça.

  > "O ícone acompanha o texto: parado no tamanho original, ele viraria um detalhe minúsculo ao lado de um rótulo que dobrou."
  - 💡 Explicação Leiga: A linha faz o ícone do botão crescer junto com o texto.

  > "Primário: o vermelho aqui é fundo, e o par branco-sobre-vermelho rende 5,4:1 — passa. Por isso segue `MfColor.brand` puro, e não `brandContent`, que é a variante para vermelho como texto/ícone."
  - 💡 Explicação Leiga: A linha usa o vermelho normal como fundo do botão principal. O texto branco por cima é legível.

  > "Sem fundo próprio, a borda é o que identifica o botão → `borderStrong`."
  - 💡 Explicação Leiga: A linha dá uma borda mais escura ao botão sem fundo.

  > "Ghost é vermelho como texto sobre a superfície da tela: no escuro o vermelho puro rende 3,28:1 e reprova."
  - 💡 Explicação Leiga: A linha usa o vermelho clareado no botão de texto, para ele ser legível no tema escuro.

  > "Mesma correção do ghost: texto vermelho sobre superfície suave."
  - 💡 Explicação Leiga: A linha usa o vermelho clareado no botão de apagar.

  > "No tema escuro o 'preto sólido' some no fundo: `selectedSurface` inverte para uma superfície clara com texto escuro, mantendo o mesmo contraste alto. É o mesmo par usado por chip e segmento ativos."
  - 💡 Explicação Leiga: A linha inverte o botão preto para branco no tema escuro.

  > "Véu do toque: claro sobre fundo escuro, escuro sobre fundo claro."
  - 💡 Explicação Leiga: A linha escolhe a cor da camada que aparece enquanto o dedo pressiona o botão.

  > "`minHeight` no lugar de `height`: o botão parte de 52/44 e cresce se o rótulo precisar de mais. Com `height` fixo, o `Row` interno recebia uma altura menor que a do texto e vazava por cima da borda."
  - 💡 Explicação Leiga: A linha define altura mínima em vez de altura fixa. Assim o texto grande não vaza para fora do botão.

  > "Sem teto: o padrão do FilledButton limita a altura e reintroduziria o corte que o `minHeight` acabou de resolver."
  - 💡 Explicação Leiga: A linha remove o limite de altura do botão.

  > "Sem tap target extra: a altura já cumpre o mínimo de 44/48px."
  - 💡 Explicação Leiga: A linha remove um espaço invisível extra em volta do botão, porque ele já é grande o bastante.

  > "O spinner acompanha a escala junto com o rótulo que ele substitui — senão o botão encolhe de volta ao entrar em carga."
  - 💡 Explicação Leiga: A linha faz o círculo de carregamento ter o mesmo tamanho do texto que ele substitui.

  > "Em escala alta, insistir em uma linha só troca o vazamento por '…' — o rótulo some do mesmo jeito. Soltando a segunda linha, o texto sobrevive e a caixa acompanha porque a altura virou mínima."
  - 💡 Explicação Leiga: A linha permite que o texto do botão use duas linhas quando a letra está grande.

  > "AppText.button não carrega cor — quem resolve é o foregroundColor acima, que também trata o disabled."
  - 💡 Explicação Leiga: A linha aplica o estilo de texto do botão. A cor é definida em outro lugar.

### 📂 ARQUIVO: lib/core/ui/widgets/app_card.dart

- ⚙️ Função: É a caixa padrão que envolve blocos de conteúdo em todas as telas.
- 💬 Comentários Removidos:

  > "Quanto o card 'sobe' da página."
  - 💡 Explicação Leiga: Esta lista define os três níveis de sombra de um cartão.

  > "Bloco dentro de uma tela que já rola: sem sombra, superfície rebaixada. Serve para agrupar conteúdo sem parecer um objeto solto."
  - 💡 Explicação Leiga: A linha define o cartão sem sombra, usado para agrupar conteúdo.

  > "Card em lista/grade. Sombra nível 1."
  - 💡 Explicação Leiga: A linha define o cartão com sombra leve.

  > "O que flutua sobre outro conteúdo — barra sobre o mapa, sheet, painel de filtro. Sombra nível 2."
  - 💡 Explicação Leiga: A linha define o cartão com sombra média, usado sobre o mapa.

  > "Container padrão de conteúdo do app. Três coisas que este widget resolve e que costumavam ser refeitas (com valores diferentes) em cada tela: 1. Superfície certa por elevação — `flat` usa `surfaceAlt`, as outras usam `surface`. É o degrau da escala de neutros que dá hierarquia sem precisar desenhar linha em tudo. 2. Sombra por token, nunca `BoxShadow` improvisado, e desligada no tema escuro na variante `raised`: sobre fundo escuro a sombra não lê, a separação vem do contraste entre `surface` e `background`. 3. Ripple contido no raio — `InkWell` sem `borderRadius` casado com o container espirra tinta para fora do canto arredondado."
  - 💡 Explicação Leiga: Esta classe desenha a caixa padrão do app. Ela resolve cor de fundo, sombra e efeito de toque de uma vez.

  > "`null` deixa o card não clicável (sem ripple, sem área de toque)."
  - 💡 Explicação Leiga: A linha torna o cartão não clicável quando nenhuma ação é informada.

  > "Traço de 1px. Ligado por padrão no claro (onde a sombra é sutil demais para definir sozinha o limite do card)."
  - 💡 Explicação Leiga: A linha desenha uma borda fina em volta do cartão.

  > "Sobrescreve a cor de fundo — para casos legítimos como card sobre foto."
  - 💡 Explicação Leiga: A linha permite trocar a cor de fundo do cartão em casos especiais.

  > "O clip fica no Material, não no DecoratedBox: recortar o container externo cortaria a própria sombra junto."
  - 💡 Explicação Leiga: A linha recorta o conteúdo do cartão nos cantos arredondados, sem cortar a sombra.

### 📂 ARQUIVO: lib/core/ui/widgets/app_choice_chip.dart

- ⚙️ Função: Desenha as etiquetas de filtro que podem ser ligadas e desligadas.
- 💬 Comentários Removidos:

  > "Chip de escolha em pílula — filtro de categoria, período, distância. Por que existe: O app tinha três cópias deste chip (home, filtros e perfil), e as três sinalizavam seleção apenas por cor de fundo. Isso reprova no WCAG 1.4.1 (Use of Color): quem não distingue o par de cores não tem como saber qual filtro está ativo. É o mesmo problema que o iOS ataca com Differentiate Without Color e Button Shapes. A correção é o ✓ que aparece ao selecionar: um segundo canal, de forma, que não depende de enxergar cor nenhuma. O fundo continua lá — ele não é o problema, ser o único sinal é que era. O peso da fonte, que algumas dessas cópias usavam como reforço, não conta: a diferença entre 600 e 700 num texto de 13px não é percebida sem os dois chips lado a lado para comparar."
  - 💡 Explicação Leiga: Esta classe desenha as etiquetas de filtro. Quando uma é escolhida, aparece um sinal de certo além da mudança de cor.

  > "`null` desabilita — o chip vira somente-leitura e deixa de ser anunciado como botão."
  - 💡 Explicação Leiga: A linha desativa a etiqueta quando nenhuma ação é informada.

  > "Fundo do estado selecionado. Padrão: `selectedSurface` do tema, que já inverte entre claro e escuro. Passe outra cor apenas quando o chip carregar identidade própria (ex: a cor da categoria no modal de filtros)."
  - 💡 Explicação Leiga: A linha define a cor de fundo da etiqueta escolhida.

  > "Conteúdo sobre [selectedSurface]. Passe junto com ele — é o par que precisa de contraste, e só quem escolhe o fundo sabe o que fica legível."
  - 💡 Explicação Leiga: A linha define a cor do texto da etiqueta escolhida.

  > "Fundo do estado não selecionado. Padrão: `surface`. O modal de filtros usa `background` porque a folha dele já é `surface` — sem isso o chip inativo desaparece contra o próprio fundo."
  - 💡 Explicação Leiga: A linha define a cor de fundo da etiqueta não escolhida.

  > "Ícone do estado não selecionado — o ✓ toma o lugar dele ao selecionar. Serve para chips cujo rótulo sozinho não diz do que se trata (o '5' de um filtro por nota, que só faz sentido ao lado de uma estrela)."
  - 💡 Explicação Leiga: A linha permite colocar um ícone na etiqueta. Ele some quando a etiqueta é escolhida.

  > "Cor de [icon]. Padrão: a mesma do rótulo. Passe outra quando o ícone carregar significado próprio (o amarelo da estrela de nota)."
  - 💡 Explicação Leiga: A linha define a cor do ícone da etiqueta.

  > "Faz o leitor de tela anunciar 'selecionado' — o terceiro canal, além da cor e do ✓."
  - 💡 Explicação Leiga: A linha informa ao leitor de tela que a etiqueta está escolhida.

  > "Decorativo para o leitor de tela: ele já ouviu 'selecionado' pelo nó de semântica, e um 'check' solto seria ruído."
  - 💡 Explicação Leiga: A linha esconde o sinal de certo do leitor de tela, para ele não ser lido duas vezes.

### 📂 ARQUIVO: lib/core/ui/widgets/app_form_field.dart

- ⚙️ Função: É o campo de digitar padrão, usado em todos os formulários do aplicativo.
- 💬 Comentários Removidos:

  > "Campo de formulário do app. O que mudou na v2 (a API é a mesma — são 27 call sites): Raio 12 no lugar da pílula. Campo em cápsula é a forma de um chip, não de uma área de digitação: o texto encosta nas laterais curvas e a linha de leitura fica torta. Quem define a forma agora é o `inputDecorationTheme`, não este widget. Superfície rebaixada (`surfaceAlt`) em vez de `surface`. Um campo é um buraco no papel, não um objeto sobre ele — antes o fundo do campo era idêntico ao do card que o continha, e só a borda o separava. Nada de `filled`/`fillColor`/`hintStyle` locais. Estavam sobrescrevendo o tema, então mudar o tema não mudava os formulários. Rótulo em `caption`, com peso 600 e no tom secundário: o rótulo orienta, o valor digitado é que deve ter contraste alto."
  - 💡 Explicação Leiga: Esta classe desenha o campo de digitar. Ele tem cantos levemente arredondados e fundo mais escuro que o cartão.

  > "Ícone à esquerda. Mantenha só onde ele informa de verdade (busca, senha, telefone) — em todo campo, vira ruído e come largura útil."
  - 💡 Explicação Leiga: A linha permite colocar um ícone dentro do campo.

  > "Teto de caracteres. O contador '0/1000' que o Flutter injeta junto continua suprimido (ver `counterText` abaixo) — o limite existe para casar com o que a API aceita, não para ser exibido."
  - 💡 Explicação Leiga: A linha limita quantas letras cabem no campo. O contador de letras fica escondido.

  > "Foco deste campo — necessário para encadear a navegação do teclado (ver [onSubmitted])."
  - 💡 Explicação Leiga: A linha identifica o campo para o teclado saber pular para o próximo.

  > "Tecla de ação do teclado. Use `TextInputAction.next` em todo campo menos o último do formulário, que recebe `done`: sem isso o teclado mostra 'concluído' em todos e fecha a cada campo, obrigando o usuário a tocar de novo na tela para continuar."
  - 💡 Explicação Leiga: A linha define o que a tecla azul do teclado faz. Ela pula para o próximo campo ou finaliza.

  > "Disparado ao confirmar no teclado. Combine com [focusNode] do próximo campo (`FocusScope.of(context).requestFocus(proximo)`) ou com o submit do formulário, no último campo."
  - 💡 Explicação Leiga: A linha define o que acontece ao apertar a tecla de confirmar.

  > "O rótulo visual acima já é lido em sequência pela maioria dos leitores de tela, mas não é associado ao campo de forma formal — o Semantics abaixo garante essa associação (WCAG 4.1.2), sem duplicar nada pra quem não usa leitor de tela (o Text visual continua sendo a única coisa renderizada na tela)."
  - 💡 Explicação Leiga: A linha liga formalmente o rótulo ao campo. Assim o leitor de tela sabe qual nome pertence a qual campo.

  > "Valor digitado com contraste alto e peso 500: é o conteúdo real do campo, precisa ganhar do rótulo e do placeholder."
  - 💡 Explicação Leiga: A linha deixa o texto digitado mais escuro e mais forte que o rótulo.

  > "Some com o '0/1000' que o Flutter injeta sozinho quando há maxLength — quando fizer falta, o call site liga de volta."
  - 💡 Explicação Leiga: A linha esconde o contador de letras que o Flutter mostra automaticamente.

  > "Ícone mais próximo do texto: o padrão do Material reserva 48px de caixa e abre um vão grande entre ícone e conteúdo."
  - 💡 Explicação Leiga: A linha aproxima o ícone do texto dentro do campo.

### 📂 ARQUIVO: lib/core/ui/widgets/app_network_image.dart

- ⚙️ Função: Baixa e mostra toda foto vinda do servidor, com cache e imagem reserva.
- 💬 Comentários Removidos:

  > "Toda imagem vinda da API passa por aqui. Antes deste widget havia treze `Image.network` escritos à mão pelo app (cards de busca, capa da loja, galeria, avatares, marcador do mapa, favoritos, avaliações...), cada um repetindo o mesmo trio de cuidados — `resolveImagemUrl` antes de montar, `excludeFromSemantics`, `errorBuilder` com um ícone cinza — e cada um com uma variação pequena do mesmo bug. Concentrar aqui resolve quatro coisas de uma vez: 1. A URL se resolve sozinha. As telas passam o path cru que veio do backend (`/uploads/lojas/x.jpg`); o `null` de 'loja sem foto' deixa de ser um `if` repetido em cada chamada e vira o [fallback]. 2. A foto entra com fade, em vez de ser pintada de estalo por cima do fundo cinza — ver [_comFade], e a ressalva sobre imagem já em cache, que não anima de propósito. 3. A foto sobrevive ao fechamento do app — ver [providerFor]. 4. Existe um ponto único para mudar qualquer uma dessas decisões sem voltar aos treze arquivos. Foi o que permitiu ligar o cache de disco no app inteiro trocando uma linha."
  - 💡 Explicação Leiga: Esta classe mostra todas as fotos que vêm do servidor. Ela substituiu treze trechos de código parecidos espalhados pelo app.

  > "Path cru devolvido pela API (ex: `/uploads/lojas/x.jpg`) ou URL absoluta. `null`/vazio cai direto no [fallback], sem tentar rede."
  - 💡 Explicação Leiga: A linha recebe o caminho da foto. Se estiver vazio, nem tenta baixar nada.

  > "Largura em pixels lógicos com que a imagem aparece na tela (ex: 84 para a miniatura da lista). A conversão para pixels físicos — multiplicar pelo `devicePixelRatio` — acontece aqui dentro, porque era exatamente a conta que cada chamada refazia à mão. Só a largura, nunca a altura junto: com as duas definidas o decoder ignora a proporção original e estica a imagem."
  - 💡 Explicação Leiga: A linha informa o tamanho em que a foto aparece. A foto é reduzida para esse tamanho, economizando memória.

  > "Descrição para leitor de tela. Deixe `null` quando a imagem for decorativa — quando o nome da loja já aparece como texto ao lado, o leitor não deve anunciá-la duas vezes."
  - 💡 Explicação Leiga: A linha guarda a descrição falada da foto. Fotos decorativas ficam sem descrição.

  > "O que aparece sem imagem e em caso de erro. Sem isto, um ícone neutro do tamanho de [fallbackIconSize]."
  - 💡 Explicação Leiga: A linha define o que aparece quando não há foto ou o download falha.

  > "Duração do fade. 200ms é o suficiente para a entrada ser percebida como suave sem atrasar a leitura da tela."
  - 💡 Explicação Leiga: A linha define que a foto surge em 200 milésimos de segundo.

  > "O provider que este widget usa para desenhar — exposto porque quem pré-carrega precisa usar exatamente o mesmo. A largura de decodificação entra na chave do cache de memória: aquecer `provider(url)` e depois desenhar `ResizeImage(provider(url), width: 1080)` são duas entradas distintas, e o precache viraria um download a mais em vez de uma tela mais rápida. Construir os dois por aqui é o que impede esse desencontro silencioso. Por que `CachedNetworkImageProvider` e não `NetworkImage`: O `NetworkImage` do Flutter guarda a imagem só em memória: fechar o app apagava tudo, e o MapFood reabria baixando cada capa de novo — em 4G de calçada, que é onde ele é usado. O provider do `cached_network_image` grava em disco. O ganho não é só entre sessões. O cache de disco é chaveado apenas pela URL, enquanto o de memória inclui a largura: a mesma capa exibida a 84px na lista e em tela cheia no detalhe eram dois downloads e agora são um só, decodificado duas vezes a partir do mesmo arquivo. Fica no provider, não no widget `CachedNetworkImage` do pacote: aquele widget traz a própria API de placeholder e fade, que substituiria o comportamento construído aqui. Trocando só o transporte, o resto do app não percebe a mudança. Retenção é a padrão do `flutter_cache_manager` (200 arquivos, 30 dias). Devolve `null` quando não há imagem — o chamador cai no fallback."
  - 💡 Explicação Leiga: A função devolve o objeto que busca a foto. As fotos ficam guardadas no disco por 30 dias, então o app não baixa a mesma foto duas vezes.

  > "`displayWidth` é lógico; o decoder espera pixel físico do aparelho. Sem a conversão a imagem sairia borrada em telas de alta densidade."
  - 💡 Explicação Leiga: A linha multiplica o tamanho pela densidade da tela. Sem isso a foto ficaria borrada.

  > "Baixa e decodifica a imagem antes de ela ser necessária, deixando-a pronta no cache de memória. Use no toque que leva a uma tela onde a imagem é o cabeçalho: a espera passa a acontecer durante a animação de transição, e a tela nova nasce com a foto no lugar em vez de com um retângulo cinza. Não devolve erro: uma foto que falhou no pré-carregamento simplesmente será buscada de novo pela tela de destino, que já sabe lidar com falha. Deixá-la escapar aqui derrubaria uma navegação por causa de um 404."
  - 💡 Explicação Leiga: A função baixa a foto antes de ela ser exibida. Assim a próxima tela já abre com a foto pronta.

  > "Fade de entrada — mas só na primeira vez. `wasSynchronouslyLoaded` é true quando a imagem já estava no cache de memória e ficou pronta no mesmo frame. Animar nesse caso faria a foto piscar a cada rebuild: a cada rolagem da lista, a cada toque no coração de favorito, a cada notificação do `ActiveStoresManager`. O fade é para mascarar espera; onde não houve espera, ele só chama atenção para si. É também o que faz o precache valer a pena: uma imagem pré-carregada antes da navegação chega por este caminho e aparece inteira no primeiro frame da tela nova, sem transição nenhuma."
  - 💡 Explicação Leiga: A função faz a foto surgir suavemente só quando houve espera. Fotos já guardadas aparecem na hora, sem piscar.

### 📂 ARQUIVO: lib/core/ui/widgets/app_refresh.dart

- ⚙️ Função: Adiciona o gesto de puxar a tela para baixo para atualizar o conteúdo.
- 💬 Comentários Removidos:

  > "'Puxe para atualizar' — o gesto padrão do app. Existe porque um `RefreshIndicator` cru erra duas coisas com facilidade, e as duas já tinham sido acertadas à mão em telas isoladas antes de virarem regra aqui: 1. A cor. O indicador nasce com o roxo do Material, que não é nenhuma cor do MapFood. 2. A física da rolagem. Sem `AlwaysScrollableScrollPhysics`, o gesto simplesmente não existe quando o conteúdo cabe na tela — e a lista curta (nenhum favorito ainda, nenhuma avaliação ainda) é justamente onde a pessoa mais puxa para conferir se algo mudou. O `parent` preserva o `BouncingScrollPhysics` que o app usa em todas as listas. A física precisa ser aplicada na lista filha, não aqui — por isso [physics] é exposta como constante para quem monta o scrollable."
  - 💡 Explicação Leiga: Esta classe adiciona o gesto de puxar para atualizar. Ela funciona mesmo quando a lista é curta e não rola.

  > "Recarga. Só termina quando o dado novo chegou — é o que segura a animação até valer a pena soltar."
  - 💡 Explicação Leiga: A linha recebe a função que busca os dados novos. A animação só para quando os dados chegam.

  > "O scrollable. Deve usar [physics], senão o gesto some em lista curta."
  - 💡 Explicação Leiga: A linha recebe a lista que vai rolar.

  > "Física a aplicar no scrollable filho."
  - 💡 Explicação Leiga: A linha guarda a configuração de rolagem que a lista deve usar.

  > "Embrulha um conteúdo que não é uma lista — um estado vazio, uma mensagem de erro — num scrollable de altura cheia, centralizado. `RefreshIndicator` só reage a um filho que rola, e um `Center` solto não rola: sem isto o gesto desapareceria justamente nos dois estados em que a pessoa mais quer tentar de novo ('nada aqui ainda', 'falha de rede')."
  - 💡 Explicação Leiga: A função permite puxar para atualizar em telas sem lista. É o caso da tela vazia e da tela de erro.

  > "O disco atrás do indicador acompanha o tema: no escuro, o branco padrão do Material vira uma pastilha clara sobre o fundo escuro."
  - 💡 Explicação Leiga: A linha faz o fundo do indicador de atualização mudar com o tema.

### 📂 ARQUIVO: lib/core/ui/widgets/app_toast.dart

- ⚙️ Função: Mostra avisos rápidos no canto da tela, que somem sozinhos.
- 💬 Comentários Removidos:

  > "Alerta de sucesso/erro em pop-up no canto superior direito que some sozinho depois de alguns segundos — infra única de notificação do app, substituindo os SnackBars/AlertDialogs que antes ficavam espalhados (e cada um decidia sua própria posição/duração/estilo). O corpo do toast é preenchido com a cor semântica: verde, vermelho, amarelo ou azul de ponta a ponta. A versão anterior usava a superfície de card com a cor só na borda a 25% de opacidade e no ícone — o que fazia os quatro estados parecerem o mesmo aviso de longe, que é justamente quando o toast é lido (ele some em 3s, no canto da tela, enquanto a pessoa olha para outra coisa)."
  - 💡 Explicação Leiga: Esta classe mostra avisos coloridos no canto da tela. A cor preenche o aviso inteiro para ser reconhecida de longe.

  > "Atenção: a ação foi adiante, mas com ressalva — ou está prestes a ir e convém saber de algo antes (limite atingido, dado faltando, permissão negada que degrada a tela sem quebrá-la). Fica entre [info] e [error]."
  - 💡 Explicação Leiga: A função mostra um aviso amarelo. Ele significa que algo funcionou, mas com uma ressalva.

  > "Aviso neutro: nada deu errado, só não há o que fazer ainda (recurso em desenvolvimento, ação indisponível no momento). Usar [error] para isso pintaria de vermelho uma situação que não é falha."
  - 💡 Explicação Leiga: A função mostra um aviso azul. Ele significa uma informação comum, não um erro.

  > "Só um toast por vez — um novo alerta substitui o anterior em vez de empilhar, evitando poluir a tela em telas com várias ações seguidas."
  - 💡 Explicação Leiga: A linha remove o aviso anterior antes de mostrar um novo.

  > "Evita chamar entry.remove() duas vezes (uma pelo toast seguinte substituindo este, outra pelo próprio onDismissed ao terminar a animação de saída) — remover um OverlayEntry já removido derruba o app."
  - 💡 Explicação Leiga: A linha impede que o aviso seja removido duas vezes. Remover duas vezes fecharia o aplicativo.

  > "Fundo na cor semântica + o conteúdo que passa em contraste sobre ele. O par vem junto de propósito: separar 'cor do fundo' de 'cor do texto' em dois switches é como se perde a garantia de contraste na primeira vez que alguém acrescenta um tipo novo."
  - 💡 Explicação Leiga: A linha escolhe a cor de fundo e a cor do texto ao mesmo tempo. Assim o par nunca fica ilegível.

  > "O único com texto escuro — ver `MfColor.warningFill`."
  - 💡 Explicação Leiga: A linha define que o aviso amarelo usa texto escuro, ao contrário dos outros.

  > "O texto do aviso é lido pelo nó do próprio Text abaixo; aqui o rótulo descreve só o que o toque faz."
  - 💡 Explicação Leiga: A linha informa ao leitor de tela que tocar no aviso o dispensa.

  > "O toast já entra e sai animado — encolher no toque brigaria com a animação de saída que o toque dispara."
  - 💡 Explicação Leiga: A linha desliga o efeito de encolher no toque.

  > "Sem borda: com o corpo inteiro preenchido, ela só acrescentaria um contorno de outra cor sobre a cor."
  - 💡 Explicação Leiga: A linha desenha apenas a sombra do aviso, sem borda.

### 📂 ARQUIVO: lib/core/ui/widgets/auth_hero_band.dart

- ⚙️ Função: Desenha a faixa colorida decorativa no topo das telas de login e cadastro.
- 💬 Comentários Removidos:

  > "Faixa decorativa desenhada em código (gradiente + blobs de cor + ícone), sem depender de foto/ilustração externa — usada no topo das telas de autenticação (login, cadastro), que antes eram 100% tipografia + campos empilhados, sem nenhum elemento gráfico. Blobs usam tons da paleta de categoria (`category_colors.dart`) pra ecoar a mesma identidade cromática do resto do app, em vez de introduzir cores novas isoladas."
  - 💡 Explicação Leiga: Esta classe desenha uma faixa colorida com formas arredondadas. Nenhuma imagem é usada, tudo é desenhado pelo código.

### 📂 ARQUIVO: lib/core/ui/widgets/confirm_delete_dialog.dart

- ⚙️ Função: Pede confirmação antes de apagar foto, loja ou conta.
- 💬 Comentários Removidos:

  > "Mostra um dialog de confirmação antes de remover uma foto já salva no servidor. Devolve `true` se o usuário confirmou."
  - 💡 Explicação Leiga: A função pergunta se o usuário quer mesmo apagar a foto.

  > "Confirma a exclusão de uma loja — não da conta. O `DELETE /lojas/{id}` apaga junto as avaliações, as denúncias e todo o histórico de acessos daquela loja. Quem lê 'excluir loja' pensa em tirar do mapa; a frase abaixo existe para que ninguém descubra depois que perdeu as notas que levou meses para juntar."
  - 💡 Explicação Leiga: A função avisa que apagar a loja apaga também as avaliações dela.

  > "Mostra um dialog de confirmação antes de excluir a conta do usuário — ação irreversível que também apaga loja(s), avaliações e denúncias associadas (cascade feito pelo backend). Devolve `true` se confirmado."
  - 💡 Explicação Leiga: A função avisa que apagar a conta apaga tudo que pertence a ela.

  > "Confirmação de ação irreversível: só libera o botão depois que a pessoa digita a palavra-chave. A digitação é o freio — num diálogo de dois botões, 'confirmar' está a um toque de distância de quem só queria fechar o menu."
  - 💡 Explicação Leiga: A função obriga o usuário a digitar uma palavra antes de apagar. Isso evita apagar algo por engano.

### 📂 ARQUIVO: lib/core/ui/widgets/confirm_dialog.dart

- ⚙️ Função: Pede confirmação de ações que podem ser desfeitas depois.
- 💬 Comentários Removidos:

  > "Confirmação de uma ação reversível — devolve `true` se confirmada. Existe ao lado de `confirm_delete_dialog.dart`, não dentro dele: lá o freio é digitar 'EXCLUIR', porque nada volta depois do toque. Pedir o mesmo ritual para inativar uma loja (que se reativa em dois toques) ensinaria a digitar a palavra no automático — e é justamente esse automatismo que protege o diálogo de exclusão."
  - 💡 Explicação Leiga: A função pede uma confirmação simples, com dois botões. Ela é usada em ações que podem ser desfeitas.

  > "Neutro, não vermelho: o vermelho é o vocabulário das ações sem volta (excluir, sair) e perde o sentido de alerta se aparecer também nas que se desfazem."
  - 💡 Explicação Leiga: A linha usa cor neutra neste diálogo. O vermelho fica reservado para ações sem volta.

  > "Mesmo CTA sólido do diálogo de logout: preto/branco fixos para ler igual nos dois temas."
  - 💡 Explicação Leiga: A linha usa um botão preto e branco fixo, igual nos dois temas.

### 📂 ARQUIVO: lib/core/ui/widgets/delta_badge.dart

- ⚙️ Função: Mostra a variação percentual entre um período e o anterior.
- 💬 Comentários Removidos:

  > "Como a pílula pinta a variação."
  - 💡 Explicação Leiga: Esta lista define três formas de colorir a variação.

  > "Cor da marca no positivo, neutro no negativo. É o tratamento do painel de atividade do consumidor, onde o número mede o próprio uso do app: avaliar menos que no mês passado não é um resultado ruim, é só um número menor — pintá-lo de vermelho repreenderia quem está usando o app."
  - 💡 Explicação Leiga: A linha define o modo que não usa vermelho. Ele é usado nos números de uso pessoal do app.

  > "Verde sobe, vermelho desce. Para métrica de negócio, onde a direção tem valor de verdade: menos gente vendo a loja é uma má notícia, e a cor é o que faz isso ser lido num relance."
  - 💡 Explicação Leiga: A linha define o modo normal. Subir é verde e descer é vermelho.

  > "O inverso: verde desce, vermelho sobe. Para o que é melhor quando diminui — denúncias, reclamações. Sem esta variante, '+40% de denúncias' apareceria em verde, com cara de conquista."
  - 💡 Explicação Leiga: A linha define o modo invertido. Ele é usado em denúncias, onde diminuir é bom.

  > "Pílula de variação percentual entre o período atual e o anterior — o '+15%' ao lado do número grande."
  - 💡 Explicação Leiga: Esta classe desenha a etiqueta pequena com a porcentagem de variação.

  > "`successContent`/`brandContent` e não os tons puros: são as versões que passam em contraste como texto nos dois temas (ver map_food_colors.dart)."
  - 💡 Explicação Leiga: A linha usa as cores ajustadas para texto, que são legíveis nos dois temas.

### 📂 ARQUIVO: lib/core/ui/widgets/edit_profile_page_scaffold.dart

- ⚙️ Função: Monta a tela de editar perfil, usada tanto pelo consumidor quanto pelo comerciante.
- 💬 Comentários Removidos:

  > "Dados iniciais comuns a qualquer perfil editável (consumidor/comerciante)."
  - 💡 Explicação Leiga: A linha define a caixinha com nome, e-mail, telefone e foto atuais.

  > "Scaffold genérico de edição de perfil — consumidor e comerciante tinham ~90% do mesmo código aqui, diferindo só no modelo salvo (cada página constrói o próprio modelo tipado e chama o próprio serviço via [salvar]) e num campo extra (CNPJ, via [extraFieldBuilder])."
  - 💡 Explicação Leiga: Esta classe monta a tela de edição para os dois tipos de usuário. A diferença é apenas um campo extra e como os dados são salvos.

  > "ValueNotifier (não bool simples) de propósito: o UnsavedChangesGuard isola o rebuild no próprio ValueListenableBuilder interno dele, então atualizar isso não reconstrói mais a página inteira a cada tecla."
  - 💡 Explicação Leiga: A linha guarda se existem mudanças não salvas. A tela inteira não é redesenhada a cada letra digitada.

  > "Sem isso, a sessão continuava com o nome/e-mail antigos (do login), e é dali que o card de Perfil lê — por isso ele não refletia a edição mesmo com o backend já salvo. `SessionStore.updateNomeEmail` atualiza disco e memória de uma vez; só o disco deixaria o valor antigo vivo em quem já leu o store nesta sessão."
  - 💡 Explicação Leiga: A linha atualiza o nome guardado na memória depois de salvar. Sem ela o app continuava mostrando o nome antigo.

  > "maybePop consulta o PopScope do UnsavedChangesGuard antes de sair — mesmo ajuste feito no StoreMapPage (ver comentário lá)."
  - 💡 Explicação Leiga: A linha faz o botão de voltar perguntar antes de descartar as mudanças.

  > "Durante o upload o toque já está bloqueado; com `onTap` nulo o nó também deixa de ser anunciado como botão, em vez de prometer uma ação inerte."
  - 💡 Explicação Leiga: A linha desativa o toque na foto durante o envio. O leitor de tela também deixa de anunciá-la como botão.

  > "Mesmo banner das telas de auth — era mais um bloco de erro montado à mão, com padding e raio próprios."
  - 💡 Explicação Leiga: A linha usa o aviso de erro padrão do app, em vez de um desenhado só para esta tela.

### 📂 ARQUIVO: lib/core/ui/widgets/empty_state.dart

- ⚙️ Função: Desenha a mensagem que aparece quando uma lista está vazia ou deu erro.
- 💬 Comentários Removidos:

  > "O que um estado vazio comunica."
  - 💡 Explicação Leiga: Esta lista define os dois tipos de tela vazia.

  > "Não há nada ainda — o app está funcionando, a pessoa é que não produziu conteúdo. É o caso mais comum (sem favoritos, sem avaliações) e o que mais precisa parecer calmo: nada deu errado aqui."
  - 💡 Explicação Leiga: A linha define o tipo calmo, sem cor de alerta. É usado quando a lista só está vazia.

  > "Algo falhou (rede, servidor). Ícone e ação ganham a cor de alerta."
  - 💡 Explicação Leiga: A linha define o tipo de erro, com ícone vermelho.

  > "Estado vazio ou de erro. A versão anterior pintava o ícone dentro de um círculo vermelho a 12% em todos os casos, inclusive nos 'você ainda não avaliou nada' — o que dava ao app um ar de erro permanente justamente nas telas em que o usuário novo passa mais tempo. Agora: o tom padrão é neutro: círculo em `surfaceAlt`, ícone em `textTertiary`. Some para o segundo plano em vez de gritar; só [EmptyStateTone.error] usa vermelho, e ainda assim apenas no ícone; a ação usa `AppButton` (`secondary` no neutro, `primary` no erro), em vez de um `ElevatedButton` pill vermelho montado à mão."
  - 💡 Explicação Leiga: Esta classe desenha a tela vazia com ícone, título e texto. Ela só usa vermelho quando houve erro de verdade.

  > "Cor de acento do ícone. Use com parcimônia — o padrão neutro é o certo para quase todo estado vazio."
  - 💡 Explicação Leiga: A linha permite trocar a cor do ícone em casos especiais.

  > "Compacta o bloco para caber dentro de um card ou seção, em vez de ocupar a tela inteira."
  - 💡 Explicação Leiga: A linha deixa o bloco menor, para caber dentro de um cartão.

  > "Círculo e ícone acompanham a escala: um estado vazio é um bloco centrado de ilustração + texto, e o ícone parado ao lado de um título que dobrou quebra a proporção do conjunto. O círculo cresce junto para não apertar o ícone contra a borda."
  - 💡 Explicação Leiga: A linha faz o círculo e o ícone crescerem junto com a letra.

  > "Sem isto, dentro de uma `Column` com `crossAxisAlignment.start` (o caso do perfil) o bloco encolhe até o conteúdo e fica encostado à esquerda em vez de centralizado."
  - 💡 Explicação Leiga: A linha força o bloco a ocupar toda a largura, para ele ficar centralizado.

  > "Três linhas bastam: um estado vazio que precisa de parágrafo está explicando demais. Mas o corte é uma regra de edição de texto, não de espaço — em escala alta ele passaria a cortar uma frase que cabia, então o teto sai de cena e o bloco cresce (nada aqui tem altura fixa)."
  - 💡 Explicação Leiga: A linha limita o texto a três linhas. O limite é removido quando a letra está grande.

### 📂 ARQUIVO: lib/core/ui/widgets/form_error_banner.dart

- ⚙️ Função: Mostra o erro de um formulário em uma faixa fixa acima do botão de enviar.
- 💬 Comentários Removidos:

  > "Erro de formulário exibido junto do botão de envio. Substitui o par 'texto vermelho solto + `AppToast.error`' que as telas de auth faziam: a mesma frase aparecia duas vezes, uma delas sumindo sozinha depois de alguns segundos. Erro de submit é estado da tela, não notificação — fica visível até o usuário corrigir. Passe `null` em [message] para não ocupar espaço nenhum."
  - 💡 Explicação Leiga: Esta classe mostra o erro do formulário de forma fixa. O erro fica visível até o usuário corrigir o campo.

### 📂 ARQUIVO: lib/core/ui/widgets/glass_container.dart

- ⚙️ Função: Desenha um bloco com efeito de vidro fosco, que desfoca o que está atrás.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

### 📂 ARQUIVO: lib/core/ui/widgets/how_it_works_scaffold.dart

- ⚙️ Função: Monta as telas de "Como funciona" mostrando os passos em ordem.
- 💬 Comentários Removidos:

  > "Um passo do 'Como funciona'."
  - 💡 Explicação Leiga: A linha define a caixinha com o ícone, o título e a descrição de um passo.

  > "Layout das telas 'Como funciona' — a do visitante e a do comerciante. As duas explicam a mesma coisa para públicos diferentes e viviam desenhadas de formas diferentes: a do visitante em três cards de cores literais distintas (vermelho, superfície, preto), com o CTA flutuando num `Stack` sobre a lista e 140px de respiro reservados à mão para ele não cobrir o último card; a do comerciante já em cards do design system. Ler as duas em sequência dava a impressão de dois aplicativos. Os passos são uma linha do tempo, não três cards soltos. Cada um só faz sentido depois do anterior (explorar → filtrar → traçar a rota; abrir → rodar → colher retorno), e é o traço vertical ligando as bolhas que diz isso — o rótulo 'PASSO N' sozinho é uma legenda, não uma sequência. O CTA fica fora do scroll: a saída da tela não deveria depender de rolar até o fim."
  - 💡 Explicação Leiga: Esta classe desenha os passos ligados por uma linha vertical. O botão de sair fica sempre visível no rodapé.

  > "O visitante fecha a tela com o CTA de marca (é o 'começar a explorar' da jornada dele); o comerciante, com o neutro forte."
  - 💡 Explicação Leiga: A linha permite escolher a cor do botão conforme o tipo de usuário.

  > "`null` usa `Navigator.pop`."
  - 💡 Explicação Leiga: A linha faz o botão fechar a tela quando nenhuma ação é informada.

  > "Um passo: bolha com o ícone à esquerda, texto à direita, traço vertical descendo da bolha até o passo seguinte."
  - 💡 Explicação Leiga: Esta classe desenha um passo da lista.

  > "Lado da bolha. Escala com a fonte porque ela precisa continuar alinhada ao bloco de texto ao lado, que cresce."
  - 💡 Explicação Leiga: A linha define o tamanho do círculo do ícone. Ele cresce junto com a letra.

  > "Coluna da linha do tempo: bolha + traço até o próximo passo. `stretch` no Row dá altura ao Expanded do traço; sem o IntrinsicHeight de fora, essa altura seria infinita."
  - 💡 Explicação Leiga: Este bloco desenha o círculo e a linha que desce até o próximo passo.

  > "O respiro entre passos vive aqui, no texto, e não como um SizedBox entre os itens: entre eles ele cortaria o traço."
  - 💡 Explicação Leiga: A linha coloca o espaço entre passos dentro do texto, para não interromper a linha vertical.

### 📂 ARQUIVO: lib/core/ui/widgets/image_picker_sheet.dart

- ⚙️ Função: Abre o painel que pergunta se a foto vem da câmera ou da galeria.
- 💬 Comentários Removidos:

  > "Abre um bottom sheet com as opções 'Tirar foto' / 'Escolher da galeria' e devolve o arquivo escolhido, ou `null` se o usuário cancelar. Devolve `XFile` (não `dart:io.File`) porque este app também builda para Flutter Web, onde não há acesso a caminhos de arquivo do sistema."
  - 💡 Explicação Leiga: A função mostra duas opções de origem da foto. Ela devolve o arquivo em um formato que funciona também no navegador.

  > "Um tom abaixo do cardSurface do sheet (mainBackground é sempre mais 'recuado'/escuro que cardSurface nos dois temas — ver map_food_colors.dart), pra continuar destacando a linha da opção sem precisar de um terceiro token de superfície."
  - 💡 Explicação Leiga: A linha usa um fundo um pouco mais escuro para destacar cada opção.

### 📂 ARQUIVO: lib/core/ui/widgets/keyboard_aware_bottom_bar.dart

- ⚙️ Função: Faz a barra do rodapé deslizar para fora da tela quando o teclado abre.
- 💬 Comentários Removidos:

  > "Ancora a bottom bar no rodapé e a faz deslizar para fora quando o teclado abre. Use como filho direto de um `Stack` — ele já devolve um [Positioned]. Por que isto é um widget, e não três linhas dentro do `build` da home: Ler `MediaQuery.of(context)` cria dependência no objeto inteiro de `MediaQueryData`. Quando o teclado sobe, `viewInsets` é animado pelo sistema e um `MediaQueryData` novo é publicado a cada frame — ou seja, quem leu `MediaQuery.of` reconstrói ~60 vezes por segundo durante a animação. Nas homes, essa leitura estava no topo do `build` da página. O `build` inteiro rodava por frame e, com ele, o `IndexedStack` recebia instâncias novas de `HomeMapExplorer`, `SearchPage`, dashboard e perfil — e como widget novo não é idêntico ao anterior, o Flutter descia a árvore e reconstruía o mapa com todos os pins, o gráfico de atividade e os formulários, tudo isso enquanto o teclado ainda estava abrindo. Era essa a queda de FPS ao focar um campo. Os `RepaintBoundary` que já existiam ali não pegavam esse caso: eles isolam pintura, não construção. A árvore era reconstruída do mesmo jeito; só a repintura das abas paradas é que era evitada. Com a leitura aqui dentro, a reconstrução por frame fica restrita a esta folha — uma barra com três ou cinco ícones —, e a home só reconstrói quando algo dela realmente muda."
  - 💡 Explicação Leiga: Esta classe isola a leitura da altura do teclado. Sem ela, o mapa inteiro era redesenhado 60 vezes por segundo ao abrir o teclado.

  > "Tempo da saída. Um pouco mais rápido que o teclado do Android (~250ms) de propósito: a barra sai da frente antes de o campo focado subir."
  - 💡 Explicação Leiga: A linha define que a barra some em 220 milésimos de segundo.

  > "`viewInsetsOf` e não `of`: mesmo confinada aqui, a dependência específica evita rebuild quando muda qualquer outra coisa do MediaQuery (rotação, padding do notch, escala de texto)."
  - 💡 Explicação Leiga: A linha observa apenas a altura do teclado, e não todas as informações da tela.

  > "`resizeToAvoidBottomInset: false` nas homes trava o Stack no lugar (a barra não sobe agarrada ao teclado); este Slide é o que dá a saída suave por baixo da tela ao focar um campo."
  - 💡 Explicação Leiga: A linha faz a barra deslizar suavemente para baixo, em vez de subir com o teclado.

### 📂 ARQUIVO: lib/core/ui/widgets/login_wall_bottom_sheet.dart

- ⚙️ Função: Mostra o painel que pede login quando um visitante tenta uma ação restrita.
- 💬 Comentários Removidos:

  > "Sheet de 'precisa de conta pra isso'. Os textos são parametrizados porque a mesma parede agora barra três ações diferentes (favoritar, avaliar, denunciar) — anunciar 'Salve seus comércios favoritos!' para quem tocou em 'Denunciar' não explica nada. Os defaults são os textos originais de favoritos, então quem já chamava sem argumentos continua vendo exatamente o mesmo sheet."
  - 💡 Explicação Leiga: A função mostra um painel pedindo para entrar na conta. O texto muda conforme a ação que o visitante tentou fazer.

### 📂 ARQUIVO: lib/core/ui/widgets/logout_dialog.dart

- ⚙️ Função: Pede confirmação e executa a saída da conta.
- 💬 Comentários Removidos:

  > "Confirmação de 'Sair da conta' — extraída do `ProfilePageScaffold` quando o perfil do consumidor deixou de usar aquele scaffold: os dois perfis precisam encerrar sessão exatamente do mesmo jeito, e duplicar este fluxo é como o `FavoritesManager` já vazou dados de uma conta pra outra antes. [onLogoutExtra] é o hook opcional de quem chama (ex: limpar favoritos); a limpeza de sessão e do estado com escopo de usuário roda sempre."
  - 💡 Explicação Leiga: A função pergunta se o usuário quer sair e depois apaga a sessão. Ela é a mesma para os dois tipos de usuário.

  > "backgroundColor/foregroundColor ficam de propósito como literais: é um CTA sólido preto/branco que deve parecer o mesmo nos dois temas, não uma superfície que se adapta ao brightness."
  - 💡 Explicação Leiga: A linha fixa as cores preto e branco do botão, sem seguir o tema.

  > "signOut (não AuthStorage.clear direto): limpa disco e memória de uma vez. Só limpar o disco deixava o SessionStore publicando um usuário já deslogado."
  - 💡 Explicação Leiga: A linha apaga a sessão do disco e da memória ao mesmo tempo.

  > "Sempre roda, pros dois papéis — não depende de a tela chamadora lembrar de passar onLogoutExtra (foi exatamente esse esquecimento, no perfil do comerciante, que deixava FavoritesManager vazando dados de uma conta pra outra no mesmo aparelho)."
  - 💡 Explicação Leiga: A linha limpa os dados guardados do usuário sempre. Antes isso dependia de cada tela lembrar de pedir.

### 📂 ARQUIVO: lib/core/ui/widgets/menu_list_tile.dart

- ⚙️ Função: Desenha uma linha de menu com ícone, título e seta.
- 💬 Comentários Removidos:

  > "Linha de menu do app (ícone em quadrado arredondado + título/subtítulo + caret vermelho) — o mesmo item aparece no Perfil, nas Configurações e no perfil de visitante, e existia copiado em cada um deles."
  - 💡 Explicação Leiga: Esta classe desenha uma linha de menu. Ela é usada em três telas diferentes.

  > "Cor de destaque opcional (ex: vermelho pra 'Excluir conta') — null usa o tratamento neutro padrão da lista."
  - 💡 Explicação Leiga: A linha permite pintar o ícone de vermelho em opções perigosas.

  > "A linha não tem altura fixa — cresce com o texto. O que faltava era o alinhamento: com o título ocupando duas linhas em escala alta, `center` (o padrão) deixava o ícone boiando no meio do bloco."
  - 💡 Explicação Leiga: A linha alinha o ícone no topo. Assim ele não fica flutuando quando o texto ocupa duas linhas.

  > "O caret é decorativo e fica na ponta da linha: escala com teto menor que os demais, para não roubar largura do título."
  - 💡 Explicação Leiga: A linha limita o crescimento da seta, para sobrar espaço para o título.

  > "Rótulo de seção em caixa alta usado acima de grupos de [MenuListTile]."
  - 💡 Explicação Leiga: Esta classe desenha o título em letras maiúsculas acima de um grupo de opções.

### 📂 ARQUIVO: lib/core/ui/widgets/photo_hero_card.dart

- ⚙️ Função: Desenha um cartão grande com foto de fundo e texto por cima.
- 💬 Comentários Removidos:

  > "Card 'imersivo': foto preenche o espaço inteiro, com um gradiente escuro em três estágios por baixo e conteúdo (badges, texto) sobreposto — extraído do `DestaqueCardWidget` original (carrossel 'Perto de você') pra virar o padrão visual reaproveitável do app: qualquer superfície que precise de tratamento 'hero' (capa da loja no dashboard, header da tela de detalhe) usa este widget por baixo, em vez de reimplementar o Stack+gradiente+ClipRRect toda vez."
  - 💡 Explicação Leiga: Esta classe desenha um cartão com foto ocupando todo o espaço. Um degradê escuro embaixo garante que o texto branco seja lido.

  > "Largura lógica com que o card aparece na tela — normalmente a largura do viewport, já que este é um card de tela cheia. Era `cacheWidth`, em pixels físicos, e cada chamador precisava lembrar de multiplicar pelo `devicePixelRatio`; a conta agora mora no [AppNetworkImage]."
  - 💡 Explicação Leiga: A linha informa a largura do cartão. A conta de conversão de tamanho ficou em outro arquivo.

  > "RepaintBoundary própria pra a foto não repintar por causa de interações no conteúdo sobreposto (favorito, scroll do carrossel ao lado etc.)."
  - 💡 Explicação Leiga: A linha isola a foto. Tocar no coração de favorito não faz a foto ser redesenhada.

  > "Um tom abaixo do cardSurface, senão o placeholder fica invisível contra o próprio fundo antes da imagem carregar."
  - 💡 Explicação Leiga: A linha usa um fundo mais escuro atrás da foto que ainda está carregando.

  > "Sem `semanticLabel`: decorativa. O conteúdo textual sobreposto já descreve o card pra leitor de tela."
  - 💡 Explicação Leiga: A linha deixa a foto sem descrição falada, porque o texto por cima já descreve o cartão.

  > "Gradiente em três estágios — fecha em preto quase opaco no último stop, senão fotos claras/quentes vazam sob o texto."
  - 💡 Explicação Leiga: A linha desenha um escurecimento gradual sobre a foto. Sem ele, o texto branco sumiria em fotos claras.

  > "Badge translúcido flutuando sobre a foto de um [PhotoHeroCard] (nota, status...) — vidro fosco escuro, mesmo estilo do `FavoriteButtonWidget` em modo `frosted`."
  - 💡 Explicação Leiga: Esta classe desenha uma etiqueta translúcida sobre a foto.

### 📂 ARQUIVO: lib/core/ui/widgets/profile_page_scaffold.dart

- ⚙️ Função: Monta a tela de Perfil, compartilhada pelo consumidor e pelo comerciante.
- 💬 Comentários Removidos:

  > "Item de menu da seção 'Minha Conta' — a única parte da tela de perfil que difere de verdade entre consumidor e comerciante."
  - 💡 Explicação Leiga: Esta classe define uma opção do menu do perfil.

  > "Cor de destaque opcional (ex: vermelho pra 'Excluir conta') — null usa o tratamento neutro padrão da lista."
  - 💡 Explicação Leiga: A linha permite pintar de vermelho a opção de apagar a conta.

  > "Scaffold genérico de perfil, compartilhado entre consumidor e comerciante — as duas telas eram ~85% código idêntico, variando só cor de destaque, itens de 'Minha Conta', a página de 'Como funciona' e as métricas/carrossel de destaque no topo (favoritos para consumidor, lojas próprias para comerciante)."
  - 💡 Explicação Leiga: Esta classe monta a tela de Perfil para os dois tipos de usuário. Só o conteúdo do topo e do menu muda.

  > "Busca a sessão salva e devolve a imagemUrl do usuário (ou null)."
  - 💡 Explicação Leiga: A linha recebe a função que busca a foto de perfil.

  > "Hook extra no logout (ex: limpar favoritos do consumidor)."
  - 💡 Explicação Leiga: A linha permite executar algo a mais na hora de sair da conta.

  > "Exclui a conta no backend (DELETE /comerciantes|consumidores/{id}) — hard delete definitivo, mesmo endpoint usado pela Web. `null` esconde a opção em Configurações (hoje é o caso do comerciante, cujo endpoint ainda responde 409 por dependências não limpas no backend)."
  - 💡 Explicação Leiga: A linha recebe a função que apaga a conta. A opção fica escondida para o comerciante, porque o servidor ainda recusa.

  > "Toque em qualquer um dos círculos de avatar — abre 'Editar Perfil'."
  - 💡 Explicação Leiga: A linha define o que acontece ao tocar na foto de perfil.

  > "Título da seção de destaque ('Minhas Lojas' para o comerciante)."
  - 💡 Explicação Leiga: A linha guarda o título da seção do topo do perfil.

  > "Toque em 'ver tudo' ao lado do título da seção de destaque — null esconde o link (ex: comerciante não tem uma tela de listagem própria)."
  - 💡 Explicação Leiga: A linha define o link "ver tudo". Ele fica escondido quando não há tela de listagem.

  > "Estado vazio da seção de destaque. Um vazio que só constata ('nada aqui') faz o app parecer abandonado; com ícone, título e uma ação, ele vira o primeiro passo — por isso os quatro campos, não só a frase."
  - 💡 Explicação Leiga: A linha guarda a mensagem que aparece quando não há favoritos ou lojas.

  > "Rótulo e ação do botão do estado vazio — `null` nos dois deixa o bloco só informativo."
  - 💡 Explicação Leiga: A linha define o botão que aparece na seção vazia.

  > "Notifica quando a seção de destaque deve ser buscada de novo (ex: `FavoritesManager.instance` no consumidor) — sem isso, a busca roda só uma vez no `initState`, e como esta página vive dentro de um `IndexedStack` (nunca é recriada ao trocar de aba), favoritar/desfavoritar em outra aba deixava esta seção com uma foto antiga — inclusive mostrando uma loja já desfavoritada."
  - 💡 Explicação Leiga: A linha avisa a tela quando os favoritos mudam em outra aba. Sem isso a lista ficava desatualizada.

  > "Recarga adicional no 'puxe para atualizar', para o que só a página que hospeda este scaffold conhece — a Atividade do consumidor, por exemplo. A foto e a seção de destaque já são recarregadas aqui dentro."
  - 💡 Explicação Leiga: A linha permite que cada tela recarregue algo a mais ao puxar para atualizar.

  > "Mantém o fallback com as iniciais do nome."
  - 💡 Explicação Leiga: A linha mantém as iniciais do nome no lugar da foto quando não há foto.

  > "Puxar para atualizar: as duas buscas do perfil (foto e seção de destaque). Serve aos dois papéis, porque este scaffold é o perfil do consumidor e o do comerciante — a foto pode ter sido trocada em outro cliente, e a seção de destaque (favoritos / lojas) muda por fora. Quem hospeda pode ter mais o que recarregar (a Atividade do consumidor, por exemplo); esse extra fica com a página, via [ProfilePageScaffold.onRefreshExtra]."
  - 💡 Explicação Leiga: A função recarrega a foto e a seção do topo do perfil.

  > "A fileira de cards de estatística saiu daqui: o perfil ficou restrito à conta, e os números do comerciante vivem na aba Estatísticas."
  - 💡 Explicação Leiga: A linha deixa apenas um espaço em branco. Os números foram movidos para outra aba.

  > "Sair não é ação primária (ninguém abre o perfil para sair) nem destrutiva — é `secondary`. Antes cada papel pintava o botão de um jeito: preto sólido no consumidor, vermelho desbotado no comerciante, sem que a diferença significasse nada."
  - 💡 Explicação Leiga: A linha desenha o botão de sair em estilo neutro, igual para os dois tipos de usuário.

  > "Cabeçalho inspirado no padrão avatar-à-esquerda + nome em destaque de apps de referência (ex: iFood) — substitui a saudação genérica 'Bem-vindo!' pelo e-mail, que é informação de verdade sobre a conta."
  - 💡 Explicação Leiga: A função desenha o topo do perfil com foto, nome e e-mail.

  > "Superfície do tema, não a cor de papel a 10%: no escuro, um fundo `ink`/vermelho tão diluído somia contra a tela e levava a inicial junto."
  - 💡 Explicação Leiga: A linha usa uma cor de fundo sólida atrás da inicial do nome.

  > "Sem foto (ou com foto quebrada), o 'vazio' deste avatar não é um ícone: é a inicial do nome."
  - 💡 Explicação Leiga: A linha mostra a primeira letra do nome quando não há foto.

  > "Isolamento de rebuild: só este ícone escuta o ThemeController — o resto do header (nome, avatar) não reconstrói quando o usuário troca de tema."
  - 💡 Explicação Leiga: A linha faz apenas o botão de tema ser redesenhado quando o tema muda.

  > "`brandContent`: vermelho como texto sobre a superfície da tela — no escuro o tom puro rende 3,28:1."
  - 💡 Explicação Leiga: A linha usa o vermelho ajustado para texto, legível nos dois temas.

  > "Mesma altura do carrossel que vai ocupar este espaço, escalada junto com ele — um placeholder parado faria a página pular ao carregar."
  - 💡 Explicação Leiga: A linha reserva a altura exata do carrossel. Assim a página não pula quando o conteúdo chega.

  > "Duas seções rotuladas — 'Minha Conta' (os atalhos que variam por papel) e 'Configurações' (uma única porta de entrada pra [SettingsPage]). Antes era uma lista única achatada de seis itens, que misturava atalhos de conteúdo do usuário ('Minhas avaliações') com ajustes do app ('Permissões de Localização', 'Termos') sem nenhuma separação — os quatro itens de ajuste migraram pra tela dedicada."
  - 💡 Explicação Leiga: A função desenha o menu do perfil em dois grupos separados.

### 📂 ARQUIVO: lib/core/ui/widgets/rating_stars.dart

- ⚙️ Função: Desenha a fileira de estrelas que mostra a nota de uma loja.
- 💬 Comentários Removidos:

  > "Fileira de estrelas de leitura (não é seletor — para avaliar, ver a tela de avaliação). Existe porque cada tela desenhava a própria fileira com `Icons.star_rounded`/`Icons.star_border_rounded` do Material: dentro de um card cheio de ícones Phosphor, a estrela do Material entrega outro peso de traço e outro raio de canto — o tipo de mistura que o app acabou de eliminar em todo o resto da iconografia. A estrela cheia usa a variante Fill e a vazia a Regular: o contorno vazado marca a posição sem competir com as preenchidas, que é justamente o que a versão anterior perdia ao usar dois ícones de peso parecido."
  - 💡 Explicação Leiga: Esta classe desenha estrelas apenas para leitura. Elas usam a mesma família de ícones do resto do app.

  > "Nota de 0 a [max]. Frações são arredondadas para baixo — meia estrela só entra quando o backend passar a devolver meia nota por avaliação individual (hoje `nota` é inteiro)."
  - 💡 Explicação Leiga: A linha recebe a nota. Valores quebrados são arredondados para baixo.

  > "Rótulo lido por leitores de tela no lugar das cinco estrelas soltas. `null` usa 'Nota X de Y'."
  - 💡 Explicação Leiga: A linha faz o leitor de tela dizer a nota em uma frase, em vez de listar cinco estrelas.

  > "Estrela vazia em amarelo cheio parecia 'meio preenchida'; o contorno translúcido lê como trilho, não como nota."
  - 💡 Explicação Leiga: A linha deixa as estrelas vazias mais claras, para não parecerem preenchidas pela metade.

  > "Selo com a nota média (`4,8`) sobre fundo amarelo suave. [nota] nula é loja sem avaliação: mostra 'Novo' em vez de `0,0` — zero é uma nota ruim, ausência de nota não é."
  - 💡 Explicação Leiga: Esta classe desenha a etiqueta com o número da nota. Lojas sem avaliação aparecem como "Novo".

  > "Compacta para caber em cabeçalho de card."
  - 💡 Explicação Leiga: A linha deixa a etiqueta menor, para caber no topo de um cartão.

  > "ratingText (não `rating` puro): amarelo sobre amarelo a 15% não passa em contraste."
  - 💡 Explicação Leiga: A linha usa o amarelo escuro no número. O amarelo claro seria ilegível.

### 📂 ARQUIVO: lib/core/ui/widgets/semantic_tap_area.dart

- ⚙️ Função: Torna qualquer elemento tocável e descrito corretamente para o leitor de tela.
- 💬 Comentários Removidos:

  > "Substitui `GestureDetector` cru nos controles icon-only do app (favoritar, chips de categoria, etc.) — sem isso, esses controles não têm nenhum nó de semântica (diferente de `InkWell`/`IconButton`/`ElevatedButton`, que geram semântica de botão automaticamente), então leitores de tela (TalkBack/VoiceOver) os ignoram ou não anunciam como interativos. Cancelamento de toque: A ação nunca dispara no toque-baixa: ela vive no `onTap`, que só acontece quando o dedo levanta dentro do alvo. Arrastar pra fora antes de soltar aborta — é o que permite desistir de um toque errado, e é o que o critério 2.5.2 do WCAG (Pointer Cancellation) exige. Isso já valia com o `GestureDetector` cru, mas era invisível: sem mudança de aparência ao pressionar, ninguém descobre que dá pra desistir. Por isso [pressFeedback] existe — `onTapDown`/`onTapUp`/`onTapCancel` aqui mudam só a aparência, jamais executam a ação. Ao arrastar pra fora, o controle volta ao normal antes de soltar, mostrando que o toque foi descartado. [onTap] nulo desativa o toque (ex: chip em modo somente-leitura) — nesse caso o nó de semântica também não é anunciado como botão, pra não sugerir uma ação que não existe, e o feedback de pressão não roda."
  - 💡 Explicação Leiga: Esta classe transforma qualquer desenho em um botão de verdade. A ação só acontece quando o dedo levanta em cima do alvo.

  > "Complemento lido depois do rótulo pelo leitor de tela — o resultado da ação quando ele não é óbvio pelo rótulo ('abre o mapa em tela cheia'). Não repita a palavra 'botão': os leitores já anunciam o papel sozinhos."
  - 💡 Explicação Leiga: A linha guarda uma explicação extra falada pelo leitor de tela.

  > "Esmaece e encolhe levemente enquanto pressionado. Desligue apenas quando o próprio [child] já reagir ao toque (ex: um `InkWell` com ripple por dentro), pra não empilhar dois feedbacks."
  - 💡 Explicação Leiga: A linha liga o efeito visual de pressionar. Ele é desligado quando o elemento já tem efeito próprio.

  > "Curto de propósito: acima disso a resposta ao toque parece atrasada."
  - 💡 Explicação Leiga: A linha define que o efeito de toque dura 90 milésimos de segundo.

  > "'Reduzir movimento' (iOS e Android): quem liga essa opção do sistema sente enjoo/desconforto com elementos que se mexem. O esmaecimento continua — ele é a informação; a escala é só o enfeite."
  - 💡 Explicação Leiga: A linha desliga o encolhimento para quem pediu menos animações no celular. O clareamento continua.

  > "A ação fica só aqui: `onTap` = dedo levantou dentro do alvo."
  - 💡 Explicação Leiga: A linha define o único ponto onde a ação é executada.

  > "Os três abaixo mexem exclusivamente no visual."
  - 💡 Explicação Leiga: As linhas seguintes só mudam a aparência, sem executar nada.

### 📂 ARQUIVO: lib/core/ui/widgets/stacked_card_carousel.dart

- ⚙️ Função: Desenha o carrossel de cartões empilhados como um baralho.
- 💬 Comentários Removidos:

  > "Categoria principal da loja. Opcional: o carrossel do comerciante ('Minhas Lojas') não tem o que dizer aqui, e o chip simplesmente não aparece."
  - 💡 Explicação Leiga: A linha guarda a categoria da loja. Ela pode ficar vazia.

  > "Nota média, já como número — a formatação (`4.0`, `Novo`) é do card."
  - 💡 Explicação Leiga: A linha guarda a nota como número. O texto é montado depois.

  > "Carrossel de cards empilhados (efeito 'baralho'): o card da frente é substituído automaticamente pelo de trás a cada [autoAdvanceInterval], e o usuário pode deslizar com o dedo pra trocar na hora — o que acontecer primeiro reinicia o temporizador, pra não 'atropelar' o gesto manual com um avanço automático logo em seguida. O empilhamento é feito por deslocamento vertical + largura decrescente (não por escala a partir do centro) — assim os cards de trás realmente aparecem espiando por baixo do card da frente, em vez de só encolher escondidos atrás dele."
  - 💡 Explicação Leiga: Esta classe desenha cartões empilhados que trocam sozinhos. O usuário também pode trocar deslizando o dedo.

  > "Recuo horizontal do card da frente em relação às bordas do carrossel — aumentar isso estreita o card (os de trás recuam ainda mais a partir deste valor, ver [_passoRecuoHorizontal])."
  - 💡 Explicação Leiga: A linha define a distância do cartão até as bordas laterais.

  > "Cada profundidade soma este deslocamento vertical e este acréscimo de recuo horizontal em relação ao card da frente (profundidade 0)."
  - 💡 Explicação Leiga: A linha define o quanto cada cartão de trás desce e estreita.

  > "ValueNotifier (não campo + setState) de propósito: um drag horizontal dispara onHorizontalDragUpdate a cada amostra do ponteiro (60+ vezes por segundo) — setState nesse ritmo reconstruía os 3 cards empilhados (foto, texto, sombra...) inteiros a cada evento, quando só a translação do card da frente muda. O ValueListenableBuilder em _buildSlot isola esse rebuild só na translação."
  - 💡 Explicação Leiga: A linha guarda a posição do dedo durante o arraste. Apenas o deslocamento é redesenhado, não os cartões inteiros.

  > "`width: double.infinity` é necessário: todos os filhos do Stack são `Positioned`, então o Stack não tem nada para se dimensionar e colapsa quando o pai passa largura frouxa (uma `Column` com `crossAxisAlignment.start`, por exemplo). O resultado era o card quase colado nas bordas, ignorando o `horizontalPadding`."
  - 💡 Explicação Leiga: A linha força a largura total. Sem ela o carrossel encolhia e ignorava as margens.

  > "Altura do card da frente + o quanto os cards de trás 'espiam' por baixo dele."
  - 💡 Explicação Leiga: A linha soma a altura total ocupada pela pilha de cartões.

  > "`AnimatedPositioned` PRECISA ser filho direto do `Stack`. Antes, o card da frente vinha embrulhado em `GestureDetector` > `Transform` e o de trás em `IgnorePointer`, então nenhum dos dois era filho direto: o `left`/`right` era descartado, o `Stack` media os filhos com restrição frouxa e o `SizedBox(width: double.infinity)` de dentro do card esticava até a borda da tela. Era essa a causa do carrossel colado nas laterais — o `horizontalPadding` estava correto, só nunca chegava a ser aplicado. O gesto e a translação agora ficam DENTRO do Positioned."
  - 💡 Explicação Leiga: A linha posiciona o cartão diretamente dentro da pilha. Antes as margens laterais eram ignoradas por causa da ordem dos elementos.

  > "`conteudo` (foto + texto do card da frente) é passado como `child` do builder — construído uma vez só, não a cada delta de drag; só o Transform.translate em volta dele é reconstruído."
  - 💡 Explicação Leiga: A linha monta o conteúdo do cartão uma vez só. Durante o arraste apenas a posição muda.

  > "Silhueta lisa (sem foto) dos cards atrás do card da frente — mostrar a imagem deles também ficaria poluído, já que só uma fatia fina aparece."
  - 💡 Explicação Leiga: Esta classe desenha os cartões de trás como formas lisas, sem foto.

  > "Card da frente: foto em sangria total com as informações da loja apoiadas sobre um véu escuro no rodapé. Antes era um banner branco em cápsula com só o nome dentro. O banner resolvia o contraste (texto escuro sobre superfície opaca), mas custava caro: tapava um terço da foto e, principalmente, o card inteiro dizia apenas qual loja é — nada sobre o que ela é nem quanto vale. Numa pilha de favoritos, que é uma lista de escolhas, é justamente isso que diferencia um item do outro. O véu em gradiente faz o mesmo trabalho de contraste sem tapar nada: ele escurece só a faixa onde o texto se apoia, e é o que garante branco legível tanto sobre uma foto clara (céu, parede branca) quanto sobre uma escura. Sem ele, o texto seria branco-sobre-foto-qualquer — que é sorte, não contraste."
  - 💡 Explicação Leiga: Esta classe desenha o cartão da frente com foto inteira. O texto fica sobre uma faixa escurecida no rodapé.

  > "Decorativa (sem `semanticLabel`): o nome da loja aparece como texto logo abaixo."
  - 💡 Explicação Leiga: A linha deixa a foto sem descrição falada, porque o nome já está escrito.

  > "Véu de leitura. Começa transparente na metade de cima pra não 'sujar' a foto e fecha em preto quase sólido no rodapé, onde o texto branco se apoia."
  - 💡 Explicação Leiga: A linha desenha o escurecimento gradual sobre a foto.

  > "Branco literal, não `primaryText`: o fundo aqui é o véu escuro, que é o mesmo nos dois temas — um token que inverte deixaria texto escuro sobre preto no tema claro."
  - 💡 Explicação Leiga: A linha fixa o texto em branco. Uma cor que muda com o tema ficaria ilegível sobre o véu escuro.

  > "Afordância de 'abre alguma coisa': o card inteiro é tocável, mas sem nenhuma marca disso ele lê como ilustração."
  - 💡 Explicação Leiga: A linha desenha uma marca visual indicando que o cartão pode ser tocado.

  > "Selo translúcido sobre o véu do card: categoria e nota. Branco a 22% em vez de uma cápsula opaca — o objetivo é marcar a informação sem abrir mais dois blocos sólidos por cima da foto. Sobre o véu (preto a 85%) o resultado é escuro o suficiente pra sustentar o texto branco em negrito."
  - 💡 Explicação Leiga: Esta classe desenha etiquetas translúcidas com a categoria e a nota.

### 📂 ARQUIVO: lib/core/ui/widgets/step_progress_header.dart

- ⚙️ Função: Mostra em que etapa de um cadastro o usuário está.
- 💬 Comentários Removidos:

  > "Progresso de um fluxo em etapas: trilhos preenchidos + 'Etapa 2 de 3'. Num cadastro dividido em passos, a pergunta que trava a pessoa não é 'o que preencho agora?', é 'quanto falta?'. Sem essa resposta, dividir o formulário só esconde o tamanho dele — e esconder o esforço restante é o que faz alguém abandonar no meio. Genérico de propósito: sabe contar etapas, não sabe o que são. Serve a qualquer fluxo que venha depois."
  - 💡 Explicação Leiga: Esta classe desenha barras que mostram o progresso. Ela também escreve "Etapa 2 de 3".

  > "Etapa atual, começando em zero."
  - 💡 Explicação Leiga: A linha guarda o número da etapa atual.

  > "Nome da etapa ('Sua loja'), mostrado ao lado da contagem. `null` deixa só os trilhos e o 'Etapa X de Y'."
  - 💡 Explicação Leiga: A linha guarda o nome da etapa, que é opcional.

  > "Etapas já vencidas e a atual ficam preenchidas: o trilho mede o caminho andado, não só onde se está."
  - 💡 Explicação Leiga: A linha pinta de vermelho todas as etapas já concluídas e a atual.

### 📂 ARQUIVO: lib/core/ui/widgets/theme_mode_sheet.dart

- ⚙️ Função: Abre o painel para escolher entre tema claro, escuro ou automático.
- 💬 Comentários Removidos:

  > "Abre um bottom sheet com as três opções de tema e aplica a escolha via [ThemeController.instance] — chame a partir de qualquer tela de configurações/perfil."
  - 💡 Explicação Leiga: A função mostra as três opções de tema e aplica a escolhida.

  > "Isolamento de rebuild: só esta lista escuta o ThemeController. O título acima e os paddings do sheet não precisam reconstruir a cada troca de tema."
  - 💡 Explicação Leiga: A linha faz apenas a lista de opções ser redesenhada quando o tema muda.

### 📂 ARQUIVO: lib/core/ui/widgets/unsaved_changes_guard.dart

- ⚙️ Função: Impede que o usuário saia de uma tela e perca o que digitou sem querer.
- 💬 Comentários Removidos:

  > "Diálogo genérico de confirmação de saída, usado tanto para formulários com alterações pendentes quanto para operações em andamento (ex: cálculo de rota). Devolve `true` se o usuário confirmou que quer sair mesmo assim."
  - 💡 Explicação Leiga: A função pergunta se o usuário quer mesmo sair da tela.

  > "Pergunta 'Deseja sair sem salvar?' antes de descartar uma edição em andamento. Devolve `true` se o usuário confirmou que quer sair."
  - 💡 Explicação Leiga: A função avisa que existem mudanças não salvas.

  > "Pergunta antes de sair de uma tela enquanto uma rota está sendo calculada — o cálculo (chamada ao OSRM) é cancelado se o usuário confirmar a saída."
  - 💡 Explicação Leiga: A função avisa que sair vai cancelar o cálculo do caminho no mapa.

  > "Envolve uma tela e intercepta a saída (gesto/botão de voltar do Android) enquanto [hasUnsavedChanges] for `true`, pedindo confirmação — via [confirmDialog] — em vez de descartar/cancelar silenciosamente. [hasUnsavedChanges] é um [ValueListenable] (não um `bool` simples) de propósito: o rebuild fica isolado no [ValueListenableBuilder] interno, que envolve só o [PopScope] — quem chama atualiza o valor a cada tecla digitada sem precisar de `setState` na tela inteira (formulário, galeria, lista de avaliações etc.) só para manter esse booleano em dia."
  - 💡 Explicação Leiga: Esta classe intercepta o botão de voltar. A tela inteira não é redesenhada a cada letra digitada.

  > "`child` é passado aqui (não recriado no builder) — o Flutter reusa a mesma instância entre notificações, então `cachedChild` nunca muda de identidade e a árvore abaixo do guard não reconstrói junto."
  - 💡 Explicação Leiga: A linha reaproveita o conteúdo da tela. Assim ele não é montado de novo a cada mudança.

### 📂 ARQUIVO: lib/core/ui/widgets/wizard_footer.dart

- ⚙️ Função: Desenha o rodapé fixo com os botões "Voltar" e "Continuar" dos cadastros em etapas.
- 💬 Comentários Removidos:

  > "Rodapé fixo de um fluxo em etapas: avançar à direita, voltar à esquerda. O botão que conclui o fluxo nunca rola para fora da tela. Num formulário longo, o CTA fica no fim de uma rolagem que a pessoa precisa descobrir; aqui ele está sempre à mão, e é o elemento de maior contraste da tela — o único lugar onde a cor cheia da marca aparece. Use como `Scaffold.bottomNavigationBar`: assim o próprio Scaffold o levanta junto com o teclado, sem cálculo de `viewInsets` na mão."
  - 💡 Explicação Leiga: Esta classe desenha os botões fixos no rodapé. Eles ficam sempre visíveis, mesmo com o formulário longo.

  > "`null` desabilita (ex: envio em curso ou etapa inválida)."
  - 💡 Explicação Leiga: A linha desativa o botão de avançar quando a etapa não está pronta.

  > "`null` esconde o botão de voltar — o caso da primeira etapa, onde não há passo anterior e um botão desabilitado só ocuparia espaço."
  - 💡 Explicação Leiga: A linha esconde o botão de voltar na primeira etapa.

  > "Rótulo do secundário. 'Voltar' num fluxo em etapas, 'Cancelar' quando a barra fecha um formulário — a ação é a mesma forma, o significado não."
  - 💡 Explicação Leiga: A linha permite trocar o texto do botão da esquerda.

  > "`divider`, o traço mais fraco do sistema: aqui ele só separa o rodapé do conteúdo que passa por baixo. Uma borda forte ou uma sombra transformaria a barra num objeto flutuante, que é peso visual que este fluxo não quer."
  - 💡 Explicação Leiga: A linha desenha uma linha fina separando o rodapé do conteúdo.

  > "O avanço domina a linha: dois botões de mesma largura leem como duas opções equivalentes, e continuar não é opcional."
  - 💡 Explicação Leiga: A linha deixa o botão de avançar duas vezes mais largo que o de voltar.

### 📂 ARQUIVO: lib/core/ui/widgets/xfile_image.dart

- ⚙️ Função: Mostra a prévia de uma foto que o usuário acabou de escolher, antes de enviar.
- 💬 Comentários Removidos:

  > "Exibe a pré-visualização de um [XFile] recém-escolhido pelo image_picker. Usa bytes (`Image.memory`) em vez de `Image.file`, já que `dart:io.File` não funciona no Flutter Web."
  - 💡 Explicação Leiga: Esta classe mostra a foto escolhida lendo o conteúdo dela. Esse jeito funciona também no navegador.

---

## 📊 PARTE 6 — ESTATÍSTICAS DO COMERCIANTE

### 📂 ARQUIVO: lib/features/analytics/presentation/controllers/analytics_controller.dart

- ⚙️ Função: Busca e calcula todos os números do painel de estatísticas do comerciante.
- 💬 Comentários Removidos:

  > "Janela de tempo do painel: recorta as denúncias e a divisão de visitantes entre as lojas."
  - 💡 Explicação Leiga: Esta lista define os períodos que o comerciante pode escolher, como 7 ou 30 dias.

  > "Quantas avaliações a loja recebeu com determinada nota."
  - 💡 Explicação Leiga: A classe guarda um par: a nota e quantas vezes ela foi dada.

  > "Quantas denúncias chegaram por um mesmo motivo."
  - 💡 Explicação Leiga: A classe guarda um par: o motivo da denúncia e quantas vezes ele apareceu.

  > "Denúncias do período, prontas para leitura. Separa em aberto de encerradas porque as duas dizem coisas opostas ao comerciante: uma denúncia arquivada pela moderação não é um problema dele, e somar tudo num número só transformaria um caso resolvido em dívida permanente na tela."
  - 💡 Explicação Leiga: A classe separa denúncias ainda abertas das já encerradas. Casos resolvidos não são contados como problema atual.

  > "Contra o período anterior de mesma duração. `null` sem base de comparação."
  - 💡 Explicação Leiga: A linha guarda a variação percentual. Fica vazia quando não há período anterior para comparar.

  > "`true` quando a busca falhou. Diferente de [limpo]: uma coisa é não ter denúncia, outra é não ter conseguido perguntar — anunciar 'nada por aqui' sem saber seria dar ao comerciante uma tranquilidade que não se apurou."
  - 💡 Explicação Leiga: A linha marca que a busca falhou. O app não diz "nenhuma denúncia" quando não conseguiu consultar.

  > "Tudo que a tela desenha, já calculado. Sem `Color` e sem widget: as cores entram na montagem das fatias, onde existe tema (ver [DonutSlice])."
  - 💡 Explicação Leiga: A classe guarda todos os números já prontos para a tela. As cores são escolhidas depois.

  > "Estado da tela de Estatísticas: escopo, período e a busca que os alimenta. Existe como `ChangeNotifier` (e não como `setState` na página) porque a mesma busca é disparada por três gatilhos diferentes — troca de loja, troca de período e recarga manual — e todos precisam passar pelo mesmo controle de corrida."
  - 💡 Explicação Leiga: Esta classe controla a tela de estatísticas. Ela evita que três buscas simultâneas se atrapalhem.

  > "Dono das lojas. `null` (sessão perdida) desliga o bloco de denúncias — a rota é por comerciante, não por loja."
  - 💡 Explicação Leiga: A linha guarda o número do comerciante. Sem ele, o bloco de denúncias não aparece.

  > "`null` = 'Dados gerais' (todas as lojas do comerciante)."
  - 💡 Explicação Leiga: A linha guarda qual loja está sendo vista. Vazio significa todas as lojas somadas.

  > "Descarta respostas de buscas superadas. Trocar de período duas vezes seguidas deixa duas requisições em voo, e a primeira pode chegar por último — sem este token, a tela terminaria mostrando o período errado."
  - 💡 Explicação Leiga: A linha numera cada busca. Respostas antigas que chegam atrasadas são ignoradas.

  > "Lojas do escopo atual: uma só, ou todas quando nenhuma está selecionada."
  - 💡 Explicação Leiga: A linha devolve a lista de lojas que estão sendo contadas no momento.

  > "Chamado pelo pai quando a lista de lojas muda (loja criada, excluída ou renomeada). Se a loja em foco sumiu, o escopo volta para 'gerais' — um filtro apontando para loja inexistente deixaria a tela vazia sem explicar. Só rebusca quando o conjunto de lojas mudou: renomear uma loja altera o rótulo do seletor, mas não os números, e uma rodada de requisições para redesenhar o mesmo gráfico é rede gasta à toa."
  - 💡 Explicação Leiga: A função atualiza a lista de lojas. Ela só busca de novo se as lojas realmente mudaram.

  > "Início do período exibido. O período anterior de mesma duração (a base do delta) é calculado a partir daqui, dentro do resumo de denúncias."
  - 💡 Explicação Leiga: A linha calcula a data inicial do período escolhido.

  > "Falha de uma loja não pode zerar a rosca das outras: cada busca devolve lista vazia no lugar de propagar a exceção. Só quando todas falham é que a tela vira erro — senão o painel mostraria 'nenhuma avaliação' com ar de dado real enquanto a rede está fora."
  - 💡 Explicação Leiga: A linha conta quantas buscas falharam. A tela só mostra erro se todas falharem.

  > "Uma chamada só, independente do escopo: a rota de denúncias é por comerciante, e o recorte por loja é feito aqui embaixo."
  - 💡 Explicação Leiga: A linha busca todas as denúncias de uma vez. A separação por loja é feita depois, no aplicativo.

  > "`null` (e não lista vazia) para o card poder dizer 'não deu para carregar' em vez de 'nada por aqui' — anunciar ausência de denúncia sem ter conseguido perguntar seria mentir para o comerciante."
  - 💡 Explicação Leiga: A linha devolve vazio quando a busca falha, e não uma lista sem itens.

  > "Média calculada da mesma lista que alimenta a rosca. A agregação do backend (`GET /lojas/{id}/completa`) seria outra fonte, e duas fontes discordando na mesma tela — a média dizendo 4,8 e as fatias mostrando outra coisa — é pior que recalcular aqui."
  - 💡 Explicação Leiga: A linha calcula a média a partir das mesmas notas do gráfico. Assim os dois números nunca se contradizem.

  > "Recorta as denúncias pelo escopo e pelo período, e conta motivos. [denuncias] nulo significa que a busca falhou — vira [DenunciaResumo.naoCarregou], não um resumo vazio."
  - 💡 Explicação Leiga: A função filtra as denúncias pelo período e conta os motivos.

  > "Fim do dia de hoje: `dataDenuncia` é LocalDateTime, e comparar contra a meia-noite descartaria tudo que foi denunciado hoje."
  - 💡 Explicação Leiga: A linha inclui o dia de hoje inteiro na contagem.

  > "Sem data não dá para situar no tempo: entra no período atual, que é o que a tela está mostrando — esconder seria pior que aproximar."
  - 💡 Explicação Leiga: A linha inclui denúncias sem data no período atual, em vez de descartá-las.

  > "Meia-noite de hoje: as datas da API são dias, sem hora, e comparar com `DateTime.now()` deixaria o dia corrente sempre 'no futuro'."
  - 💡 Explicação Leiga: A função devolve a data de hoje zerada na meia-noite.

### 📂 ARQUIVO: lib/features/analytics/presentation/pages/merchant_analytics_page.dart

- ⚙️ Função: Desenha a tela com os gráficos e números da loja do comerciante.
- 💬 Comentários Removidos:

  > "Painel de estatísticas do comerciante. Substitui os cards de cor sólida que existiam no topo de 'Minha loja' e do Perfil. Aqueles respondiam 'quantos?'; nenhum respondia 'está subindo?' — que é a pergunta que faz o lojista abrir o app duas vezes no mesmo dia. O desenho segue o painel de atividade do consumidor: superfície neutra com borda de 1px e sem sombra, `Spacing.lg` nas laterais, número grande em `display` e período em `AppChoiceChip`. Cor só onde ela significa algo — a direção da variação, e a identidade de cada fatia das roscas."
  - 💡 Explicação Leiga: Esta classe desenha o painel de estatísticas. Ela mostra se os números estão subindo ou descendo.

  > "Lojas do comerciante, vindas da página que já as carregou (`MerchantHomePage`) — esta tela não repete a busca."
  - 💡 Explicação Leiga: A linha recebe a lista de lojas que já foi buscada por outra tela.

  > "`true` enquanto esta é a aba exibida. A página vive num `IndexedStack` — construída uma vez e nunca descartada —, então o `initState` não serve como gatilho de atualização: sem este aviso, os números ficariam parados no retrato do momento em que o app abriu. Mesmo mecanismo do painel de atividade do consumidor."
  - 💡 Explicação Leiga: A linha avisa quando esta aba fica visível. Sem esse aviso os números nunca seriam atualizados.

  > "Denúncias são consultadas por comerciante, não por loja — a rota devolve 403 para qualquer id que não seja o do próprio token."
  - 💡 Explicação Leiga: A linha usa o número do comerciante logado. O servidor recusa o pedido com outro número.

  > "Cada volta para esta aba refaz a busca. É o que faz uma visita recebida há pouco aparecer sem precisar reiniciar o app — o dado de acesso muda por fora, sem nenhuma ação do comerciante que pudesse servir de gatilho."
  - 💡 Explicação Leiga: A função busca os números de novo toda vez que a aba é aberta.

  > "A página vive num IndexedStack e nunca é recriada: quando o pai troca a lista (loja criada, excluída, renomeada), é por aqui que ela chega. A assinatura inclui o nome porque ele é o rótulo do seletor de escopo — quem decide se isso vale uma rebusca é o controller."
  - 💡 Explicação Leiga: A função cria um texto que identifica a lista de lojas. Ele serve para perceber quando a lista mudou.

  > "Aba não tem 'voltar'. O `AppBar` desenha a seta sozinho sempre que existe rota abaixo na pilha, e aqui ela sairia da home do lojista inteira — não desta tela."
  - 💡 Explicação Leiga: A linha esconde a seta de voltar. Ela levaria o usuário para fora da home inteira.

  > "Erro tem precedência sobre o dado velho só quando não há nada para mostrar — com um snapshot anterior em mãos, trocar a tela inteira por uma mensagem apagaria o que a pessoa estava lendo."
  - 💡 Explicação Leiga: A linha só mostra a tela de erro quando não há nenhum dado antigo na tela.

  > "Puxar para atualizar: além da volta para a aba, é o gesto que a pessoa já tenta por instinto quando quer saber se chegou visita agora."
  - 💡 Explicação Leiga: A linha liga o gesto de puxar para baixo e atualizar os números.

  > "`AlwaysScrollable`: sem isso o gesto de puxar não existe quando o conteúdo cabe na tela — justamente o caso da loja sem movimento, que é quem mais quer conferir se algo mudou."
  - 💡 Explicação Leiga: A linha permite puxar para atualizar mesmo quando a tela não rola.

  > "Denúncias do período. Sem nenhuma, o card não mostra um '0': mostra um selo de que está tudo certo. Um zero grande num card de denúncia lê como alerta à distância — a pessoa vê o rótulo 'Denúncias' em destaque e o coração dispara antes de ela ler o número. O selo diz a mesma coisa sem o susto. Com denúncias, o que importa não é só quantas, mas por quê (a rosca de motivos, que é o acionável) e quantas ainda estão de pé — caso arquivado pela moderação não é dívida do comerciante, e somá-lo ao total transformaria um problema encerrado em cobrança permanente."
  - 💡 Explicação Leiga: A função desenha o cartão de denúncias. Quando não há nenhuma, aparece um selo verde em vez do número zero.

  > "Nunca 'Nada por aqui' quando a busca falhou: seria dar uma tranquilidade que não foi apurada."
  - 💡 Explicação Leiga: A linha mostra uma mensagem diferente quando a busca falhou.

  > "Invertido: aqui subir é a má notícia."
  - 💡 Explicação Leiga: A linha usa o modo invertido de cores. Aumento de denúncias aparece em vermelho.

  > "Escala de nota: verde no 5, vermelho no 1, âmbar no meio. É a mesma leitura de 'bom → ruim' da direção do delta, então as duas cores do card significam a mesma coisa."
  - 💡 Explicação Leiga: A função escolhe a cor de cada nota. Notas altas são verdes e notas baixas são vermelhas.

  > "Motivos de denúncia. Tons quentes, sem verde: aqui nenhuma fatia é boa notícia, e um motivo pintado de verde sugeriria o contrário. São cinco, o número exato de motivos que a API aceita."
  - 💡 Explicação Leiga: A linha lista cinco cores quentes para os motivos de denúncia.

  > "Pastilha de status das denúncias ('2 em análise', '5 já encerradas'). Ícone junto do texto, e não só cor: a diferença entre o que ainda pesa e o que já foi resolvido é a informação mais importante do card, e ela não pode depender de distinguir vermelho de verde."
  - 💡 Explicação Leiga: Esta classe desenha uma etiqueta com ícone e texto. O ícone permite entender sem depender da cor.

### 📂 ARQUIVO: lib/features/analytics/presentation/widgets/analytics_scope_selector.dart

- ⚙️ Função: Permite alternar o painel entre uma loja específica e todas as lojas juntas.
- 💬 Comentários Removidos:

  > "Alterna o painel entre dados gerais (todas as lojas somadas) e uma loja específica. Fica no AppBar, e não no corpo, porque não é um filtro entre outros: ele governa o que todos os números abaixo significam. Um controle solto no meio da lista de cards se perderia na rolagem, e daí o total de acessos passaria a ser lido como 'de tudo' quando é de uma loja só. Com uma loja só cadastrada, o seletor não aparece — não há o que alternar, e um menu de uma opção só é ruído."
  - 💡 Explicação Leiga: Esta classe desenha o seletor de loja no topo da tela. Ele some quando o comerciante tem apenas uma loja.

  > "`null` = dados gerais."
  - 💡 Explicação Leiga: A linha guarda a loja escolhida. Vazio significa todas as lojas.

  > "'Dados gerais' viaja pelo menu como este id falso, e não como `null`. `PopupMenuButton` trata `null` como cancelamento: o `showMenu` resolve com o valor escolhido, e ali um `null` é indistinguível de 'fechou o menu sem escolher' — o framework chama `onCanceled` e nunca `onSelected` (`material/popup_menu.dart`, no `.then` do `showMenu`). Com `int?` como tipo do menu, voltar para os dados gerais simplesmente não acontecia: o painel continuava preso na última loja. Id de loja é sempre positivo (chave do banco), então `-1` nunca colide."
  - 💡 Explicação Leiga: A linha usa o número menos um para representar "todas as lojas". O valor vazio era confundido com fechar o menu sem escolher.

  > "`initialValue` deixa o item ativo marcado ao abrir o menu — sem isso a única pista do escopo atual seria o rótulo do botão, que fica escondido atrás do próprio menu enquanto ele está aberto."
  - 💡 Explicação Leiga: A linha marca a opção atual quando o menu abre.

  > "Sem `onTap`: quem abre o menu é o PopupMenuButton em volta. Este nó existe para o leitor de tela anunciar o estado atual junto do botão."
  - 💡 Explicação Leiga: A linha existe apenas para o leitor de tela anunciar qual loja está selecionada.

  > "Marcação por forma, não só por peso da fonte: a diferença entre w500 e w700 não se percebe sem os dois itens lado a lado."
  - 💡 Explicação Leiga: A linha desenha um sinal de certo na opção escolhida.

### 📂 ARQUIVO: lib/features/analytics/presentation/widgets/analytics_section_card.dart

- ⚙️ Função: Desenha a moldura de cada bloco do painel de estatísticas.
- 💬 Comentários Removidos:

  > "Bloco de uma seção do painel: título, apoio opcional e conteúdo. A moldura é a mesma do card de atividade do consumidor (`_decoracaoCard` em `consumer_profile_page.dart`): `surface` + `Radii.xl` + borda de 1px, sem sombra. Não usa o `AppCard` porque aquele é um container clicável de lista/grade, com elevação — aqui o card é só um agrupador dentro de uma tela que já rola, e uma sombra por bloco empilharia relevo sem hierarquia."
  - 💡 Explicação Leiga: Esta classe desenha uma caixa com título e conteúdo. Ela não tem sombra porque serve apenas para agrupar.

  > "Uma linha explicando o que o número mede. Existe porque métrica sem definição é lida como outra coisa: 'visitantes' vira 'visualizações' na cabeça de quem lê, e o valor parece baixo demais."
  - 💡 Explicação Leiga: A linha guarda uma frase que explica o significado do número.

---

## 🔐 PARTE 7 — ENTRAR E CRIAR CONTA

### 📂 ARQUIVO: lib/features/auth/data/models/auth_response.dart

- ⚙️ Função: Guarda os dados que o servidor devolve quando o login dá certo.
- 💬 Comentários Removidos:

  > "`token`, `tipo` e `id` são obrigatórios: sem qualquer um deles não há sessão utilizável, e falhar aqui com [ParseException] nomeada é melhor do que gravar uma sessão pela metade (era o que `json['token'].toString()` fazia: um token nulo virava a string 'null' e só quebrava na requisição autenticada seguinte, como 401 sem explicação)."
  - 💡 Explicação Leiga: A função lê a resposta do login. Se faltar o crachá, o número ou o tipo, ela avisa o erro na hora.

### 📂 ARQUIVO: lib/features/auth/data/models/login_request.dart

- ⚙️ Função: Monta o pacote com e-mail, senha e tipo de conta enviado ao servidor no login.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

### 📂 ARQUIVO: lib/features/auth/data/services/auth_service.dart

- ⚙️ Função: Faz o login no servidor e guarda a sessão do usuário.
- 💬 Comentários Removidos:

  > "Autentica e persiste a sessão. Passa pelo [ApiClient] como todo o resto do app: o `ErrorInterceptor` já traduz 401 em `UnauthorizedException`, 5xx em `ServerException` e timeout em `NetworkException`. Antes, este método criava um `Dio` avulso por chamada — sem interceptors, com `validateStatus` próprio e um mapeamento de erro reimplementado à mão que chegava a expor o tipo interno da exceção Dart na tela ('Erro: DioException — ...'). `handle401: false` é essencial: aqui um 401 significa 'credenciais inválidas', não 'sessão expirada'. Sem isso, errar a senha ao trocar de conta derrubaria a sessão ainda válida no aparelho."
  - 💡 Explicação Leiga: A função envia e-mail e senha ao servidor. Errar a senha não desconecta a conta que já estava aberta.

  > "A API nem sempre devolve o e-mail no corpo do login; preserva o que foi digitado para a sessão não nascer sem esse campo."
  - 💡 Explicação Leiga: A linha guarda o e-mail digitado quando o servidor não devolve esse dado.

  > "signIn persiste E publica: nenhuma tela precisa reler o disco depois do login para saber quem entrou."
  - 💡 Explicação Leiga: A linha salva a sessão e avisa todas as telas ao mesmo tempo.

### 📂 ARQUIVO: lib/features/auth/presentation/pages/account_type_page.dart

- ⚙️ Função: Pergunta se a pessoa quer criar uma conta de cliente ou de comerciante.
- 💬 Comentários Removidos:

  > "Título fora da AppBar: na jornada de entrada, o título é o conteúdo principal da tela, não um rótulo de barra. Mesma abertura das telas de login e cadastro — a sequência inteira lê como um bloco só."
  - 💡 Explicação Leiga: A linha deixa a barra do topo vazia. O título aparece grande no corpo da tela.

  > "Saída para quem já tem conta: antes esta tela era um beco — quem chegava aqui vindo do onboarding só voltava pelo botão do topo, e a única porta para o login era o rodapé da própria tela de login, que ficava um passo atrás."
  - 💡 Explicação Leiga: Este bloco adiciona um link para quem já tem conta ir direto ao login.

### 📂 ARQUIVO: lib/features/auth/presentation/pages/consumer_register_page.dart

- ⚙️ Função: Formulário de cadastro para o cliente comum.
- 💬 Comentários Removidos:

  > "Encadeamento do teclado: cada campo manda o foco pro próximo, e o último envia o formulário. Antes todos abriam 'concluído', o que fechava o teclado a cada campo e obrigava a tocar de novo na tela."
  - 💡 Explicação Leiga: A linha liga os campos em sequência. A tecla do teclado pula para o próximo campo.

  > "O aceite dos termos virou um FormField (ver TermsCheckbox), então entra nesta mesma validação e o erro aparece embaixo do checkbox — antes era um toast no topo da tela, longe do que precisava ser corrigido."
  - 💡 Explicação Leiga: A linha valida o formulário inteiro, incluindo o aceite dos termos.

  > "Tira o foco pra o teclado não cobrir os campos em erro."
  - 💡 Explicação Leiga: A linha fecha o teclado para o usuário conseguir ver os campos com erro.

  > "Só o banner inline: antes a mesma frase aparecia duas vezes (banner + toast), e a versão do toast sumia sozinha antes de ser lida."
  - 💡 Explicação Leiga: A função mostra o erro apenas na faixa fixa, sem repetir em aviso flutuante.

  > "O papel da conta vira um rótulo discreto acima do título, em vez de tingir o próprio título de preto ou vermelho."
  - 💡 Explicação Leiga: A linha escreve "CONTA DE CLIENTE" em letras pequenas acima do título.

### 📂 ARQUIVO: lib/features/auth/presentation/pages/login_page.dart

- ⚙️ Função: Tela onde o usuário digita e-mail e senha para entrar.
- 💬 Comentários Removidos:

  > "Placeholder da recuperação de senha: a entrada já existe na tela para não deixar quem esqueceu a senha sem nenhuma pista do que fazer, mas o fluxo (código por e-mail + redefinição) ainda não tem backend no app."
  - 💡 Explicação Leiga: A função avisa que recuperar a senha ainda não está disponível no aplicativo.

  > "Validação pelo mesmo FormValidator das telas de cadastro — antes esta tela tinha regra própria (`email.contains('@')`), então 'a@b' passava aqui e era recusado no cadastro."
  - 💡 Explicação Leiga: A linha usa as mesmas regras de validação do cadastro.

  > "pushNamedAndRemoveUntil (não pushReplacementNamed) para limpar todo o histórico de navegação do Guest — sem isso o botão 'voltar' do celular retornava ao perfil Guest depois de logado."
  - 💡 Explicação Leiga: A linha apaga o histórico de telas ao entrar. O botão de voltar não leva mais à tela de visitante.

  > "Sem AuthHeroBand: o gradiente vermelho com bolhas coloridas competia com o formulário e era o elemento mais datado da tela. O que abre a tela agora é a tipografia."
  - 💡 Explicação Leiga: A linha remove a faixa colorida do topo. A tela agora abre com o título em texto.

  > "Revalida a cada tecla só depois da primeira tentativa: avisar 'e-mail inválido' enquanto a pessoa ainda está digitando a primeira letra é ruído."
  - 💡 Explicação Leiga: A linha só começa a validar o campo depois da primeira tentativa de enviar.

  > "Só 'campo obrigatório' aqui: as regras de força valem no cadastro. Aplicá-las no login barraria quem tem senha antiga, mais curta que a regra atual."
  - 💡 Explicação Leiga: A linha só confere se a senha foi preenchida. As regras de senha forte valem apenas no cadastro.

  > "Consumidor entra pelo CTA neutro; comerciante pelo vermelho — mesma distinção de papel do seletor acima."
  - 💡 Explicação Leiga: A linha muda a cor do botão conforme o tipo de conta escolhido.

### 📂 ARQUIVO: lib/features/auth/presentation/pages/merchant_register_page.dart

- ⚙️ Função: Formulário de cadastro para o dono de comércio.
- 💬 Comentários Removidos:

  > "Encadeamento do teclado — o formulário tem sete campos, é onde a falta do 'próximo' mais custava: era um toque a mais na tela por campo."
  - 💡 Explicação Leiga: A linha liga os sete campos em sequência para o teclado pular entre eles.

  > "O aceite entra na validação do Form (ver TermsCheckbox), então o erro aparece embaixo do checkbox em vez de um toast no topo da tela."
  - 💡 Explicação Leiga: A linha valida também o aceite dos termos junto com os outros campos.

  > "MerchantHomePage detecta que não há loja e redireciona para StoreRegisterPage"
  - 💡 Explicação Leiga: A linha leva o comerciante para a home. Lá ele é encaminhado para cadastrar a primeira loja.

  > "Só o banner inline: o par banner + toast repetia a mesma frase duas vezes, e a do toast sumia sozinha antes de ser lida."
  - 💡 Explicação Leiga: A função mostra o erro apenas na faixa fixa da tela.

  > "Rótulo de grupo do formulário. Em caixa alta e pequeno: separa as duas metades do cadastro sem competir com o título da tela, que é o único texto grande daqui."
  - 💡 Explicação Leiga: A função desenha um título pequeno em maiúsculas separando grupos de campos.

### 📂 ARQUIVO: lib/features/auth/presentation/widgets/account_type_card.dart

- ⚙️ Função: Desenha os dois cartões de escolha do tipo de conta.
- 💬 Comentários Removidos:

  > "Card de escolha do tipo de conta. Antes os dois cards eram blocos sólidos de cor — um preto, um vermelho — com sombra tingida da própria cor. Dois problemas: a tela virava dois retângulos berrantes disputando atenção (sem dizer qual escolher), e sombra colorida é o efeito que mais envelhece uma interface. Agora um dos cards é [highlighted] (fundo escuro sólido, o neutro forte da marca) e o outro é superfície neutra com traço de 1px. A hierarquia passa a existir — a maioria das pessoas que chega aqui é consumidora — e o vermelho fica reservado ao card secundário e ao seu CTA, o que mantém a proporção 60/30/10 da paleta."
  - 💡 Explicação Leiga: Esta classe desenha o cartão de escolha de conta. Um deles é destacado, porque é a opção mais comum.

  > "Rótulo pequeno acima do título ('PERFIL COMUM')."
  - 💡 Explicação Leiga: A linha guarda o texto pequeno que aparece acima do título do cartão.

  > "Card em destaque: fundo escuro sólido e CTA branco."
  - 💡 Explicação Leiga: A linha marca qual cartão recebe o destaque visual.

  > "O destaque só é um bloco escuro sólido no tema claro. No escuro, `ink` encosta no fundo e o card fica chapado — lá o destaque vira o degrau de superfície, que é o que significa 'elevado' num tema escuro."
  - 💡 Explicação Leiga: A linha muda a forma do destaque no tema escuro. O bloco preto sumiria contra o fundo escuro.

  > "Sobre o bloco sólido, tudo é branco em opacidades diferentes; fora dele, a hierarquia normal de texto do tema."
  - 💡 Explicação Leiga: A linha escolhe a cor do texto conforme o cartão ser destacado ou não.

  > "O card inteiro é clicável, e o CTA repete a ação para quem procura um botão — os dois levam ao mesmo lugar."
  - 💡 Explicação Leiga: A linha torna o cartão inteiro tocável, além do botão dentro dele.

  > "No claro, o destaque é o `ink` sólido da marca. No escuro esse mesmo tom encosta no fundo e o card fica chapado, então o destaque passa a ser o degrau de superfície (`surfaceAlt`) — que no tema escuro é justamente o que significa 'elevado'."
  - 💡 Explicação Leiga: A linha escolhe a cor de fundo do cartão conforme o tema.

  > "Quadrado de ícone ao lado de texto: acompanha a escala, senão vira um selo pequeno perdido ao lado de um título que dobrou."
  - 💡 Explicação Leiga: A linha faz o quadrado do ícone crescer junto com a letra.

  > "Claro: branco sobre o bloco escuro. Escuro: o CTA de alto contraste do tema — o card destacado continua sendo o que 'chama' mais, mesmo sem o bloco sólido."
  - 💡 Explicação Leiga: A linha escolhe o estilo do botão dentro do cartão conforme o tema.

### 📂 ARQUIVO: lib/features/auth/presentation/widgets/account_type_switch.dart

- ⚙️ Função: Desenha o seletor entre "Consumidor" e "Comerciante" na tela de login.
- 💬 Comentários Removidos:

  > "Seletor 'Consumidor / Comerciante' do login. A cor do segmento ativo carrega significado e é a mesma em toda a jornada de cada papel: preto para consumidor (o CTA neutro do app) e vermelho para comerciante. É o que faz o botão 'Entrar' logo abaixo mudar de cor junto — a pessoa vê para qual conta está entrando sem ler. Trilho com raio 12 (não pílula): o campo de e-mail logo abaixo tem a mesma forma, e os dois elementos passam a ler como um bloco só."
  - 💡 Explicação Leiga: Esta classe desenha o seletor de tipo de conta. A cor escolhida também aparece no botão de entrar.

  > "'CONSUMIDOR' ou 'COMERCIANTE'."
  - 💡 Explicação Leiga: A linha guarda qual tipo de conta está selecionado.

  > "Consumidor usa o neutro forte do tema (que inverte no escuro); comerciante usa o vermelho de marca, que vale nos dois temas."
  - 💡 Explicação Leiga: A linha escolhe a cor de cada opção do seletor.

  > "Segmentado, mesma leitura do seletor de tema: o ativo ganha uma superfície que o outro não tem, então o estado não depende só de cor."
  - 💡 Explicação Leiga: A linha dá um fundo próprio à opção ativa, além da cor diferente.

  > "Mesmo tratamento do seletor de tema: altura mínima."
  - 💡 Explicação Leiga: A linha define a altura mínima de 44 pontos para o toque.

### 📂 ARQUIVO: lib/features/auth/presentation/widgets/terms_checkbox.dart

- ⚙️ Função: Desenha a caixa de aceite dos termos com links para as políticas.
- 💬 Comentários Removidos:

  > "Aceite dos termos, com links para a política. Era ~50 linhas repetidas nas duas telas de cadastro, e o 'esqueci de aceitar' só aparecia como toast global no topo da tela — longe do checkbox e some sozinho. Aqui é um [FormField] de verdade: entra na validação do `Form`, e o erro aparece embaixo da linha que ele descreve."
  - 💡 Explicação Leiga: Esta classe desenha a caixa de aceite. O erro de "falta aceitar" aparece logo abaixo dela.

  > "Cor de preenchimento do checkbox marcado. `null` usa o neutro do tema (`selectedSurface`), que inverte no escuro; o cadastro de comerciante passa o vermelho de marca, que vale igual nos dois temas."
  - 💡 Explicação Leiga: A linha define a cor da caixinha marcada.

  > "Texto antes do primeiro link."
  - 💡 Explicação Leiga: A linha guarda a frase que vem antes do link.

  > "Segundo link, ligado por ' e a '. `null` deixa só o primeiro (é o caso do comerciante, que aceita apenas os Termos de Parceiro)."
  - 💡 Explicação Leiga: A linha permite um segundo link. O cadastro de comerciante usa apenas um.

  > "O 'check' acompanha o fundo escolhido: sobre a superfície clara do tema escuro, um check branco (o padrão do Material) seria invisível."
  - 💡 Explicação Leiga: A linha escolhe a cor do sinal de certo conforme o fundo da caixinha.

  > "Borda vermelha quando o aceite falta: o campo em erro precisa ser localizável sem ler o texto."
  - 💡 Explicação Leiga: A linha pinta a borda de vermelho quando o usuário não aceitou os termos.

  > "GestureDetector cru de propósito — este é a exceção à migração para SemanticTapArea. O texto contém dois links com `recognizer` próprio ('Termos de Uso', 'Política de Privacidade'); embrulhar tudo num nó `Semantics(button:)` colapsaria o bloco num único botão e esconderia os dois links do leitor de tela. Quem usa leitor alcança o controle pelo Checkbox ao lado, que já tem semântica própria — este toque é só uma área de conveniência."
  - 💡 Explicação Leiga: A linha usa um detector de toque simples. Um botão completo esconderia os dois links do leitor de tela.

---

## ⭐ PARTE 8 — AVALIAÇÕES

### 📂 ARQUIVO: lib/features/avaliacoes/data/models/avaliacao_model.dart

- ⚙️ Função: Guarda os dados de uma avaliação feita por um cliente.
- 💬 Comentários Removidos:

  > "Modelo de avaliação retornado pela API `/avaliacoes`."
  - 💡 Explicação Leiga: Esta classe guarda a nota, o comentário e o autor de uma avaliação.

  > "Foto de perfil de quem avaliou, como path cru da API (`/uploads/consumidores/x.jpg`). `null` em quem nunca enviou uma. O campo sempre veio no JSON de `/avaliacoes/loja/{id}` (o endpoint devolve a entidade `Avaliacao` inteira, e `Consumidor` tem `imagemUrl`) — era este parser que o descartava, e por isso a lista de avaliações do app só sabia desenhar a inicial do nome. A web já lia o mesmo campo."
  - 💡 Explicação Leiga: A linha guarda a foto de quem avaliou. Antes o aplicativo jogava fora esse dado sem querer.

### 📂 ARQUIVO: lib/features/avaliacoes/data/services/avaliacao_service.dart

- ⚙️ Função: Busca e envia avaliações no servidor.
- 💬 Comentários Removidos:

  > "Serviço responsável por consumir os endpoints de avaliação."
  - 💡 Explicação Leiga: Esta classe reúne todos os pedidos ao servidor relacionados a avaliações.

  > "Busca as avaliações de uma loja específica via GET /avaliacoes/loja/{id}. Rota pública — não requer token."
  - 💡 Explicação Leiga: A função busca as avaliações de uma loja. Não é preciso estar logado.

  > "Busca as avaliações do consumidor autenticado via GET /avaliacoes/minhas."
  - 💡 Explicação Leiga: A função busca as avaliações que o próprio usuário escreveu.

  > "Cria uma nova avaliação do consumidor autenticado para a loja, via POST /avaliacoes (rota geral, contrato legado). O backend sempre insere uma nova linha — múltiplas avaliações do mesmo consumidor para a mesma loja são permitidas (histórico), não há upsert. O controller espera o corpo no formato bruto da entidade `Avaliacao` (`nota`, `comentario`, `loja: {id}`) — não um DTO enxuto — pra manter retrocompatibilidade com o painel Web legado, que consome esse mesmo contrato. [lojaId] ID da loja avaliada. [nota] Nota inteira de 1 a 5. [comentario] Comentário opcional."
  - 💡 Explicação Leiga: A função envia uma avaliação nova. O mesmo cliente pode avaliar a mesma loja várias vezes.

### 📂 ARQUIVO: lib/features/avaliacoes/presentation/pages/consumer_review_page.dart

- ⚙️ Função: Mostra a lista de avaliações que o usuário já escreveu.
- 💬 Comentários Removidos:

  > "[mostrarSpinner] falso no 'puxe para atualizar': o gesto já é o indicador, e ligar `_isLoading` trocaria a lista por um spinner de página inteira debaixo do dedo de quem está puxando."
  - 💡 Explicação Leiga: A função busca as avaliações. Ao puxar para atualizar, a lista continua visível.

  > "Um tom abaixo do cardSurface do card que envolve esta miniatura (mesmo padrão de superfície aninhada dos lotes anteriores)."
  - 💡 Explicação Leiga: A linha usa um fundo levemente mais escuro atrás da miniatura da foto.

  > "Decorativa (sem `semanticLabel`): o nome da loja já aparece como texto ao lado."
  - 💡 Explicação Leiga: A linha deixa a miniatura sem descrição falada, porque o nome já está escrito.

---

## 🙋 PARTE 9 — O CLIENTE (CONSUMIDOR)

### 📂 ARQUIVO: lib/features/consumer/data/models/consumer_model.dart

- ⚙️ Função: Guarda todos os dados cadastrais de um cliente.
- 💬 Comentários Removidos:

  > "Modelo completo de consumidor retornado por GET /consumidores/{id}. PUT /consumidores/{id} faz replace completo no backend (não faz merge de campos), então toda edição precisa reenviar cpf/imagemUrl mesmo quando a tela não permite editá-los, senão são sobrescritos com null — inclusive apagando a foto de perfil enviada por POST /consumidores/{id}/imagem."
  - 💡 Explicação Leiga: Esta classe guarda os dados do cliente. Ao salvar, é preciso reenviar todos os campos, senão o servidor apaga os que faltarem.

### 📂 ARQUIVO: lib/features/consumer/data/models/consumer_register_request.dart

- ⚙️ Função: Monta o pacote de dados enviado ao servidor no cadastro de um cliente.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

### 📂 ARQUIVO: lib/features/consumer/data/services/consumer_service.dart

- ⚙️ Função: Busca, atualiza e apaga os dados do cliente no servidor.
- 💬 Comentários Removidos:

  > "Envia a foto de perfil. O corpo da resposta do POST não é confiável, então busca o consumidor novamente pra devolver o estado atualizado. Usa bytes (não o path) porque o Flutter Web não expõe caminho de arquivo."
  - 💡 Explicação Leiga: A função envia a foto e depois busca os dados de novo. A resposta do envio não é confiável.

  > "Exclusão definitiva da conta — o backend já faz cascade (avaliações, denúncias)."
  - 💡 Explicação Leiga: A função apaga a conta. O servidor apaga junto as avaliações e denúncias.

  > "PUT /consumidores/{id} faz replace completo no backend, então [consumer] deve carregar todos os campos existentes (inclusive os não editáveis nesta tela, como cpf) para não serem apagados. [novaSenha] só é enviada se o usuário quiser trocar a senha — omitida, o backend preserva a senha atual automaticamente."
  - 💡 Explicação Leiga: A função salva os dados do cliente. A senha só é enviada quando o usuário quer trocá-la.

### 📂 ARQUIVO: lib/features/consumer/presentation/controllers/activity_summary.dart

- ⚙️ Função: Agrupa as datas das avaliações para desenhar o gráfico de atividade.
- 💬 Comentários Removidos:

  > "Série pronta pro gráfico + os números do cabeçalho do card."
  - 💡 Explicação Leiga: Esta classe guarda os pontos do gráfico e os totais.

  > "Total de eventos dentro do período selecionado."
  - 💡 Explicação Leiga: A linha guarda quantas avaliações foram feitas no período.

  > "Variação percentual contra o período anterior de mesma duração. `null` quando o período anterior não teve nenhum evento — nesse caso não existe base de comparação e mostrar '+100%' seria inventar leitura."
  - 💡 Explicação Leiga: A linha guarda a variação percentual. Fica vazia quando não houve nada no período anterior.

  > "Agrupa [datas] (data de cada avaliação feita pelo consumidor) nos baldes do [periodo] escolhido, sempre terminando em hoje. Tudo é calculado no cliente a partir da lista que o perfil já busca — não há endpoint de série temporal na API, e inventar um só pra este gráfico seria mudança de backend por causa de estética."
  - 💡 Explicação Leiga: A função separa as datas em grupos por dia, semana ou mês. Toda a conta é feita dentro do celular.

  > "Primeiro dia do mês de 11 meses atrás — o balde 11 é o mês corrente."
  - 💡 Explicação Leiga: A linha calcula a data inicial para o gráfico de doze meses.

### 📂 ARQUIVO: lib/features/consumer/presentation/pages/consumer_edit_profile.dart

- ⚙️ Função: Tela onde o cliente edita nome, e-mail, telefone e foto.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

### 📂 ARQUIVO: lib/features/consumer/presentation/pages/consumer_home_page.dart

- ⚙️ Função: É a tela principal do cliente, com as abas de mapa, busca e perfil.
- 💬 Comentários Removidos:

  > "Aba exibida. `ValueNotifier` e não um campo com `setState`: trocar de aba não muda mais nada nesta página além de qual filho o `IndexedStack` mostra, e um `setState` aqui reconstruiria o `build` inteiro — recriando as instâncias de `HomeMapExplorer`, `SearchPage` e `ConsumerProfilePage`. Widget recriado não é idêntico ao anterior, então o Flutter desce a árvore e reconstrói o mapa com todos os pins a cada toque na barra. Com o notifier, a lista de abas é construída uma vez por build da página, as instâncias são as mesmas, e `Element.updateChild` corta o trabalho por identidade."
  - 💡 Explicação Leiga: A linha guarda qual aba está aberta. Trocar de aba não redesenha o mapa inteiro.

  > "Muda a cada edição de perfil salva, forçando o ConsumerProfilePage a remontar (novo nome/e-mail/foto) em vez de continuar com os dados carregados na primeira vez que a aba foi aberta."
  - 💡 Explicação Leiga: A linha guarda um contador. Quando ele muda, a tela de perfil é montada de novo com os dados atualizados.

  > "Avisa o perfil quando ele passa a ser a aba exibida. O IndexedStack constrói as três abas de uma vez e nunca as descarta, então o `initState` do perfil roda no login e nunca mais — sem esse aviso, a Atividade fica congelada no retrato daquele momento. `ValueNotifier` e não `setState` porque só o perfil precisa reagir a isso."
  - 💡 Explicação Leiga: A linha avisa a aba de perfil quando ela fica visível. Sem isso os números nunca seriam atualizados.

  > "Lê a sessão do [SessionStore] — síncrono, já hidratado no `main()`. Antes era um `await AuthStorage.getSession()`, e a tela precisava mostrar um spinner de página inteira (`_sessionLoaded`) enquanto o disco respondia, só para descobrir o próprio nome do usuário."
  - 💡 Explicação Leiga: A função lê o nome do usuário da memória. Antes a tela mostrava um carregamento só para isso.

  > "Fire-and-forget explícito: `load()` já converte falha em `errorMessage` observável (ver FavoritesManager), então não há nada a aguardar aqui — mas a intenção precisa estar escrita, não implícita."
  - 💡 Explicação Leiga: A linha inicia o carregamento dos favoritos sem esperar o resultado.

  > "Chamado ao voltar da tela de Editar Perfil — relê nome/e-mail da sessão e força o ConsumerProfilePage a remontar (via troca de key) pra também buscar a foto de novo, já que o card não se atualiza sozinho."
  - 💡 Explicação Leiga: A função atualiza a tela ao voltar da edição de perfil.

  > "O guard `_sessionLoaded` (spinner de página inteira) saiu: a sessão já está em memória desde o `main()`, então a home nasce pronta."
  - 💡 Explicação Leiga: A linha remove um carregamento que não era mais necessário.

  > "Construída fora do ValueListenableBuilder de propósito: assim as três instâncias sobrevivem à troca de aba e o IndexedStack só troca o índice. Dentro do builder, cada toque na barra recriaria as três e o mapa seria reconstruído do zero."
  - 💡 Explicação Leiga: A linha monta as três abas uma única vez. Trocar de aba apenas muda qual delas aparece.

  > "RepaintBoundary em cada aba: isola o layer de pintura de cada uma — a troca de aba passa a ser só trocar qual layer já pronto mostrar, sem repintar o mapa/formulário das abas que não mudaram."
  - 💡 Explicação Leiga: A linha isola o desenho de cada aba. As abas escondidas não são redesenhadas.

### 📂 ARQUIVO: lib/features/consumer/presentation/pages/consumer_profile_page.dart

- ⚙️ Função: Tela de perfil do cliente, com atividade, favoritos e ajustes de conta.
- 💬 Comentários Removidos:

  > "AuthStorage continua aqui só por `diasNoApp()`: é uma marca local do aparelho (não faz parte da sessão) e por isso não migra para o SessionStore."
  - 💡 Explicação Leiga: A linha importa o arquivo que guarda a data do primeiro uso no celular.

  > "Perfil do consumidor. Não usa mais o `ProfilePageScaffold` (que segue servindo o comerciante): a tela foi redesenhada em torno de atividade — um card com a métrica em destaque, o gráfico da série e os números resumidos —, com o resto do conteúdo distribuído em três abas de texto no lugar da rolagem única de antes. Nada saiu: favoritos (com 'ver tudo'), Editar Perfil, Minhas avaliações, Minhas denúncias, Configurações, trocar tema e Sair continuam todos aqui, só que agrupados por assunto."
  - 💡 Explicação Leiga: Esta classe desenha o perfil do cliente em três abas. Nenhuma opção foi removida, apenas reorganizada.

  > "Chamado ao voltar da tela de Editar Perfil, pra quem construiu esta página poder recarregar nome/e-mail/foto — o card de perfil não atualiza sozinho porque os dados vêm de fora via [userName]/[userEmail]."
  - 💡 Explicação Leiga: A linha avisa a tela de cima quando o perfil foi editado.

  > "Leva para a aba de busca — usado pelo estado vazio de favoritos, que precisa oferecer o próximo passo em vez de só constatar o vazio."
  - 💡 Explicação Leiga: A linha permite ir para a busca a partir da lista de favoritos vazia.

  > "`true` enquanto esta é a aba exibida. Esta página vive num `IndexedStack` — construída uma vez no login e nunca descartada —, então o `initState` não serve como gatilho de atualização: sem este aviso, o gráfico de atividade e os contadores ficariam parados no retrato do login, sem refletir avaliações e denúncias feitas depois."
  - 💡 Explicação Leiga: A linha avisa quando esta aba fica visível, para os números serem atualizados.

  > "Datas das avaliações do consumidor — fonte única do gráfico e do contador 'Lojas avaliadas'. Null enquanto carrega."
  - 💡 Explicação Leiga: A linha guarda as datas das avaliações. Elas alimentam o gráfico e o contador.

  > "Evita cargas concorrentes: voltar de 'Minhas avaliações' já dispara uma recarga, e mudar de aba logo em seguida dispararia outra por cima."
  - 💡 Explicação Leiga: A linha impede duas buscas ao mesmo tempo.

  > "Toda vez que a aba volta a ser exibida, os números são buscados de novo — é o que faz uma avaliação recém-enviada aparecer no gráfico sem exigir que o app seja reiniciado. Os favoritos entram na mesma releitura porque esta página os exibe (a seção de destaque) e não é a única a editá-los: favoritar pela web altera o mesmo conjunto no servidor. Como esta aba vive num `IndexedStack` e nunca é recriada, sem isto a seção continuaria mostrando o que foi carregado no login — inclusive uma loja já desfavoritada em outro cliente."
  - 💡 Explicação Leiga: A função busca os números e os favoritos toda vez que a aba é aberta.

  > "Mantém o fallback com as iniciais do nome."
  - 💡 Explicação Leiga: A linha mantém as iniciais do nome quando não há foto de perfil.

  > "Rebusca os números da aba Atividade. Os campos só são sobrescritos quando a nova resposta chega — nada é zerado no início —, então uma recarga não faz o gráfico piscar de volta pro estado de carregamento."
  - 💡 Explicação Leiga: A função busca os números de novo. O gráfico antigo continua na tela até o novo chegar.

  > "Linha do resumo fica em '—'; não pode impedir a busca do gráfico."
  - 💡 Explicação Leiga: A linha mostra um traço quando um número falhou, sem derrubar o resto da tela.

  > "Só na primeira carga: numa recarga que falhou, manter a série que já estava na tela é melhor do que trocá-la por 'sem avaliações'."
  - 💡 Explicação Leiga: A linha só limpa o gráfico na primeira vez. Numa recarga com falha, o gráfico antigo fica.

  > "Denúncias entram só como número no resumo — falha aqui não pode derrubar o gráfico, que é o conteúdo principal da aba."
  - 💡 Explicação Leiga: A linha busca as denúncias separadamente. Uma falha nelas não afeta o gráfico.

  > "Deixa o resumo mostrando '—' pra essa linha."
  - 💡 Explicação Leiga: A linha mostra um traço no lugar do número que não carregou.

  > "Abre uma tela e rebusca os números da Atividade ao voltar dela."
  - 💡 Explicação Leiga: A função abre outra tela e atualiza os números quando o usuário volta.

  > "Recarga em segundo plano: `_carregarAtividade` já é reentrante (guard `_carregandoAtividade`) e trata os próprios erros por bloco."
  - 💡 Explicação Leiga: A linha inicia a atualização sem travar a tela.

  > "Puxar para atualizar: as três origens de dado do perfil — foto, atividade e favoritos —, em paralelo. Vale para qualquer aba selecionada: quem puxa não está pensando em qual aba está aberta, e as três são baratas."
  - 💡 Explicação Leiga: A função atualiza foto, números e favoritos ao mesmo tempo.

  > "Respiro pra bottom bar flutuante da ConsumerHomePage."
  - 💡 Explicação Leiga: A linha reserva espaço no rodapé para a barra de navegação não cobrir o conteúdo.

  > "cabeçalho e abas"
  - 💡 Explicação Leiga: Marca o início do trecho que desenha o topo da tela.

  > "Isolamento de rebuild: só este ícone escuta o ThemeController — nome, avatar e abas não reconstroem quando o usuário troca de tema."
  - 💡 Explicação Leiga: A linha faz apenas o botão de tema ser redesenhado ao trocar o tema.

  > "Superfície do tema, não o preto da marca a 10%: no escuro aquele fundo ficava indistinguível da tela, e a inicial (também `ink`) sumia junto."
  - 💡 Explicação Leiga: A linha usa uma cor sólida atrás da inicial do nome, para ela não sumir no tema escuro.

  > "Sem foto (ou com foto quebrada), o 'vazio' deste avatar não é um ícone: é a inicial do nome."
  - 💡 Explicação Leiga: A linha mostra a primeira letra do nome quando não há foto.

  > "Abas de texto com indicador embaixo do rótulo ativo, sobre uma linha contínua fina — em vez de `TabBar`/`TabController`, que traria um `TickerProvider` e uma view paginada só pra alternar três colunas."
  - 💡 Explicação Leiga: A função desenha três abas de texto com um traço embaixo da ativa.

  > "A aba ativa se distingue pelo traço vermelho embaixo do rótulo — marcação de posição, não de cor —, mais o peso da fonte. Faltava anunciar o 'selecionado'."
  - 💡 Explicação Leiga: A linha informa ao leitor de tela qual aba está selecionada.

  > "aba: atividade"
  - 💡 Explicação Leiga: Marca o início do trecho que desenha a aba de atividade.

  > "As duas linhas abaixo levam à tela que produz o número. Como essas telas editam/excluem avaliações e denúncias, a volta passa por `_abrirERecarregar` — senão o contador aqui continuaria mostrando o total de antes da exclusão."
  - 💡 Explicação Leiga: As linhas seguintes abrem outras telas e atualizam os contadores ao voltar.

  > "O visual (incluindo o `selectedSurface`, que inverte no tema escuro pra o chip ativo não sumir) vive no AppChoiceChip."
  - 💡 Explicação Leiga: A linha usa a etiqueta padrão do app para escolher o período.

  > "Placeholder do card de atividade: acompanha a escala pelo mesmo motivo que o card real — senão a tela encolhe no instante em que os dados chegam e o conteúdo 'pula'."
  - 💡 Explicação Leiga: A linha reserva a altura exata do gráfico enquanto ele carrega.

  > "Linha de 'Seus números'. Com [onTap], ela vira o atalho para a tela que origina aquele número — 'Lojas avaliadas' abre as avaliações, 'Denúncias feitas' abre as denúncias. Um número numa lista é uma pergunta implícita ('quais?'), e a resposta estava a três toques daqui, escondida na aba Conta. O chevron é o que avisa que a linha responde — sem ele, a diferença entre a linha clicável e a de 'Dias no app' (que não leva a lugar nenhum, porque não existe tela de 'dias') só apareceria depois do toque."
  - 💡 Explicação Leiga: A função desenha uma linha com rótulo e número. Quando a linha leva a outra tela, aparece uma seta.

  > "'—' enquanto carrega ou quando a chamada falhou — mesmo placeholder que os cards de estatística já usavam."
  - 💡 Explicação Leiga: A linha mostra um traço enquanto o número não chegou.

  > "Decorativo: quem usa leitor de tela já ouve que a linha é um botão pelo SemanticTapArea que a envolve."
  - 💡 Explicação Leiga: A linha esconde a seta do leitor de tela, para não repetir informação.

  > "aba: favoritos"
  - 💡 Explicação Leiga: Marca o início do trecho que desenha a aba de favoritos.

  > "Escuta o FavoritesManager direto: favoritar/desfavoritar em outra aba precisa refletir aqui na hora — era exatamente esse o bug que o `featuredRefreshListenable` do scaffold antigo resolvia."
  - 💡 Explicação Leiga: A linha observa a lista de favoritos. Mudanças em outra aba aparecem aqui na hora.

  > "Falha de carga não pode se disfarçar de 'nenhum favorito ainda': o estado vazio convida a explorar, e é a orientação errada para quem tem favoritos salvos e está só sem rede."
  - 💡 Explicação Leiga: A linha mostra erro em vez de "lista vazia" quando a busca falha.

  > "Estado vazio com saída: sem o botão, a aba dizia 'não há nada' e deixava a pessoa sem o que fazer a respeito — é o que faz um app novo parecer abandonado."
  - 💡 Explicação Leiga: A linha mostra um botão de explorar quando não há favoritos.

  > "`brandContent`: vermelho como texto sobre a superfície da tela."
  - 💡 Explicação Leiga: A linha usa o vermelho ajustado para texto.

  > "Categoria e nota são o que diferencia um favorito do outro numa pilha — o nome sozinho obriga a abrir a loja pra lembrar do que se trata."
  - 💡 Explicação Leiga: A linha mostra a categoria da loja embaixo do nome.

  > "`precacheCapaDaLoja` em vez de `abrirDetalheDaLoja`: esta navegação precisa recarregar a lista ao voltar (dá pra avaliar a loja lá dentro, e sair daqui e voltar não passa pelo aviso de visibilidade — a aba nunca deixou de ser a exibida), e quem faz isso é o `_abrirERecarregar`."
  - 💡 Explicação Leiga: A linha baixa a foto da loja antes de abrir a tela dela.

  > "aba: conta"
  - 💡 Explicação Leiga: Marca o início do trecho que desenha a aba de conta.

  > "Estas duas telas editam/excluem avaliações e denúncias, ou seja, mexem justamente nos números da aba Atividade — por isso a recarga ao voltar, sem esperar o usuário sair e entrar na aba de novo."
  - 💡 Explicação Leiga: As opções seguintes atualizam os números ao voltar.

  > "Sem onLogoutExtra: `SessionManager.clearUserScopedState()` (chamado dentro do fluxo de exclusão) já limpa os favoritos — passar de novo aqui seria limpeza em dobro."
  - 💡 Explicação Leiga: A linha não repete a limpeza dos favoritos, porque ela já acontece em outro ponto.

  > "`inverse`: sair não é ação primária (ninguém abre o perfil para sair) nem destrutiva — é o CTA neutro forte, e o token inverte sozinho no tema escuro, onde o preto sólido sumia no fundo."
  - 💡 Explicação Leiga: A linha desenha o botão de sair em preto no tema claro e claro no tema escuro.

### 📂 ARQUIVO: lib/features/consumer/presentation/widgets/activity_chart.dart

- ⚙️ Função: Desenha o gráfico de linha com a atividade do cliente ao longo do tempo.
- 💬 Comentários Removidos:

  > "Um ponto da série de atividade: quantas avaliações o consumidor fez no intervalo rotulado por [label]."
  - 💡 Explicação Leiga: Esta classe guarda um ponto do gráfico, com rótulo e valor.

  > "Gráfico de linha da atividade do consumidor. `CustomPainter` em vez de um pacote de charts de propósito: é uma série só, sem eixos, zoom ou tooltip — não justifica uma dependência nova no `pubspec.yaml`. O ponto de maior valor ganha um marcador e um balão com o número, que é o que dá leitura imediata ao gráfico sem eixo Y desenhado."
  - 💡 Explicação Leiga: Esta classe desenha o gráfico manualmente, sem usar biblioteca externa. O ponto mais alto recebe um balão com o número.

  > "Topo reservado pro balão do valor máximo — sem essa margem ele sairia cortado quando o pico está na primeira linha do gráfico."
  - 💡 Explicação Leiga: A linha reserva 26 pontos no topo para o balão não ser cortado.

  > "Área sob a curva, esvaindo pra transparente — mesma leitura de 'volume' da referência sem precisar de grade de fundo."
  - 💡 Explicação Leiga: A linha pinta a área embaixo da linha do gráfico com um degradê.

  > "Marcador + balão no pico da série."
  - 💡 Explicação Leiga: A linha encontra o ponto mais alto para desenhar o balão nele.

  > "Curva por Bézier cúbica com pontos de controle no meio horizontal de cada par — dá a linha arredondada da referência sem 'estourar' acima do pico, que é o que acontece com interpolação Catmull-Rom ingênua."
  - 💡 Explicação Leiga: A função desenha a linha arredondada do gráfico. A curva nunca passa acima do ponto mais alto.

  > "Trava nas bordas pra o balão nunca vazar do card quando o pico é o primeiro ou o último ponto da série."
  - 💡 Explicação Leiga: A linha impede que o balão saia para fora do cartão.

  > "A `DeltaBadge` que morava aqui foi para `core/ui/widgets/delta_badge.dart`: a tela de Estatísticas do comerciante precisa da mesma pílula, e um widget compartilhado importado de dentro da feature do consumidor seria acoplamento entre dois módulos que não se conhecem. O visual daqui não mudou — é o `DeltaTone.marca`, que continua sendo o padrão."
  - 💡 Explicação Leiga: Anota que a etiqueta de variação foi movida para a pasta de peças compartilhadas.

### 📂 ARQUIVO: lib/features/consumer/presentation/widgets/consumer_bottom_bar.dart

- ⚙️ Função: Desenha a barra de navegação do rodapé para o cliente.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

---

## ✉️ PARTE 10 — FALAR COM OS ADMINISTRADORES

### 📂 ARQUIVO: lib/features/contato/data/services/contato_service.dart

- ⚙️ Função: Envia a mensagem de contato para a equipe do MapFood.
- 💬 Comentários Removidos:

  > "Envio de mensagem para os administradores da plataforma. `POST /contato` é público (não exige token) e o servidor encaminha a mensagem por e-mail — não há listagem, edição nem histórico: é um envio e pronto, do mesmo jeito que no site. Tem limite de taxa: 3 envios por minuto, por IP. Estourar devolve 429, e o [ErrorInterceptor] traduz isso em `AppException`. Vale o texto do backend, não uma mensagem inventada aqui."
  - 💡 Explicação Leiga: Esta classe envia a mensagem por e-mail para a equipe. O servidor aceita no máximo três envios por minuto.

  > "[telefone] é o único campo opcional — o backend valida os demais como obrigatórios. Vazio é omitido do corpo em vez de ir como string vazia: o campo tem `@Size(max = 30)` e aceita nulo, mas mandar `''` deixa o e-mail que o administrador recebe com um rótulo de telefone em branco."
  - 💡 Explicação Leiga: A função envia a mensagem. O telefone é o único campo que pode ficar em branco.

### 📂 ARQUIVO: lib/features/contato/presentation/pages/contato_page.dart

- ⚙️ Função: Formulário para o usuário escrever uma mensagem à equipe do MapFood.
- 💬 Comentários Removidos:

  > "'Fale com os administradores' — espelho da tela de Contato do site. Mesmo fluxo do site (formulário → `POST /contato` → e-mail para a equipe) e os mesmos cinco campos, com duas diferenças que vêm de ser um aplicativo, e não uma página: 1. Nome e e-mail vêm preenchidos para quem está logado. No site o visitante quase sempre chega deslogado; aqui, quem abre esta tela veio do próprio perfil, e redigitar o que o app já sabe é atrito puro. Os campos continuam editáveis — a pessoa pode querer resposta em outro endereço. 2. Guarda de saída: o texto de uma reclamação escrita à mão se perde com um deslize lateral. Um formulário começado pede confirmação antes de fechar."
  - 💡 Explicação Leiga: Esta classe desenha o formulário de contato. O nome e o e-mail já vêm preenchidos para quem está logado.

  > "Só o que a pessoa escreveu conta como rascunho — nome e e-mail já chegam preenchidos da sessão, e considerá-los faria a guarda de saída disparar num formulário em que ninguém digitou nada."
  - 💡 Explicação Leiga: A linha só considera rascunho o que foi digitado à mão. Campos preenchidos automaticamente não contam.

  > "Fecha o teclado antes de enviar: o toast de sucesso nasce no topo da tela e o foco de volta num campo reabriria o teclado sobre a mensagem."
  - 💡 Explicação Leiga: A linha fecha o teclado antes de enviar, para o aviso de sucesso ficar visível.

  > "Limpa antes de sair para a guarda de rascunho não barrar o próprio fechamento pós-envio."
  - 💡 Explicação Leiga: A linha apaga o texto depois do envio. Assim o aviso de "sair sem salvar" não aparece.

  > "O backend corta em 200; o contador avisa antes de o texto ser recusado no envio."
  - 💡 Explicação Leiga: A linha limita o campo a 200 letras, igual ao limite do servidor.

  > "O e-mail da equipe, para quem prefere escrever do próprio cliente de e-mail. É o mesmo endereço que aparece no rodapé do site e na política de privacidade — deixá-lo de fora daria a impressão de que o formulário é o único caminho."
  - 💡 Explicação Leiga: A linha mostra o endereço de e-mail da equipe como alternativa ao formulário.

---

## 🚨 PARTE 11 — DENÚNCIAS

### 📂 ARQUIVO: lib/features/denuncias/data/models/denuncia_model.dart

- ⚙️ Função: Guarda os dados de uma denúncia feita por um cliente.
- 💬 Comentários Removidos:

  > "Modelo de denúncia retornado pela API `/denuncias`."
  - 💡 Explicação Leiga: Esta classe guarda o motivo, a descrição e a loja denunciada.

  > "Mapeia os motivos de denúncia do enum Java para strings da UI e vice-versa."
  - 💡 Explicação Leiga: Esta classe traduz os códigos do servidor para frases legíveis na tela.

  > "Converte o enum da API de volta pro label da UI — usado pra pré-preencher o dropdown quando o consumidor já denunciou a loja."
  - 💡 Explicação Leiga: A função traduz o código do servidor de volta para a frase mostrada na tela.

### 📂 ARQUIVO: lib/features/denuncias/data/models/denuncia_recebida_model.dart

- ⚙️ Função: Guarda os dados de uma denúncia recebida contra a loja do comerciante.
- 💬 Comentários Removidos:

  > "Denúncia contra uma loja do comerciante, como devolvida por `GET /denuncias/loja/comerciante/{id}` (`DenunciaRecebidaResponse` na API). É um formato diferente do [DenunciaModel] usado pelo consumidor: a API omite de propósito quem denunciou (sigilo do denunciante) e envia a loja achatada em `lojaId`/`lojaNome`, em vez do objeto `loja` aninhado. Ler esta resposta com o model do consumidor devolvia 'Comércio removido' em todo nome de loja — passou despercebido porque o único consumo até aqui usava apenas o tamanho da lista."
  - 💡 Explicação Leiga: Esta classe guarda uma denúncia vista pelo lado do comerciante. O nome de quem denunciou nunca é enviado.

  > "Enum cru da API (`FRAUDE_OU_GOLPE`, `SPAM`...). Use [MotivosDenuncia.fromApi] para exibir."
  - 💡 Explicação Leiga: A linha guarda o código do motivo. Ele precisa ser traduzido antes de aparecer na tela.

  > "`PENDENTE`, `EM_ANALISE`, `RESOLVIDA` ou `ARQUIVADA`."
  - 💡 Explicação Leiga: A linha guarda a situação da denúncia.

  > "Denúncia que ainda pesa contra a loja. `RESOLVIDA`/`ARQUIVADA` já passaram pela moderação e não exigem mais nada do comerciante — contá-las junto faria o painel cobrar por algo que já foi encerrado."
  - 💡 Explicação Leiga: A linha informa se a denúncia ainda está aberta. Casos encerrados não contam.

  > "Rótulo de exibição do motivo."
  - 💡 Explicação Leiga: A linha devolve o motivo já traduzido para o texto da tela.

### 📂 ARQUIVO: lib/features/denuncias/data/services/denuncia_service.dart

- ⚙️ Função: Cria e busca denúncias no servidor.
- 💬 Comentários Removidos:

  > "Cria a denúncia do consumidor autenticado para a loja, via POST /denuncias (rota geral, contrato legado). O controller não extrai o consumidor do JWT — espera a entidade `Denuncia` crua no corpo, com `consumidor`/`loja` já resolvidos — por isso [consumidorId] precisa ser informado pelo chamador (normalmente vindo de `AuthStorage.getSession()`). Não há checagem de duplicidade no backend: reenviar cria uma nova denúncia, não há mais 409 nem upsert. [lojaId] ID da loja. [consumidorId] ID do consumidor autenticado (da sessão local). [motivo] Label da UI (ex: 'Fraude ou golpe') — será convertido para enum da API. [descricao] Texto descritivo opcional."
  - 💡 Explicação Leiga: A função envia uma denúncia nova. O servidor aceita denúncias repetidas sem recusar.

  > "Busca as denúncias feitas por um consumidor específico."
  - 💡 Explicação Leiga: A função busca as denúncias que o próprio usuário fez.

  > "Denúncias recebidas pelas lojas de um comerciante, via GET /denuncias/loja/comerciante/{comercianteId}. Devolve a lista inteira — motivo, status, data e loja de cada uma. A versão anterior deste método descartava tudo isso e devolvia só `data.length`, porque o único consumo era um card de contagem. O painel de Estatísticas usa os campos para dizer por que e quando, que é o que o comerciante pode agir a respeito. Só o dono das lojas (ou um administrador) recebe 200 aqui; a API não expõe a identidade de quem denunciou."
  - 💡 Explicação Leiga: A função busca as denúncias contra as lojas do comerciante. Antes ela só devolvia a quantidade.

### 📂 ARQUIVO: lib/features/denuncias/presentation/pages/consumer_complaints_page.dart

- ⚙️ Função: Mostra a lista de denúncias que o usuário já fez.
- 💬 Comentários Removidos:

  > "Estas duas telas tinham cópias privadas de 'vazio' e 'erro', cada uma com seu próprio tamanho de ícone e botão. Agora usam o EmptyState compartilhado."
  - 💡 Explicação Leiga: A linha usa o bloco de tela vazia compartilhado, em vez de uma cópia própria.

  > "Sem override de cor: legenda() já resolve pra secondaryText."
  - 💡 Explicação Leiga: A linha usa a cor padrão do estilo de legenda, sem trocá-la.

  > "Sem override de cor: legenda() já resolve pra secondaryText."
  - 💡 Explicação Leiga: A linha usa a cor padrão do estilo de legenda, sem trocá-la.

---

## ❤️ PARTE 12 — FAVORITOS

### 📂 ARQUIVO: lib/features/favorites/data/services/favorito_service.dart

- ⚙️ Função: Busca, adiciona e remove lojas favoritas no servidor.
- 💬 Comentários Removidos:

  > "GET /favoritos/completo (não o /favoritos legado): mesma listagem, mas com mediaAvaliacao/totalAvaliacoes já agregados, pra não mostrar 'Novo' em lojas favoritadas que já têm avaliações."
  - 💡 Explicação Leiga: A linha usa o endereço que já traz a nota das lojas. Sem ele, lojas avaliadas apareciam como "Novo".

### 📂 ARQUIVO: lib/features/favorites/presentation/controllers/favorites_manager.dart

- ⚙️ Função: Guarda na memória a lista de lojas favoritas e mantém os corações sincronizados.
- 💬 Comentários Removidos:

  > "Favoritos do consumidor logado, em memória. O app não é o único cliente que edita este conjunto. O favorito é gravado no servidor com o id do consumidor extraído do token, então favoritar pela web altera o mesmo dado — e o app não fica sabendo, porque a API não tem push e este singleton só lê o servidor quando alguém chama [load]. Enquanto isso não acontece, os corações da tela mostram o estado de quando a lista foi carregada. Daí a releitura ao voltar do segundo plano (ver [didChangeAppLifecycleState]): é o momento em que a chance de o dado estar velho é maior, e é barato. Não resolve o caso de duas sessões editando ao mesmo tempo com o app em primeiro plano — para isso seria preciso push do servidor, o que é desproporcional aqui."
  - 💡 Explicação Leiga: Esta classe guarda a lista de favoritos na memória. Ela relê a lista quando o usuário volta ao aplicativo.

  > "Ao voltar do segundo plano, relê os favoritos do servidor. Só para consumidor: visitante e comerciante não têm favoritos, e `GET /favoritos/completo` responderia 401/403 — um 401 faria o `SessionManager` derrubar a sessão e mandar o usuário para o login, ou seja, sair do app e voltar deslogaria um visitante."
  - 💡 Explicação Leiga: A função relê os favoritos ao voltar ao aplicativo. Ela só roda para clientes logados.

  > "Fire-and-forget: `load()` já converte falha em `errorMessage` observável, então não há nada a aguardar num callback de ciclo de vida."
  - 💡 Explicação Leiga: A linha inicia a leitura sem esperar o resultado.

  > "Troca o service num teste. Necessário porque este controller é um singleton de processo: ele resolve o `ApiClient` na construção, ou seja, antes de qualquer `ApiClient.overrideInstance` que um teste faça."
  - 💡 Explicação Leiga: A linha permite trocar o mecanismo de busca durante os testes.

  > "Índice de consulta O(1), mantido em paralelo à lista. `isFavorite` era um `any` linear, e cada card de loja na tela mantém um listener neste singleton. Com as abas vivas num IndexedStack são dezenas de corações montados ao mesmo tempo: uma única notificação disparava O(cards × favoritos) comparações no thread de UI, durante a animação do toque. Invariante: `_favorites` só pode ser tocada por [_add], [_remove] e [clear] — é o que impede a lista e o índice de divergirem."
  - 💡 Explicação Leiga: A linha guarda um conjunto de números para consulta rápida. Antes o app percorria a lista inteira a cada coração desenhado.

  > "Falha da última carga — null quando deu certo. Existe porque `load()` era um `try/finally` sem `catch`: um erro de rede virava exceção assíncrona órfã (o chamador não dá await) e a aba ficava em lista vazia silenciosa, indistinguível de 'você não tem favoritos'."
  - 💡 Explicação Leiga: A linha guarda a mensagem de erro. Assim a tela distingue "sem favoritos" de "falha na busca".

  > "Evita duas chamadas concorrentes de toggle() pro mesmo storeId (ex: double-tap no coração antes da primeira resposta da API chegar), que podiam disparar add/remove em paralelo e deixar o ícone dessincronizado do que ficou persistido no backend."
  - 💡 Explicação Leiga: A linha impede dois toques seguidos no mesmo coração de se atrapalharem.

  > "Busca os favoritos do consumidor autenticado na API. Seguro de chamar mais de uma vez (ex: a cada abertura da home/aba de favoritos)."
  - 💡 Explicação Leiga: A função busca a lista de favoritos no servidor.

  > "Falha vira estado observável, não exceção que ninguém pega: quem chama `load()` normalmente o faz sem await (login, abertura de aba)."
  - 💡 Explicação Leiga: A linha guarda o erro em vez de deixá-lo se perder.

  > "Atualização otimista: alterna localmente e notifica antes de confirmar com a API. Reverte e relança o erro se a chamada falhar."
  - 💡 Explicação Leiga: A função muda o coração na hora e só depois avisa o servidor. Se der erro, ela desfaz a mudança.

  > "Reverte a atualização otimista — lista e índice juntos."
  - 💡 Explicação Leiga: A linha desfaz a mudança quando o servidor recusa.

  > "Zera o estado local sem chamar a API — usado no logout, pra não vazar favoritos de uma conta para a sessão seguinte no mesmo aparelho."
  - 💡 Explicação Leiga: A função apaga a lista da memória ao sair da conta.

### 📂 ARQUIVO: lib/features/favorites/presentation/pages/consumer_favorites_page.dart

- ⚙️ Função: Mostra a lista completa de lojas favoritadas pelo cliente.
- 💬 Comentários Removidos:

  > "Primeira carga sem nada na tela é a única situação sem 'puxe para atualizar': não há o que puxar, e o spinner já é a resposta. Nos demais estados — inclusive erro e lista vazia — o gesto existe, porque é exatamente ali que se quer tentar de novo."
  - 💡 Explicação Leiga: A linha mostra o carregamento na primeira busca. Nos outros casos o gesto de puxar continua disponível.

  > "Erro tem precedência sobre o vazio: sem isso, uma falha de rede aparecia como 'nenhum favorito ainda' e o usuário concluía que tinha perdido o que salvou."
  - 💡 Explicação Leiga: A linha mostra a mensagem de erro em vez da mensagem de lista vazia.

  > "Um tom abaixo do cardSurface do card que envolve esta miniatura (mesmo padrão de superfície aninhada dos lotes anteriores)."
  - 💡 Explicação Leiga: A linha usa um fundo mais escuro atrás da miniatura.

  > "Decorativa (sem `semanticLabel`): o nome da loja já aparece como texto no card."
  - 💡 Explicação Leiga: A linha deixa a miniatura sem descrição falada.

  > "Selo de canto com a cor de identidade da categoria principal — mesma paleta usada nos filtros."
  - 💡 Explicação Leiga: A linha desenha uma etiqueta colorida com a categoria da loja.

### 📂 ARQUIVO: lib/features/favorites/presentation/widgets/favorite_button_widget.dart

- ⚙️ Função: Desenha o botão de coração que salva ou remove uma loja dos favoritos.
- 💬 Comentários Removidos:

  > "Alvo de toque mínimo recomendado (Material 48dp / Apple HIG 44pt) — o círculo visual (ícone + padding) pode ser menor, mas a área que responde ao toque não deve."
  - 💡 Explicação Leiga: A linha define 48 pontos como área mínima de toque, mesmo que o círculo desenhado seja menor.

  > "Vidro fosco translúcido sobre a foto (efeito do card 'Em Alta', igual ao anexo de referência) em vez do círculo branco opaco padrão."
  - 💡 Explicação Leiga: A linha liga o modo translúcido, usado quando o botão fica sobre uma foto.

  > "O papel vem do SessionStore, leitura síncrona e sem I/O. Antes era um parâmetro empurrado por até 4 níveis de widget acima daqui, cada nível existindo só para repassá-lo adiante."
  - 💡 Explicação Leiga: A linha lê o tipo de usuário direto da memória, sem precisar recebê-lo de fora.

  > "Coração do estado favoritado: preenchido, não só vermelho. O contorno vermelho sozinho lê como 'botão de favoritar' — a mesma silhueta do estado não-favoritado, trocando só a cor. É o par [AppIcons.star]/[AppIcons.starFill] que o `RatingStars` já usa: a massa sólida é o que marca o estado, a cor só o reforça. O [AnimatedSwitcher] faz o preenchido entrar crescendo (e o vazado sair encolhendo) — a confirmação de que o toque pegou, num botão cujo único retorno visual, fora o toast, é ele mesmo."
  - 💡 Explicação Leiga: A função desenha o coração cheio quando a loja é favorita. Ele cresce ao ser marcado, confirmando o toque.

  > "Sem a key os dois ícones são 'o mesmo widget' para o switcher e a troca acontece sem transição nenhuma."
  - 💡 Explicação Leiga: A linha identifica cada versão do ícone, para a animação de troca acontecer.

  > "[SemanticTapArea] (rótulo + papel de botão pro leitor de tela) como widget mais externo, com no mínimo 48dp de área de toque — o círculo visual (`_circle`) fica centralizado dentro dela, sem crescer."
  - 💡 Explicação Leiga: A função cria a área de toque em volta do coração.

  > "Círculo translúcido sem BackdropFilter de propósito: este botão aparece em listas roláveis (busca, 'Em Alta') com vários cards visíveis ao mesmo tempo — cada BackdropFilter força seu próprio saveLayer + blur na GPU, e vários simultâneos durante o scroll eram a maior causa de engasgo do app. Alpha mais alto (0.32 vs 0.28) + sombra compensam visualmente a falta do desfoque de fundo."
  - 💡 Explicação Leiga: A linha desenha um círculo translúcido sem desfoque real. O desfoque em vários cartões travava a rolagem.

---

## 👀 PARTE 13 — O VISITANTE (SEM CONTA)

### 📂 ARQUIVO: lib/features/guest/presentation/pages/guest_home_page.dart

- ⚙️ Função: Tela principal de quem usa o aplicativo sem estar logado.
- 💬 Comentários Removidos:

  > "Mesma decisão das homes de consumidor e comerciante: com `setState`, cada toque na barra recriava as instâncias de `HomeMapExplorer`, `SearchPage` e `GuestProfilePage` e o Flutter reconstruía o mapa inteiro só pra trocar o índice do `IndexedStack`. Ver a nota longa em `KeyboardAwareBottomBar`."
  - 💡 Explicação Leiga: A linha guarda a aba atual sem redesenhar a tela inteira ao trocar de aba.

  > "Fora do builder de propósito — ver a nota no campo `_abaAtual`."
  - 💡 Explicação Leiga: A linha monta as abas uma única vez.

  > "RepaintBoundary em cada aba: isola o layer de pintura de cada uma — a troca de aba passa a ser só trocar qual layer já pronto mostrar, sem repintar o mapa das abas que não mudaram."
  - 💡 Explicação Leiga: A linha isola o desenho de cada aba, evitando redesenhar o mapa.

### 📂 ARQUIVO: lib/features/guest/presentation/pages/guest_profile_page.dart

- ⚙️ Função: Tela de perfil do visitante, com convite para criar conta e links úteis.
- 💬 Comentários Removidos:

  > "O caret que ficava à direita do rótulo saiu junto: era decoração ('acrescenta informação' é o critério do AppButton para ícone), e num botão de largura total já não indicava direção nenhuma."
  - 💡 Explicação Leiga: A linha remove a seta do botão, porque ela não acrescentava informação.

  > "Vale para o visitante também: `POST /contato` é público, e quem ainda não criou conta é justamente quem pode ter dúvida sobre a plataforma."
  - 💡 Explicação Leiga: A linha mostra a opção de contato também para quem não tem conta.

### 📂 ARQUIVO: lib/features/guest/presentation/pages/how_it_works_page.dart

- ⚙️ Função: Explica em três passos como o aplicativo funciona para quem procura comida.
- 💬 Comentários Removidos:

  > "Três passos para quem procura comida entender a mecânica do app. O desenho da tela vive em [HowItWorksScaffold], compartilhado com a versão do comerciante — aqui fica só o conteúdo."
  - 💡 Explicação Leiga: Esta classe guarda apenas o texto dos três passos. O desenho vem de outro arquivo.

### 📂 ARQUIVO: lib/features/guest/presentation/pages/termos_page.dart

- ⚙️ Função: Mostra os termos de uso e a política de privacidade.
- 💬 Comentários Removidos:

  > "Sem override de cor: corpo() já herda o texto primário do tema — parágrafo de texto legal não deve ficar esmaecido como um texto secundário."
  - 💡 Explicação Leiga: A linha usa a cor de texto principal nos parágrafos. Texto legal não deve ficar apagado.

### 📂 ARQUIVO: lib/features/guest/presentation/widgets/floating_bottom_bar.dart

- ⚙️ Função: Desenha a barra de navegação do rodapé para o visitante.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

---

## 🏪 PARTE 14 — O COMERCIANTE

### 📂 ARQUIVO: lib/features/merchant/data/models/merchant_model.dart

- ⚙️ Função: Guarda todos os dados cadastrais de um comerciante.
- 💬 Comentários Removidos:

  > "Modelo completo de comerciante retornado por GET /comerciantes/{id}. PUT /comerciantes/{id} faz replace completo no backend (não faz merge de campos), então toda edição precisa reenviar cpf/telefone/imagemUrl mesmo quando a tela não permite editá-los, senão são sobrescritos com null — inclusive apagando a foto de perfil enviada por POST /comerciantes/{id}/imagem."
  - 💡 Explicação Leiga: Esta classe guarda os dados do comerciante. Ao salvar é preciso reenviar todos os campos, senão o servidor apaga os que faltarem.

### 📂 ARQUIVO: lib/features/merchant/data/models/merchant_register_request.dart

- ⚙️ Função: Monta o pacote de dados enviado ao servidor no cadastro de um comerciante.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

### 📂 ARQUIVO: lib/features/merchant/data/services/merchant_service.dart

- ⚙️ Função: Busca, atualiza e apaga os dados do comerciante no servidor.
- 💬 Comentários Removidos:

  > "Envia a foto de perfil. O corpo da resposta do POST não é confiável, então busca o comerciante novamente pra devolver o estado atualizado. Usa bytes (não o path) porque o Flutter Web não expõe caminho de arquivo."
  - 💡 Explicação Leiga: A função envia a foto e depois busca os dados de novo.

  > "Exclusão definitiva da conta — hard delete via o endpoint legado (mesmo caminho da Web): o backend já faz cascade (lojas, avaliações, denúncias, acessos). Decisão revertida do soft delete da Fase 4 — sem isso, uma conta 'excluída' pelo mobile continuava plenamente utilizável pela Web, já que ela não sabia de nenhum estado intermediário."
  - 💡 Explicação Leiga: A função apaga a conta de forma definitiva. Antes a conta continuava funcionando pelo site.

  > "PUT /comerciantes/{id} faz replace completo no backend, então [merchant] deve carregar todos os campos existentes (inclusive os não editáveis nesta tela, como cpf) para não serem apagados. [novaSenha] só é enviada se o usuário quiser trocar a senha — omitida, o backend preserva a senha atual automaticamente."
  - 💡 Explicação Leiga: A função salva os dados do comerciante, reenviando todos os campos.

### 📂 ARQUIVO: lib/features/merchant/presentation/controllers/store_ronda_controller.dart

- ⚙️ Função: Controla abrir e fechar a loja e envia a posição do GPS enquanto ela está aberta.
- 💬 Comentários Removidos:

  > "A operação da loja: abrir/fechar e manter a posição no mapa enquanto aberta. Saiu sem reescrita da antiga aba 'Ronda' — o comportamento de GPS é o mesmo, linha por linha. O que muda é o dono: a lógica de rastreamento deixou de morar num `State` de tela, e por isso sobreviveu à fusão daquela aba com o painel de gestão (`MerchantStorePage`)."
  - 💡 Explicação Leiga: Esta classe controla o estado aberto ou fechado da loja. Ela também envia a posição do GPS enquanto a loja está aberta.

  > "Avisa quem hospeda esta seção que a loja mudou no backend (status ou posição), para a lista de lojas dele não ficar defasada."
  - 💡 Explicação Leiga: A linha avisa a tela de cima quando a loja muda.

  > "Momento em que o servidor aceitou a última posição, e a precisão do fix que o aparelho reportou. 'Aberta' e 'sendo localizada' são estados diferentes, e o rodapé do card de status precisa distinguir os dois."
  - 💡 Explicação Leiga: A linha guarda quando a última posição foi enviada com sucesso.

  > "Falha corrente do envio de posição. Existe porque um `catch` mudo deixava a loja parecendo 'ao vivo' enquanto o servidor seguia com uma posição velha — o pior tipo de erro, o que não aparece."
  - 💡 Explicação Leiga: A linha guarda o erro de envio de posição, para ele aparecer na tela.

  > "Assinatura de GPS que atualiza a lat/lng da loja em tempo real enquanto ela está aberta — só em primeiro plano, cancelada ao fechar ou sair."
  - 💡 Explicação Leiga: A linha guarda a conexão com o GPS. Ela é desligada ao fechar a loja.

  > "Incrementado a cada posição recebida — descarta a resposta de um PUT antigo que chegue depois de um mais recente (rede lenta + deslocamento rápido podem inverter a ordem de chegada)."
  - 💡 Explicação Leiga: A linha numera cada envio de posição. Respostas atrasadas são descartadas.

  > "Redesenha o 'há X min' sem esperar uma nova posição chegar."
  - 💡 Explicação Leiga: A linha guarda um cronômetro que atualiza o texto de tempo na tela.

  > "Resincroniza com a versão mais recente vinda de fora (ex: edição salva em outra tela). Sem isso, o próximo tick de GPS reenviaria nome/descrição/categorias desatualizados por cima da edição recém-salva — esta seção fica viva em segundo plano no `IndexedStack`. Loja diferente (switcher do comerciante) não é resync, é troca de alvo: delega para [trocarLoja]. Antes, o `return` mudo deste guard fazia a seção continuar operando a loja anterior — o card e o mapa não acompanhavam o switcher, e 'Fechar loja' fechava a loja de antes."
  - 💡 Explicação Leiga: A função atualiza os dados da loja. Se for outra loja, ela troca de alvo em vez de apenas atualizar.

  > "A loja pode ser fechada fora deste card (ex: 'Inativar loja' em Configurações avançadas). Sem desligar a ronda aqui, o GPS seguiria ligado e enviando posição de uma loja que não está mais no mapa."
  - 💡 Explicação Leiga: A linha desliga o GPS quando a loja é fechada em outra tela.

  > "Passa a operar outra loja (troca no switcher do comerciante). A ronda é sempre de uma loja só — a pessoa está num lugar de cada vez —, então a assinatura de GPS em curso, que estava enviando posição para a loja anterior, cai antes de qualquer coisa. `_posicaoSeq` avança junto para descartar um PUT da loja antiga que ainda esteja em voo: sem isso, a resposta atrasada devolveria `_store` para a loja de antes."
  - 💡 Explicação Leiga: A função troca a loja que está sendo controlada. O GPS da loja anterior é desligado antes.

  > "A loja recém-selecionada já estava aberta: a ronda segue nela, agora."
  - 💡 Explicação Leiga: A linha religa o GPS quando a loja escolhida já estava aberta.

  > "Um tick por minuto, e só enquanto a ronda está ligada: é a granularidade do rótulo ('agora', 'há 3 min'). Um timer de segundos gastaria bateria para reescrever o mesmo texto."
  - 💡 Explicação Leiga: A função atualiza o texto de tempo uma vez por minuto, para economizar bateria.

  > "O diálogo de permissão do SO pode levar segundos — se a seção já foi descartada nesse meio-tempo, não assina o stream (senão a subscription nunca é cancelada e o GPS fica ligado à toa)."
  - 💡 Explicação Leiga: A linha cancela a ligação do GPS se a tela já tiver sido fechada.

  > "Stream compartilhado com o mapa de lojas próximas — um único consumo de GPS mesmo com as duas telas vivas no IndexedStack."
  - 💡 Explicação Leiga: A linha usa a mesma conexão de GPS do mapa, em vez de abrir outra.

  > "Sem GPS disponível — loja segue aberta, só sem posição ao vivo."
  - 💡 Explicação Leiga: A linha mantém a loja aberta mesmo sem GPS.

  > "O payload completo é montado por `StoreCreateRequest.fromStore`, no model — a camada de tela não decide o que vai no corpo do PUT."
  - 💡 Explicação Leiga: A linha envia a posição nova. O conteúdo do envio é montado em outro arquivo.

  > "Descarta a resposta se uma posição mais recente já foi enviada enquanto esta estava em voo — evita regredir a posição exibida."
  - 💡 Explicação Leiga: A linha ignora respostas antigas que chegam atrasadas.

  > "Uma falha isolada não interrompe o rastreamento — a próxima tentativa (próximo deslocamento) resolve. Mas fica visível: sem isso, o comerciante não tem como saber que parou de subir."
  - 💡 Explicação Leiga: A linha registra a falha sem parar o GPS. O aviso aparece na tela.

  > "Abre ou fecha a loja. Devolve `null` quando deu certo, ou a mensagem de erro para quem chamou exibir — o controller não conhece `BuildContext`, e toast é decisão de quem está na tela."
  - 💡 Explicação Leiga: A função troca o estado da loja. Ela devolve o erro para a tela mostrar.

  > "Loja alvo no momento do toque: abrir exige GPS, o que pode demorar segundos, e nesse meio-tempo o switcher pode ter mudado de loja. Sem guardar o alvo, a resposta aplicaria o status da loja A sobre a B."
  - 💡 Explicação Leiga: A linha guarda qual loja foi tocada. Assim a resposta não é aplicada na loja errada.

  > "Guard de sessão: leitura síncrona do SessionStore (o id não é usado aqui — a API extrai o comerciante do JWT nesta rota)."
  - 💡 Explicação Leiga: A linha impede que um visitante tente abrir uma loja.

  > "Exige localização para abrir: sem coordenada, a loja fica ATIVA no banco mas invisível no mapa (o filtro de 'perto de você' ignora loja sem lat/long) — bloqueia aqui em vez de deixar esse estado fantasma acontecer de novo."
  - 💡 Explicação Leiga: A linha exige a posição do GPS para abrir a loja. Sem ela a loja ficaria invisível no mapa.

  > "Fechar não precisa de localização — troca só o status, partindo do estado que já temos (o backend rejeita SUSPENSA vinda do mobile, embora este toggle nunca a envie)."
  - 💡 Explicação Leiga: A linha fecha a loja sem precisar do GPS.

  > "Trocou de loja enquanto a chamada estava em voo: o status foi gravado na loja certa no servidor, e a lista de quem hospeda precisa saber — mas escrever esse resultado no estado desta seção, que agora exibe outra loja, é o que fazia 'fechar a loja A' aparecer como a B fechada."
  - 💡 Explicação Leiga: A linha avisa a tela de cima sem aplicar o resultado na loja errada.

  > "Sem await: a ronda é um fluxo de longa duração (permissão + stream), e o `finally` precisa liberar `alternando` assim que o status já foi persistido. Erros de GPS são tratados lá dentro."
  - 💡 Explicação Leiga: A linha inicia o GPS sem travar o botão de abrir a loja.

  > "Posição pontual (não o stream) — exigida antes de deixar a loja ir para ATIVA. `null` em qualquer falha: serviço desligado, permissão negada, timeout ou sem fix de GPS."
  - 💡 Explicação Leiga: A função pega a posição uma única vez, antes de abrir a loja.

### 📂 ARQUIVO: lib/features/merchant/presentation/pages/merchant_edit_profile.dart

- ⚙️ Função: Tela onde o comerciante edita seus dados pessoais.
- 💬 Comentários Removidos: nenhum. O arquivo já estava sem comentários.

### 📂 ARQUIVO: lib/features/merchant/presentation/pages/merchant_home_page.dart

- ⚙️ Função: Tela principal do comerciante, com as abas de mapa, estatísticas, loja e perfil.
- 💬 Comentários Removidos:

  > "Aba exibida. `ValueNotifier` e não um campo com `setState`: aqui o `IndexedStack` tem quatro filhos (mapa, estatísticas, minha loja, perfil), e um `setState` por toque na barra recriava as quatro instâncias — o Flutter então descia a árvore inteira, reconstruindo o mapa com os pins e o dashboard, só pra mudar qual delas fica visível. Ver a mesma nota, mais longa, em `KeyboardAwareBottomBar`."
  - 💡 Explicação Leiga: A linha guarda a aba atual. Trocar de aba não redesenha as outras.

  > "Índice da aba de Estatísticas na barra e no `IndexedStack`."
  - 💡 Explicação Leiga: A linha guarda o número da aba de estatísticas.

  > "Avisa a aba de Estatísticas quando ela volta a ser exibida. Ela vive no `IndexedStack` e nunca é descartada, então o `initState` dela roda uma vez só — sem este aviso, os números ficariam congelados no momento em que o app abriu. `ValueNotifier` e não `setState` porque só ela reage."
  - 💡 Explicação Leiga: A linha avisa a aba de estatísticas quando ela fica visível.

  > "Muda a cada edição de perfil salva, forçando o MerchantProfilePage a remontar (novo nome/e-mail/foto) em vez de continuar com os dados carregados na primeira vez que a aba foi aberta."
  - 💡 Explicação Leiga: A linha guarda um contador que força a tela de perfil a recarregar.

  > "O trio isLoading/errorMessage/data do AsyncLoadMixin já nasce `isLoading: false` por padrão — força `true` aqui, antes do primeiro build, pra não desenhar um frame de 'sem loja' (`data` ainda nulo) enquanto `_loadData` aguarda a sessão local."
  - 💡 Explicação Leiga: A linha marca a tela como carregando desde o início. Sem isso aparecia um piscar de "sem loja".

  > "Chamado ao voltar da tela de Editar Perfil — recarrega só nome/e-mail da sessão (sem repetir o fluxo de `_loadData`, que também busca lojas e pode redirecionar) e força o MerchantProfilePage a remontar via key, pra também buscar a foto de novo."
  - 💡 Explicação Leiga: A função atualiza apenas o nome e o e-mail ao voltar da edição.

  > "Sessão em memória (hidratada no `main()`): nome e e-mail saem daqui sem I/O, e só a busca das lojas continua sendo assíncrona."
  - 💡 Explicação Leiga: A linha lê o nome do usuário da memória, sem acessar o disco.

  > "Sem loja cadastrada → redireciona obrigatoriamente para criação. Devolve `false` pra nunca commitar essa lista vazia em `asyncState` — a tela está sendo substituída, não faz sentido ela chegar a renderizar com `stores` vazio antes de sair."
  - 💡 Explicação Leiga: A linha leva o comerciante sem loja direto para o cadastro de loja.

  > "A busca deixou de ser aba do comerciante (o lugar virou 'Estatísticas') e passou a ser empurrada pelo botão de busca do mapa. `onVoltar` fecha a rota — sem ele a página empurrada não teria saída visível, já que a `SearchPage` não desenha cabeçalho quando é usada como aba."
  - 💡 Explicação Leiga: A função abre a busca como uma tela nova, com botão de voltar.

  > "Mantém a lista de lojas em dia quando uma tela filha altera a loja no backend (toggle aberta/fechada, edição, posição da ronda) — sem isso, trocar de loja no switcher e voltar remontava a tela com o dado velho do boot, parecendo que a alteração não persistiu."
  - 💡 Explicação Leiga: A função atualiza a lista de lojas quando uma tela filha muda alguma coisa.

  > "Sem loja e sem redirecionamento em voo: a sessão sumiu entre o `_loadData` e este build (ex: 401 concorrente limpando o AuthStorage). Indexar aqui dava RangeError e tela branca."
  - 💡 Explicação Leiga: A linha protege contra a tela ficar em branco quando a sessão é perdida.

  > "`clamp` como segunda linha de defesa: o índice também pode ficar fora do intervalo se a lista encolher (loja excluída) antes do próximo build."
  - 💡 Explicação Leiga: A linha limita o número escolhido ao tamanho da lista, evitando erro.

  > "Construídas fora do ValueListenableBuilder: assim as quatro instâncias sobrevivem à troca de aba, e o IndexedStack só troca o índice. Dentro do builder, cada toque na barra recriaria as quatro."
  - 💡 Explicação Leiga: A linha monta as quatro abas uma única vez.

  > "RepaintBoundary em cada aba: sem isso, o Stack/Compositor trata a troca de aba do IndexedStack como parte do mesmo layer de pintura das outras abas (mesmo as invisíveis) — isolando cada uma, a troca vira só uma questão de qual layer já pronto mostrar, sem repintar o mapa/formulários das abas que não mudaram."
  - 💡 Explicação Leiga: A linha isola o desenho de cada aba.

  > "Sem `key` por loja: a página resincroniza pelo `didUpdateWidget`, e uma key nova a cada troca de loja remontaria a seção de operação — derrubando a assinatura de GPS da ronda em curso."
  - 💡 Explicação Leiga: A linha evita recriar a tela ao trocar de loja. Recriar desligaria o GPS.

### 📂 ARQUIVO: lib/features/merchant/presentation/pages/merchant_how_it_works.dart

- ⚙️ Função: Explica em três passos como o aplicativo funciona para o comerciante.
- 💬 Comentários Removidos:

  > "Três passos para o comerciante entender a mecânica do app. Os passos são uma sequência de operação (ativar → rodar → colher retorno), e é por isso que aparecem numa linha do tempo, e não como três cards soltos de mesmo peso. O desenho vive em [HowItWorksScaffold], compartilhado com a versão do visitante — aqui fica só o conteúdo."
  - 💡 Explicação Leiga: Esta classe guarda o texto dos três passos do comerciante.

### 📂 ARQUIVO: lib/features/merchant/presentation/pages/merchant_profile_page.dart

- ⚙️ Função: Tela de perfil do comerciante.
- 💬 Comentários Removidos:

  > "Chamado ao voltar da tela de Editar Perfil, pra quem construiu esta página poder recarregar nome/e-mail/foto — o card de perfil não atualiza sozinho porque os dados vêm de fora via [userName]/[userEmail]."
  - 💡 Explicação Leiga: A linha avisa a tela de cima quando o perfil foi editado.

  > "'Excluir conta' está temporariamente escondido para o comerciante (sem `onDeleteAccount`, o item some de Configurações): o DELETE /comerciantes/{id} falha com 409 quando a conta tem favoritos na loja, posts, pix ou localização — o backend só limpa denúncias, avaliações e acessos antes de apagar. Reativar assim que o cascade estiver completo em ComercianteController.deletar; MerchantService.delete continua pronto para isso."
  - 💡 Explicação Leiga: A opção de excluir a conta está escondida para o comerciante. O servidor ainda recusa esse pedido.

  > "Os cards de estatística ('Dias no App', 'Avaliações Recebidas', 'Denúncias Recebidas') saíram daqui: o perfil ficou restrito à conta, e desempenho tem tela própria. Com eles foi embora também a cascata de chamadas que os alimentava — uma busca de avaliações por loja, em série, mais a de denúncias, todas antes de a tela poder aparecer."
  - 💡 Explicação Leiga: Os números foram movidos para a tela de Estatísticas. Isso deixou o perfil abrir mais rápido.

### 📂 ARQUIVO: lib/features/merchant/presentation/pages/merchant_store_page.dart

- ⚙️ Função: Painel onde o comerciante administra a loja, do status às configurações.
- 💬 Comentários Removidos:

  > "O painel de quem administra a loja. Une o que eram duas abas — a operação (abrir/fechar + mapa da ronda) e o perfil público — porque elas nunca foram assuntos diferentes: são o mesmo objeto, visto de dois lados. Separadas, a informação mais consultada do dia (estou aberto? apareço onde?) ficava numa aba ao lado do lugar onde a loja é administrada. A organização é por frequência de uso, não por tipo de dado: imediata (abrir/fechar, posição no mapa) fica no topo, sem rolagem; diária (dados, fotos, categorias) fica a um toque na StoreEditPage; rara (inativar/excluir loja) fica a dois toques na StoreAdvancedPage."
  - 💡 Explicação Leiga: Esta classe reúne tudo sobre a loja em uma tela só. O que é usado todo dia fica no topo.

  > "Barra de troca de loja (comerciante com mais de uma) — renderizada no topo do body pra não colidir com o AppBar."
  - 💡 Explicação Leiga: A linha recebe a barra que permite trocar entre lojas.

  > "Loja alterada no backend (status, posição da ronda, edição salva)."
  - 💡 Explicação Leiga: A linha avisa a tela de cima quando a loja muda.

  > "Loja excluída — quem hospeda precisa recarregar a lista, porque a loja desta tela deixou de existir."
  - 💡 Explicação Leiga: A linha avisa a tela de cima quando a loja é apagada.

  > "Resincroniza com a versão mais recente vinda do pai. Aqui não há formulário aberto para atropelar — este painel é leitura, e a edição acontece numa rota empurrada por cima."
  - 💡 Explicação Leiga: A linha atualiza os dados da loja quando eles mudam.

  > "Troca de loja pelo switcher: as avaliações são de outra loja agora."
  - 💡 Explicação Leiga: A linha troca a loja exibida e busca as avaliações da nova.

  > "Troca de loja pelo switcher: zera o que está na tela antes de buscar, porque o conteúdo atual é de outra loja e continuaria visível, atribuído à loja errada, durante a busca."
  - 💡 Explicação Leiga: A função limpa a tela antes de buscar os dados da nova loja.

  > "Puxar para atualizar: refaz as buscas da mesma loja, e por isso não zera nada — o que está na tela continua correto até o dado novo chegar. Em paralelo, já que uma não depende da outra."
  - 💡 Explicação Leiga: A função busca os dados de novo sem limpar a tela.

  > "Lista vazia com o aviso da própria seção — não derruba o painel."
  - 💡 Explicação Leiga: A linha mantém o painel funcionando mesmo se as avaliações falharem.

  > "Mantém null ('Novo') se a busca falhar."
  - 💡 Explicação Leiga: A linha mantém a nota vazia quando a busca falha.

  > "Inativar por lá muda o status da mesma loja que o card de operação está exibindo aqui — sem isso o painel voltaria mostrando 'Loja aberta' com a ronda ligada."
  - 💡 Explicação Leiga: A linha mantém o painel atualizado quando a loja é inativada em outra tela.

  > "As camadas são separadas por respiro, não por linha: quatro `Divider` de ponta a ponta numa tela de sete blocos fatiavam o painel em faixas de mesmo peso, e o que se lia era a grade, não a hierarquia. A única linha que sobra é a que antecede a camada rara — ali ela marca uma quebra de natureza (consulta → ação destrutiva), não um respiro."
  - 💡 Explicação Leiga: A linha separa os blocos com espaço em branco. Só existe uma linha divisória, antes das ações perigosas.

  > "As avaliações e a nota média chegam de fora: é o cliente que avalia, não o lojista. Puxar é o gesto de 'chegou alguma nota nova?'."
  - 💡 Explicação Leiga: A linha liga o gesto de puxar para buscar avaliações novas.

  > "imediata"
  - 💡 Explicação Leiga: Marca o bloco de abrir e fechar a loja, o mais usado.

  > "diária"
  - 💡 Explicação Leiga: Marca o bloco com os dados públicos da loja.

  > "rara"
  - 💡 Explicação Leiga: Marca o bloco com as ações pouco usadas, como excluir a loja.

  > "A ronda escreve na loja a cada deslocamento. O painel acompanha para o preview não ficar com o endereço de antes, e repassa para o pai."
  - 💡 Explicação Leiga: A função atualiza o endereço mostrado quando a loja se move.

  > "Como o cliente vê a loja — leitura pura, com um atalho para editar. Nada de campo de formulário aqui: para conferir o nome da loja não faz sentido montar um `TextField` desabilitado, que era o que a tela antiga fazia e o que dava a uma página de consulta a cara de formulário quebrado."
  - 💡 Explicação Leiga: Esta classe mostra os dados da loja apenas para leitura. Não existem campos de digitar aqui.

  > "Um bloco só, com as linhas separadas por divisores internos. Soltas sobre o fundo da página, com 16 de respiro entre uma e outra, as quatro liam como campos de um formulário desabilitado — que é exatamente o que esta tela deixou de ser. Superfície `flat`: o painel inteiro já rola, e um card com sombra aqui viraria um objeto solto no meio da página."
  - 💡 Explicação Leiga: A linha agrupa as informações em um único bloco sem sombra.

  > "Divisor entre duas linhas do bloco de consulta. Recuado à esquerda até onde o texto começa — encostado na borda ele cortaria a coluna de ícones ao meio, e é a coluna que amarra as linhas como um bloco só."
  - 💡 Explicação Leiga: Esta classe desenha a linha divisória recuada, para não cortar a coluna de ícones.

  > "Linha de consulta: rótulo pequeno em cima, valor com contraste embaixo. Valor ausente vira 'Não informado' em tom terciário em vez de espaço em branco — vazio silencioso lê como falha de carregamento. O respiro é padding interno (o card que a hospeda tem padding zero): assim os divisores entre as linhas caem no meio do espaço, e não colados na linha de cima."
  - 💡 Explicação Leiga: Esta classe desenha uma linha com rótulo e valor. Campos vazios mostram "Não informado".

### 📂 ARQUIVO: lib/features/merchant/presentation/widgets/merchant_bottom_bar.dart

- ⚙️ Função: Desenha a barra de navegação do rodapé para o comerciante.
- 💬 Comentários Removidos:

  > "'Buscar' saiu daqui e virou um push a partir do mapa: explorar lojas alheias é secundário para quem administra a própria."
  - 💡 Explicação Leiga: A linha troca a aba de busca pela de estatísticas.

  > "'Ronda' e 'Minha loja' eram duas abas para o mesmo objeto — o toggle de aberta/fechada agora é o topo do painel de gestão, que é onde ele sempre foi procurado."
  - 💡 Explicação Leiga: A linha junta duas abas antigas em uma só.

### 📂 ARQUIVO: lib/features/merchant/presentation/widgets/store_operation_section.dart

- ⚙️ Função: Mostra o botão de abrir/fechar a loja e o mapa com a posição atual.
- 💬 Comentários Removidos:

  > "A camada imediata do painel do comerciante: abrir/fechar a loja e ver onde ela está aparecendo agora. É o bloco mais consultado do dia e por isso fica no topo, sem rolagem. Virou seção justamente para morar dentro do painel de gestão: antes era uma aba inteira ('Ronda'), separada de 'Minha loja' — o status era a informação que o lojista mais procura e a única que não estava onde ele administra."
  - 💡 Explicação Leiga: Esta classe desenha o bloco mais usado pelo comerciante. Ele fica no topo, sem precisar rolar.

  > "Notifica o pai quando a loja muda no backend (status ou posição)."
  - 💡 Explicação Leiga: A linha avisa a tela de cima quando a loja muda.

  > "Altura proporcional com piso e teto: o mapa é conferência ('estou aparecendo onde acho que estou?'), não a tela principal — num aparelho pequeno ele cede espaço para o card de status, que é o que se opera."
  - 💡 Explicação Leiga: A linha calcula a altura do mapa como um terço da tela, com limites mínimo e máximo.

  > "Loja fechada: véu sobre a cartografia. O mapa continua legível (é a referência do último ponto), mas para de parecer o estado ao vivo que ele não é."
  - 💡 Explicação Leiga: A linha escurece o mapa quando a loja está fechada.

  > "Nota de rodapé explicando a ronda. Curta e presente nos dois estados: é a única explicação de por que a loja 'anda' no mapa, e some do caminho de quem já sabe (uma linha, sem caixa colorida chamando atenção)."
  - 💡 Explicação Leiga: Esta classe escreve uma frase curta explicando por que a loja se move no mapa.

### 📂 ARQUIVO: lib/features/merchant/presentation/widgets/store_reviews_section.dart

- ⚙️ Função: Mostra as avaliações que a loja recebeu, começando recolhida.
- 💬 Comentários Removidos:

  > "O que os clientes disseram sobre a loja, do ponto de vista de quem recebe. A nota média vem do backend (`GET /lojas/{id}/resumo`), não de uma conta feita sobre a lista carregada aqui — a lista é paginável no futuro e a média calculada no cliente passaria a divergir da que o consumidor vê. Chega recolhida. O painel é a tela de operação da loja, e a lista inteira de avaliações empurrava 'Configurações avançadas' para fora do alcance de qualquer loja com histórico — quem abre o painel quer saber como está a nota, não reler cada comentário. O resumo (média + total) fica sempre visível; a lista é um toque."
  - 💡 Explicação Leiga: Esta classe mostra a nota média sempre visível. A lista de comentários só abre com um toque.

  > "Média agregada. `null` quando a loja ainda não tem nota."
  - 💡 Explicação Leiga: A linha guarda a nota média da loja.

  > "Vazio não tem o que expandir: o estado vazio é curto e vale mais visível do que escondido atrás de um toque que revelaria 'nada aqui'."
  - 💡 Explicação Leiga: A linha desliga o botão de expandir quando não há avaliações.

  > "Linha de 'ver/ocultar' com a contagem no rótulo. O número no botão é o que faz a seção recolhida não parecer vazia: sem ele, 'Ver avaliações' some no meio da página como um link qualquer."
  - 💡 Explicação Leiga: Esta classe desenha o botão de abrir a lista, com a quantidade escrita nele.

  > "48 de altura mínima: é um alvo de toque de largura inteira, e o conteúdo é uma linha de texto só."
  - 💡 Explicação Leiga: A linha define a altura mínima de toque do botão.

  > "Roda com a expansão: a mesma seta serve para os dois estados e marca o sentido do movimento."
  - 💡 Explicação Leiga: A linha faz a seta girar ao abrir e fechar a lista.

  > "Foto de quem avaliou, com a inicial do nome como fallback — mesmo tratamento do card de avaliação do lado do consumidor."
  - 💡 Explicação Leiga: A linha mostra a foto de quem avaliou, ou a inicial do nome.

  > "Um degrau acima do `surfaceAlt` do card que envolve este avatar — superfície aninhada precisa se destacar do pai."
  - 💡 Explicação Leiga: A linha usa uma cor de fundo diferente da caixa em volta.

  > "Dois cards fantasma com a forma real do conteúdo. Um spinner centralizado não diz o que está vindo e faz a página saltar de altura quando os cards finalmente chegam."
  - 💡 Explicação Leiga: Esta classe desenha duas caixas cinzas no formato das avaliações enquanto elas carregam.

### 📂 ARQUIVO: lib/features/merchant/presentation/widgets/store_status_card.dart

- ⚙️ Função: Desenha o cartão que mostra se a loja está aberta e permite abrir ou fechar.
- 💬 Comentários Removidos:

  > "O controle mais importante do app para o comerciante: abrir e fechar a loja, e entender num relance se ela está sendo vista. Três decisões de operação (não de estética) que este card resolve: 1. A ação virou botão, não interruptor. O `Switch` do Material tem ~40×24px de alvo real e nenhum rótulo do que vai acontecer; quem opera isso está na rua, muitas vezes de uma mão só. Um botão de 52px dizendo 'Fechar loja' acerta na primeira e não deixa dúvida sobre o sentido do toque — interruptor obriga a ler o estado atual para deduzir o efeito. 2. Aberta é uma superfície de alto contraste, via `selectedSurface`/`onSelectedSurface` (o mesmo par de chip e segmento ativos). Antes era `Colors.black` fixo com texto `grey.shade400`: no tema escuro o card sumia no fundo e o subtítulo caía abaixo do mínimo de contraste. 3. A ronda de GPS é visível. 'Aberta' e 'sendo localizada' são estados diferentes — dá para estar aberta com o GPS negado, e a loja não aparece no mapa de ninguém. O rodapé mostra quando a última posição subiu e com que precisão, e [avisoPosicao] transforma a falha silenciosa de envio em algo que a pessoa consegue ver e reagir."
  - 💡 Explicação Leiga: Esta classe desenha o cartão de status da loja. A ação é um botão grande com texto, não um interruptor pequeno.

  > "Assinatura de GPS ativa, enviando posição ao servidor."
  - 💡 Explicação Leiga: A linha informa se o GPS está ligado e enviando a posição.

  > "Chamada em andamento (abrir/fechar) — bloqueia o botão e mostra spinner."
  - 💡 Explicação Leiga: A linha bloqueia o botão enquanto o pedido está sendo processado.

  > "Quando a última posição foi aceita pelo servidor."
  - 💡 Explicação Leiga: A linha guarda a hora do último envio de posição.

  > "Raio de erro do GPS em metros, como reportado pelo aparelho."
  - 💡 Explicação Leiga: A linha guarda a margem de erro da posição em metros.

  > "Falha corrente do envio de posição (rede/servidor). `null` quando tudo está subindo normalmente."
  - 💡 Explicação Leiga: A linha guarda o erro de envio de posição, se houver.

  > "Sobre a superfície invertida não dá para usar `textSecondary` (ele é calibrado para o fundo da tela): o apoio vira o próprio conteúdo a 65%."
  - 💡 Explicação Leiga: A linha calcula a cor do texto de apoio a partir da cor do conteúdo.

  > "Sobre o card invertido, o vermelho de marca brigaria com a superfície: `onBrand` dá o branco sólido que sempre lê ali. Fechada, abrir é a ação principal da tela — vermelho."
  - 💡 Explicação Leiga: A linha escolhe a cor do botão conforme a loja estar aberta ou fechada.

  > "Selo 'AO VIVO' com ponto pulsante — o vocabulário que todo app de entrega usa para 'isto está acontecendo agora'. Sem o pulso, o selo parece um rótulo estático e não comunica atividade."
  - 💡 Explicação Leiga: Esta classe desenha o selo "AO VIVO" com um ponto que pisca.

  > "RepaintBoundary: o pulso repinta 60x/s e não deve arrastar o resto do card (que inclui texto e botão) junto."
  - 💡 Explicação Leiga: A linha isola o ponto que pisca, para o resto do cartão não ser redesenhado.

  > "Rodapé de dados da ronda: quando a posição subiu e com que precisão."
  - 💡 Explicação Leiga: Esta classe escreve a hora e a precisão da última posição.

  > "'agora' cobre o intervalo mais comum (a posição sobe a cada poucos metros percorridos) — mostrar 'há 4 s' ali só faria o número piscar sem dizer nada de novo."
  - 💡 Explicação Leiga: A função escreve "agora" para posições muito recentes.

  > "`numeric` (tabular): '±12 m' e 'há 3 min' trocam de valor no lugar em vez de empurrar o texto lateralmente a cada atualização."
  - 💡 Explicação Leiga: A linha usa números de largura fixa, para o texto não tremer.

  > "Faixa de aviso quando o envio de posição está falhando. Antes essa falha era um `catch (_)` mudo: a loja aparecia como aberta e 'ao vivo' enquanto o servidor seguia com a posição de meia hora atrás."
  - 💡 Explicação Leiga: Esta classe desenha o aviso de que a posição não está sendo enviada.

  > "Sobre o card aberto (superfície invertida) a paleta de alerta precisa de outro fundo — o `dangerSurface` claro sumiria ali."
  - 💡 Explicação Leiga: A linha troca o fundo do aviso quando ele aparece sobre o cartão escuro.

### 📂 ARQUIVO: lib/features/merchant/presentation/widgets/store_switcher_bar.dart

- ⚙️ Função: Desenha a barra de etiquetas para trocar entre as lojas do comerciante.
- 💬 Comentários Removidos:

  > "Chips horizontais para alternar entre as lojas do comerciante, com um chip final para cadastrar outra. Aparece sobre 'Minha operação' e 'Perfil da Loja'. Continua visível mesmo com uma loja só: o chip 'Nova loja' é o caminho mais curto para cadastrar a segunda, e escondê-lo por 'limpeza visual' tiraria a única entrada desse fluxo fora do perfil. A faixa perdeu o fundo e a sombra próprios — ela vive dentro do fundo da página, e uma barra sombreada logo abaixo do AppBar criava uma segunda linha de cabeçalho que competia com o título da tela."
  - 💡 Explicação Leiga: Esta classe desenha etiquetas com o nome de cada loja. A última etiqueta abre o cadastro de uma loja nova.

  > "Teto de escala da barra. Tira horizontal fixa no topo da área do comerciante: ela some da tela se crescer demais, e o conteúdo que ela seleciona é que precisa do espaço."
  - 💡 Explicação Leiga: A linha limita o crescimento da barra quando a letra aumenta.

  > "Selecionado usa o par que inverte com o tema (o mesmo dos segmentos e do card de status). O `Colors.black` fixo de antes desaparecia no fundo escuro, e o chip ativo virava o menos visível da fileira."
  - 💡 Explicação Leiga: A linha escolhe a cor da etiqueta ativa conforme o tema.

  > "Verde é estado operacional (aberta), não cor de marca — vale igual nos dois temas, por isso vem de MfColor e não da escala de superfícies."
  - 💡 Explicação Leiga: A linha usa verde para indicar loja aberta, com o mesmo tom nos dois temas.

---

## 👋 PARTE 15 — BOAS-VINDAS

### 📂 ARQUIVO: lib/features/onboarding/presentation/pages/onboarding_page.dart

- ⚙️ Função: Tela de boas-vindas mostrada apenas na primeira vez que o aplicativo abre.
- 💬 Comentários Removidos:

  > "Boas-vindas da primeira execução. Só aparece quando não há sessão salva e a marca de 'já visto' ainda não existe (ver [main]) — quem já está logado continua caindo direto na home do seu papel, e quem já passou por aqui uma vez nunca mais vê esta tela. 'Continuar sem conta' existe porque o MapFood é navegável sem login: o mapa, a busca e as lojas funcionam como visitante, e o login só é exigido nas ações que precisam de conta (favoritar, avaliar, denunciar). Sem essa saída, o onboarding viraria uma parede de cadastro na frente do app."
  - 💡 Explicação Leiga: Esta classe desenha a tela de boas-vindas. Ela oferece a opção de usar o app sem criar conta.

  > "Deixa a home de visitante embaixo da tela de cadastro em vez de substituir a pilha por ela: sem isso, o 'voltar' de dentro do cadastro não teria pra onde ir (o onboarding já foi removido) e fecharia o app."
  - 💡 Explicação Leiga: A função abre o cadastro deixando a tela de visitante embaixo. Assim o botão de voltar funciona.

  > "Quadrado de ícone acima do título: acompanha a escala, mesmo tratamento do AccountTypeCard. A marca de verdade no lugar das iniciais 'MF': este é o primeiro contato de quem abre o app, e duas letras num quadrado não são um logo — são o placeholder de um. O mesmo pin vermelho do ícone do aplicativo (assets/icon/app_icon.png, aqui na cópia já declarada em assets/images/) é o que a pessoa acabou de tocar na tela inicial do celular."
  - 💡 Explicação Leiga: A linha mostra o logotipo real do aplicativo. Antes apareciam apenas as letras "MF".

  > "Superfície de marca (vermelho bem diluído) em vez do bloco `ink`: o logo é vermelho sólido e precisa de um fundo que o deixe respirar nos dois temas — `primaryContainer` já é o par brandSurface/brandSurfaceDark do AppTheme."
  - 💡 Explicação Leiga: A linha usa um fundo rosa bem claro atrás do logotipo vermelho.

  > "Decorativo: o título logo abaixo já nomeia o produto."
  - 💡 Explicação Leiga: A linha esconde o logotipo do leitor de tela, porque o nome já está escrito.

  > "Substitui o 'Descubra • Avalie • Favorite' que ficava solto no rodapé: diz as mesmas três coisas, mas de forma concreta e ancorada em ícone — e no lugar onde a pessoa está lendo."
  - 💡 Explicação Leiga: A linha desenha três frases com ícone explicando o que o app faz.

---

## 🔎 PARTE 16 — BUSCA

### 📂 ARQUIVO: lib/features/search/data/services/search_history_service.dart

- ⚙️ Função: Guarda no celular as últimas buscas feitas pelo usuário.
- 💬 Comentários Removidos:

  > "Histórico de buscas recentes, persistido localmente por dispositivo."
  - 💡 Explicação Leiga: Esta classe salva as buscas recentes no próprio celular.

### 📂 ARQUIVO: lib/features/search/data/store_search.dart

- ⚙️ Função: Procura lojas pelo texto digitado, tolerando acentos e erros de digitação.
- 💬 Comentários Removidos:

  > "Busca textual de lojas, feita inteiramente no cliente. Vive fora do widget pelo mesmo motivo do `lojasDentroDoRaio`: é regra de negócio, e dentro de um `State` só seria verificável abrindo o app e digitando. Aqui é função pura — mesma entrada, mesma saída. O problema que isto resolve: O filtro anterior era `nome.toLowerCase().contains(termo)`. Três falhas concretas, todas silenciosas (a tela dizia 'nenhum comércio encontrado'): 1. Acento. Quem digita 'acai' no teclado do celular — sem parar para achar o ç e o í — não encontrava 'Açaí da Praça'. 2. Só o nome. Procurar 'pastel' não achava nada, mesmo com lojas da categoria Salgados chamadas 'Dona Maria'. 3. Um dedo errado. 'padria' não achava 'Padaria', e a pessoa concluía que não havia padaria por perto. A busca da API (`GET /lojas/nome`) tem exatamente as mesmas limitações e é `LIKE %termo%` no banco — daí resolver aqui, sobre a lista que o app já mantém em memória."
  - 💡 Explicação Leiga: A função procura lojas pelo texto digitado. Ela ignora acentos, procura também na categoria e aceita erros de digitação.

  > "O índice original entra no par para desempatar: `List.sort` do Dart não é estável, e sem isso lojas de mesma relevância trocariam de posição a cada tecla digitada — a lista 'tremeria' enquanto a pessoa escreve."
  - 💡 Explicação Leiga: A linha guarda a posição original de cada loja. Assim a lista não muda de ordem sozinha ao digitar.

  > "Quão bem [loja] responde a [alvo] (já normalizado). Menor é melhor; `null` significa 'não é resultado'. A escala não é uma nota arbitrária: é a ordem em que uma pessoa espera ver os resultados. Quem digita 'pa' quer 'Padaria Central' antes de uma loja cuja descrição menciona 'pão', e ambas antes de um acerto aproximado."
  - 💡 Explicação Leiga: A função dá uma nota de relevância para cada loja. Acertos no nome vêm antes de acertos na descrição.

  > "Último recurso: erro de digitação. Fica no fim da lista de propósito — é um palpite, não um acerto."
  - 💡 Explicação Leiga: A linha coloca os resultados por semelhança no fim da lista.

  > "'pad' acha 'Empório Padaria' na segunda palavra, não só no começo do nome."
  - 💡 Explicação Leiga: A função procura o texto no começo de qualquer palavra do nome.

  > "`true` quando [alvo] parece uma versão errada de alguma palavra de [nome]. O limiar cresce com o tamanho do termo, e termos curtos não entram: com distância 1 sobre 3 letras, 'bar' acharia 'mar', 'lar' e 'par' — uma busca que devolve qualquer coisa é pior do que uma que não devolve nada."
  - 💡 Explicação Leiga: A função detecta erros de digitação. Ela não faz isso com palavras muito curtas.

  > "Compara só o trecho do tamanho do termo: sem isto, 'padria' nunca casaria com 'padarias' pela diferença de comprimento."
  - 💡 Explicação Leiga: A linha compara apenas o começo da palavra, do tamanho do que foi digitado.

  > "Minúsculas e sem diacríticos. Feito à mão em vez de por pacote: são 20 caracteres que importam em português, e a alternativa (`unorm`/`diacritic`) traria uma dependência inteira para isso."
  - 💡 Explicação Leiga: A função remove acentos e deixa tudo em letras minúsculas.

  > "Quantas edições (inserir, remover, trocar) separam duas palavras. Duas linhas em vez da matriz inteira: a busca roda a cada tecla, sobre a lista completa de lojas ativas."
  - 💡 Explicação Leiga: A função conta quantas letras diferem entre duas palavras. Ela é otimizada porque roda a cada tecla digitada.

### 📂 ARQUIVO: lib/features/search/presentation/pages/search_page.dart

- ⚙️ Função: Tela de busca, com filtros por categoria e as seções "Perto de você" e "Em Alta".
- 💬 Comentários Removidos:

  > "Quantidade máxima de lojas exibidas em cada seção da visão de navegação (nenhuma categoria marcada, sem busca ativa)."
  - 💡 Explicação Leiga: A linha limita cada seção a dez lojas.

  > "Corte do carrossel 'Perto de você' — mais apertado que o das outras seções nas duas dimensões, porque aqui 'perto' é uma afirmação e não só uma ordem. Antes a seção apenas ordenava por distância e mostrava as [_maxSectionItems] primeiras: com a base concentrada numa cidade isso parecia certo, mas nada impedia o carrossel de anunciar como 'perto' a loja mais próxima de um usuário que está a 300 km de todas elas."
  - 💡 Explicação Leiga: A linha define três quilômetros como o limite de "perto de você".

  > "Ação do botão de voltar no topo. `null` (o caso de consumidor e visitante) esconde o cabeçalho inteiro: ali esta página é uma aba, e aba não tem para onde voltar. Existe por causa do comerciante, cuja barra inferior trocou 'Buscar' por 'Estatísticas' — para ele a busca passou a ser empurrada a partir do mapa, e página empurrada precisa de saída visível."
  - 💡 Explicação Leiga: A linha só mostra o botão de voltar quando a busca é aberta como tela nova.

  > "Categoria em foco, pelo nome. `null` é a listagem sem recorte — o estado que a tira de filtros não oferece como item e para o qual se volta desmarcando a categoria ativa (ver `CategoryFiltersWidget`). Guardado pelo nome, e não pelo índice, porque `_categorias` é recarregável: um índice sobreviveria à recarga apontando para outra categoria."
  - 💡 Explicação Leiga: A linha guarda o nome da categoria filtrada. Guardar o nome evita apontar para a categoria errada após recarregar.

  > "Lista completa filtrada por categoria/busca — usada na visão vertical quando uma categoria específica está selecionada."
  - 💡 Explicação Leiga: A linha guarda a lista de lojas já filtrada.

  > "'Em Alta': lojas com avaliação acima de 4.5 dentro do filtro atual."
  - 💡 Explicação Leiga: A linha guarda as lojas mais bem avaliadas.

  > "'Perto de você': até [_pertoDeVoceMaxItems] lojas dentro de [_pertoDeVoceRaioKm], ordenadas pela distância até o usuário. Sem `_userLat`/`_userLng` (sem permissão/GPS indisponível), cai no fallback de mostrar a lista sem raio e sem ordenar por distância — melhor que esconder a seção inteira. Com o raio valendo, a seção pode ficar vazia (o carrossel se esconde sozinho nesse caso) — é a diferença esperada em relação ao comportamento anterior, que sempre tinha algo a mostrar."
  - 💡 Explicação Leiga: A linha guarda a posição do usuário. Sem GPS, a seção mostra lojas sem prometer proximidade.

  > "Busca a posição atual uma única vez (sem stream contínuo — o carrossel 'Perto de você' não precisa reordenar a cada passo do usuário, ao contrário do mapa da aba 'Início')."
  - 💡 Explicação Leiga: A função pega a posição do GPS uma vez só.

  > "No Flutter Web o prompt é nativo do navegador, fora do canvas do Flutter — sem timeout, um prompt ignorado/não respondido trava este `await` pra sempre (mesmo problema em NearbyStoresSection, que roda ao mesmo tempo na aba 'Início')."
  - 💡 Explicação Leiga: A linha define um tempo limite para o pedido de permissão. Sem ele o aplicativo travava no navegador.

  > "Sem GPS disponível — 'Perto de você' cai no fallback sem ordenar por distância."
  - 💡 Explicação Leiga: A linha segue sem posição quando o GPS não está disponível.

  > "Puxar para atualizar: refaz as duas buscas de rede desta tela — as categorias (que alimentam a tira de filtros) e a lista de lojas ativas. A lista vem do `ActiveStoresManager` e não de uma chamada local: pedir direto ao manager mantém uma única fonte para as lojas, e o resultado chega aqui pelo listener que já existe. Buscar em paralelo porque as duas são independentes — em série, o gesto duraria a soma das duas."
  - 💡 Explicação Leiga: A função busca categorias e lojas ao mesmo tempo.

  > "Chamado quando o `ActiveStoresManager` (polling a cada 20s, compartilhado com as home pages) atualiza a lista de lojas ativas — sem isso, a Search Page buscava as lojas uma única vez no initState e nunca via uma loja que acabou de ser ativada enquanto a aba já estava montada."
  - 💡 Explicação Leiga: A função atualiza a tela quando a lista de lojas muda.

  > "Cancela um debounce de digitação pendente — senão ele dispara ~500ms depois com o texto antigo e desfaz essa seleção do histórico."
  - 💡 Explicação Leiga: A linha cancela uma busca agendada, para ela não sobrescrever a escolha do usuário.

  > "A API não oferece um endpoint de busca combinada (nome + categoria), então carregamos todas as lojas ativas uma vez e filtramos localmente. [mostrarSpinner] falso no 'puxe para atualizar': lá o próprio gesto já é o indicador de progresso, e ligar `_isLoading` trocaria a tela inteira por um `CircularProgressIndicator` justamente enquanto a pessoa segura a lista — o conteúdo sumiria debaixo do dedo."
  - 💡 Explicação Leiga: A função baixa todas as lojas e filtra dentro do celular.

  > "Uma categoria que saiu do ar não pode continuar recortando a listagem: sem cartão marcado na tira, o filtro ficaria invisível e não haveria como desfazê-lo."
  - 💡 Explicação Leiga: A linha remove o filtro quando a categoria escolhida deixa de existir.

  > "Filtra por nome, não por id: o endpoint que alimenta `_allStores` (/mobile/api/v1/lojas, via ActiveStoresManager) devolve `categorias` como lista de nomes crus, sem id (ver StoreDto._parseCategoriaIds) — filtrar por `categoriaIds` aqui nunca daria match e zerava a lista pra qualquer categoria selecionada."
  - 💡 Explicação Leiga: A linha filtra pelo nome da categoria, porque o servidor não envia o número dela.

  > "`buscarLojas` (não um `contains` no nome): ignora acento, procura também em categoria/cidade/endereço/descrição, tolera um erro de digitação em termos longos e devolve já ordenado por relevância."
  - 💡 Explicação Leiga: A linha usa a busca inteligente, e não uma comparação simples de texto.

  > "O corte por raio é o mesmo do mapa da aba 'Início' (`lojasDentroDoRaio`, função pura já coberta por teste): sem posição do usuário ele devolve a lista inteira, e é isso que mantém o fallback antigo desta seção — sem GPS, ela continua mostrando lojas, só que sem prometer proximidade."
  - 💡 Explicação Leiga: A linha aplica o filtro de distância usando a mesma função do mapa.

  > "`lojasDentroDoRaio` já garantiu que toda loja aqui tem coordenada — o `latitude!`/`longitude!` acima só é seguro por causa disso."
  - 💡 Explicação Leiga: A linha ordena as lojas por distância. Todas já têm coordenada garantida.

  > "'Perto de você' + 'Em Alta' é a visão de navegação: nenhuma categoria marcada e nenhuma busca ativa. É para cá que a tela volta quando a categoria em foco é desmarcada. Com uma query digitada, sempre mostra a lista vertical de resultados, mesmo sem categoria marcada."
  - 💡 Explicação Leiga: A linha decide entre mostrar as seções ou a lista de resultados.

  > "Recarrega categorias e lojas. A lista vem do `ActiveStoresManager`, que só busca a cada 20s — puxar encurta essa espera quando a pessoa quer ver agora quem acabou de abrir."
  - 💡 Explicação Leiga: A linha liga o gesto de puxar para atualizar.

  > "`null` chega quando o toque desmarcou a categoria que estava ativa — e a tela volta à visão de navegação."
  - 💡 Explicação Leiga: A linha reage ao toque na categoria, marcando ou desmarcando.

  > "Idem: cancela um debounce de digitação pendente pra ele não sobrescrever essa troca de categoria depois."
  - 💡 Explicação Leiga: A linha cancela uma busca agendada ao trocar de categoria.

### 📂 ARQUIVO: lib/features/search/presentation/widgets/category_filters.dart

- ⚙️ Função: Desenha a faixa horizontal de cartões coloridos para filtrar por categoria.
- 💬 Comentários Removidos:

  > "Cartão ilustrado (arte ou ícone + rótulo embaixo) nas pills de filtro da Search Page. Fundo do círculo e ícone usam a cor de identidade da categoria (core/ui/theme/category_colors.dart) — mesma paleta usada nos chips de filtro da home. As categorias com arte 3D mostram a imagem de core/ui/utils/category_images.dart; as demais seguem com o ícone de core/ui/utils/category_icons.dart (compartilhado com os badges de categoria dos cards de loja)."
  - 💡 Explicação Leiga: Este bloco explica que cada categoria mostra uma arte ou um ícone dentro de um círculo colorido.

  > "Filtros de categoria em cartão (arte colorida + rótulo embaixo), inspirado num grid de categorias de food app — mesma distribuição horizontal de antes, só o formato do item mudou de pill pra cartão. Só existem as categorias reais: 'ver tudo' é o estado em que nenhuma está marcada, alcançado tocando de novo na que está — não um item da tira. Um cartão 'Todos' competiria por espaço e por atenção com as categorias sendo, na prática, a ausência de escolha; e a lista já mostra tudo quando nada está marcado, então o estado sem recorte nunca precisa ser pedido, só desfeito."
  - 💡 Explicação Leiga: Esta classe desenha os cartões de categoria. Não existe um cartão "Todos": basta tocar de novo na categoria marcada.

  > "Nomes das categorias, na ordem em que aparecem."
  - 💡 Explicação Leiga: A linha guarda a lista de nomes de categoria.

  > "Categoria marcada, ou `null` quando a listagem está sem recorte."
  - 💡 Explicação Leiga: A linha guarda a categoria marcada.

  > "Recebe o nome da categoria tocada, ou `null` quando o toque desmarcou a que estava ativa (volta à listagem completa)."
  - 💡 Explicação Leiga: A linha avisa a tela quando uma categoria é tocada.

  > "Teto de escala dos cartões. Tira horizontal de altura fixa com rótulo de até duas linhas — o formato menos elástico do app. Acima de 1,5× o cartão passaria a ocupar mais que a lista de lojas que ele filtra."
  - 💡 Explicação Leiga: A linha limita o crescimento dos cartões quando a letra aumenta.

  > "Lado do círculo da categoria. Fixo de propósito: é uma superfície colorida de identidade, não um bloco de texto."
  - 💡 Explicação Leiga: A linha define 72 pontos como tamanho do círculo colorido.

  > "Largura do item (círculo + rótulo de até duas linhas). Precisa de folga além do círculo para o nome não quebrar cedo demais."
  - 💡 Explicação Leiga: A linha define 78 pontos como largura de cada cartão.

  > "Só a metade de texto cresce — crescer o círculo junto com a fonte só o faria disputar espaço com o rótulo logo abaixo."
  - 💡 Explicação Leiga: A linha faz apenas a parte do texto crescer com a letra.

  > "Tocar na categoria já marcada desfaz o recorte."
  - 💡 Explicação Leiga: A linha remove o filtro quando o usuário toca na categoria já escolhida.

  > "Cartão de uma categoria: arte (ou ícone, quando ela ainda não tem arte) sobre o círculo na cor de identidade, com o nome embaixo. Marcado, ganha borda e rótulo na cor da categoria — que é também a deixa de que ele pode ser desmarcado."
  - 💡 Explicação Leiga: Esta classe desenha um cartão de categoria.

  > "Este filtro já não dependia só de cor: a borda de 1,5px no estado ativo é marcação estrutural, então aqui faltava apenas a semântica (o nó de botão e o 'selecionado')."
  - 💡 Explicação Leiga: A linha informa ao leitor de tela qual categoria está marcada.

  > "Caminho da arte, ou `null` na categoria que ainda não tem uma."
  - 💡 Explicação Leiga: A linha guarda o endereço da imagem da categoria.

  > "Lado do desenho dentro do círculo. Bem maior que o ícone que substitui porque a arte já traz margem no próprio canvas — em 31 o objeto sairia minúsculo."
  - 💡 Explicação Leiga: A linha define 62 pontos como tamanho do desenho dentro do círculo.

  > "Fallback compartilhado: categoria sem arte, e também arte que sumiu do bundle — nos dois casos o filtro continua legível com o ícone, nunca com o quadrado do 'X' de imagem quebrada."
  - 💡 Explicação Leiga: A função desenha o ícone quando não existe imagem.

  > "Dobro do lado desenhado cobre telas de até 2× sem decodificar o PNG de 1024px inteiro pra caber num círculo de 72."
  - 💡 Explicação Leiga: A linha reduz a imagem antes de desenhar, economizando memória.

### 📂 ARQUIVO: lib/features/search/presentation/widgets/search_field.dart

- ⚙️ Função: Desenha a barra de busca em formato de cápsula.
- 💬 Comentários Removidos:

  > "Campo de página, não elemento flutuante: superfície rebaixada (`surfaceAlt`) e cápsula, a mesma forma da busca que flutua sobre o mapa — as duas são a mesma função do app e agora têm a mesma silhueta. Em repouso o traço é `divider`, não `border`: quem delimita o campo é o próprio preenchimento rebaixado, e o contorno só arremata a forma. Com `border` ele desenhava um anel nítido em volta da cápsula, que lia como moldura em vez de campo. No foco o traço volta forte (marca, 1,5px) — é ali que ele carrega informação de verdade."
  - 💡 Explicação Leiga: A linha desenha a barra de busca em cápsula. A borda fica mais forte quando o campo está selecionado.

  > "Com a cápsula, o conteúdo precisa recuar das curvas: à esquerda a lupa encostaria no arco e à direita o 'x' faria o mesmo."
  - 💡 Explicação Leiga: A linha afasta os ícones das bordas curvas.

  > "O preenchimento é do container acima, que é quem também desenha a borda e o padding. Deixar o `filled` do tema ligado pintaria um retângulo de `surfaceAlt` por dentro do padding, e ele apareceria como um degrau reto dentro da cápsula."
  - 💡 Explicação Leiga: A linha desliga o preenchimento automático, para não desenhar um retângulo dentro da cápsula.

  > "Os quatro slots, não só `border`. `InputDecoration.border` é apenas o fallback: quando `enabledBorder`/`focusedBorder` ficam nulos aqui, eles herdam o `inputDecorationTheme` do app e o campo passava a desenhar TAMBÉM o contorno `borderStrong` de raio 12 do tema, por dentro da cápsula do container. Era esse traço duplo — o forte do tema por dentro do fraco do container — que deixava a borda tão nítida."
  - 💡 Explicação Leiga: A linha desliga todas as bordas internas do campo, evitando um contorno duplo.

### 📂 ARQUIVO: lib/features/search/presentation/widgets/search_history.dart

- ⚙️ Função: Mostra a lista de buscas recentes abaixo da barra de busca.
- 💬 Comentários Removidos:

  > "Sem override de cor: legenda() já resolve pra secondaryText."
  - 💡 Explicação Leiga: A linha usa a cor padrão do estilo de legenda.

---

## ⚙️ PARTE 17 — CONFIGURAÇÕES

### 📂 ARQUIVO: lib/features/settings/presentation/pages/settings_page.dart

- ⚙️ Função: Tela de configurações, com tema, permissões, termos e exclusão de conta.
- 💬 Comentários Removidos:

  > "Tela dedicada de Configurações — antes estas opções (aparência, permissões de GPS, excluir conta, como funciona, termos) viviam achatadas no meio da lista do Perfil, junto de 'Editar Perfil' e 'Minhas avaliações', misturando ajustes do app com atalhos de conteúdo. Compartilhada entre consumidor e comerciante: o que muda entre os dois é só a página de 'Como funciona' e a chamada de exclusão de conta, ambas injetadas por quem abre a tela."
  - 💡 Explicação Leiga: Esta classe desenha a tela de configurações. Ela é a mesma para cliente e comerciante.

  > "Exclui a conta no backend (DELETE /comerciantes|consumidores/{id}). `null` esconde o item 'Excluir conta' — é o caso do comerciante hoje, enquanto o endpoint ainda falha com 409 por dependências não limpas (favoritos da loja, posts, pix). Voltar a passar a callback quando o backend fizer o cascade completo."
  - 💡 Explicação Leiga: A linha recebe a função de apagar a conta. A opção fica escondida quando ela não é informada.

  > "Hook extra no encerramento de sessão (ex: limpar favoritos do consumidor) — mesmo contrato do logout no Perfil."
  - 💡 Explicação Leiga: A linha permite executar algo a mais ao sair da conta.

  > "Mesmo fluxo que rodava no Perfil antes de 'Excluir conta' migrar pra cá: confirma, apaga no backend, limpa a sessão local e o estado com escopo de usuário, e volta pra home de visitante sem histórico."
  - 💡 Explicação Leiga: A função apaga a conta e leva o usuário para a tela de visitante.

  > "44, não 40: era o único alvo de toque do app ainda abaixo do mínimo. Icon-only, então não escala com a fonte — o que ele precisava era do tamanho certo."
  - 💡 Explicação Leiga: A linha aumenta a área de toque do botão para 44 pontos.

  > "Seletor de tema em pílula segmentada. Três opções, não duas: o modo 'Automático' é o padrão de quem nunca escolheu tema — um par Claro/Escuro forçaria essas pessoas a sair dele sem querer."
  - 💡 Explicação Leiga: Esta classe desenha o seletor com três opções de tema.

  > "Isolamento de rebuild: só o segmentado escuta o ThemeController — o resto da tela de configurações não reconstrói a cada troca."
  - 💡 Explicação Leiga: A linha faz só o seletor ser redesenhado ao trocar o tema.

  > "Segmentado: aqui o estado ativo não é só cor — o segmento escolhido ganha uma superfície que os outros não têm, e a presença desse bloco é perceptível sem distinguir matiz. Faltava só o nó de semântica com o 'selecionado'."
  - 💡 Explicação Leiga: A linha informa ao leitor de tela qual tema está escolhido.

  > "Segmento com rótulo dentro: altura mínima, não fixa — o seletor vive numa Column e tem para onde crescer."
  - 💡 Explicação Leiga: A linha define altura mínima de 42 pontos, permitindo crescer.

  > "`selectedSurface`: o mesmo 'segmento ativo' do seletor de tipo de conta e dos chips de período — e que inverte no tema escuro, onde o preto da marca ficaria indistinguível do fundo."
  - 💡 Explicação Leiga: A linha usa a cor padrão do item selecionado, que inverte no tema escuro.

---

## 🗺️ PARTE 18 — LOJAS E MAPA (DADOS)

### 📂 ARQUIVO: lib/features/store/data/models/categoria_model.dart

- ⚙️ Função: Guarda o número e o nome de uma categoria de loja.
- 💬 Comentários Removidos:

  > "Modelo de categoria retornado por GET /categorias."
  - 💡 Explicação Leiga: Esta classe guarda os dados de uma categoria vinda do servidor.

### 📂 ARQUIVO: lib/features/store/data/models/store_create_request.dart

- ⚙️ Função: Monta o pacote de dados enviado ao servidor ao criar ou salvar uma loja.
- 💬 Comentários Removidos:

  > "Payload completo de uma loja existente, com os campos indicados sobrescritos. Ponto único que define 'o que é o corpo de um PUT de loja'. Antes, cada tela montava o seu: a ronda de GPS (hoje `StoreRondaController`) omitia `endereco`, `cidade`, `estado` e `cep` a cada envio de posição — se o backend fizer replace (e não merge) nesses campos, cada deslocamento do comerciante apagava o endereço cadastrado da loja. Regra de negócio preservada: `statusLoja` só muda quando explicitamente informado. `SUSPENSA` é decisão exclusiva de administrador e nunca deve partir do app do comerciante."
  - 💡 Explicação Leiga: A função monta o pacote completo da loja. Antes o endereço era apagado a cada envio de posição.

### 📂 ARQUIVO: lib/features/store/data/models/store_dto.dart

- ⚙️ Função: Guarda todos os dados de uma loja recebidos do servidor.
- 💬 Comentários Removidos:

  > "Nome da 1ª categoria (cards / chips de busca)"
  - 💡 Explicação Leiga: A linha guarda o nome da primeira categoria, usado nos cartões.

  > "IDs para edição de loja"
  - 💡 Explicação Leiga: A linha guarda os números das categorias, usados na tela de edição.

  > "Todos os nomes (tela de detalhes)"
  - 💡 Explicação Leiga: A linha guarda todos os nomes de categoria da loja.

  > "Foto de capa"
  - 💡 Explicação Leiga: A linha guarda o endereço da foto principal da loja.

  > "Fotos internas (cardápio/vitrine)"
  - 💡 Explicação Leiga: A linha guarda os endereços das fotos da galeria.

  > "true quando a loja tem coordenadas suficientes para aparecer no mapa."
  - 💡 Explicação Leiga: A linha informa se a loja tem posição definida.

  > "Endereço legível pra exibição (ex: 'Rua X, Cidade - UF')."
  - 💡 Explicação Leiga: A linha monta o endereço completo em uma frase.

  > "Uma foto representativa da loja, pra widgets que só precisam de uma imagem (cards de busca, favoritos): a capa, ou a primeira da galeria se não houver capa definida."
  - 💡 Explicação Leiga: A linha devolve a foto principal da loja, ou a primeira da galeria.

  > "Leitura via [JsonReader]: `id` é o único campo obrigatório (sem ele não existe loja), e a falta dele vira `ParseException` nomeada em vez do `TypeError` que o `as num` produzia — erro que escapava de todo o tratamento de exceção do app. Os demais campos são deliberadamente tolerantes: a mesma classe é preenchida por endpoints diferentes (`/lojas`, `/lojas/ativas/completa`, `/favoritos/completo`), e nem todos devolvem o objeto inteiro."
  - 💡 Explicação Leiga: A função lê os dados da loja. Só o número de identificação é obrigatório.

  > "Suporta campo 'avaliacao' (legado) ou 'mediaAvaliacao' (endpoints /completa)"
  - 💡 Explicação Leiga: A linha aceita dois nomes diferentes para o campo da nota.

  > "Extrai o nome da primeira categoria para exibição nos cards. Suporta: `categorias: [{id, nome}]`, `categorias: [int]` ou `categoria: 'string'`"
  - 💡 Explicação Leiga: A função lê o nome da primeira categoria em três formatos diferentes.

  > "Extrai todos os nomes de categoria para exibição na tela de detalhes. Suporta: `categorias: [{id, nome}]` (endpoints legados) ou `categorias: ['nome', ...]` (endpoints /mobile/api/v1/lojas, que não expõem id — só nome, pra listagem/leitura, não pra edição)."
  - 💡 Explicação Leiga: A função lê todos os nomes de categoria em dois formatos diferentes.

  > "Extrai lista de IDs das categorias. Suporta `categorias: [{id, nome}]` ou `categorias: [int]`; entradas sem id (ex: lista de nomes crus vinda de /mobile/api/v1/lojas) são ignoradas — essas telas não editam a loja, só listam/exibem."
  - 💡 Explicação Leiga: A função lê os números das categorias, ignorando entradas que só têm nome.

### 📂 ARQUIVO: lib/features/store/data/nearby_filter.dart

- ⚙️ Função: Filtra as lojas que estão dentro do raio de distância escolhido.
- 💬 Comentários Removidos:

  > "Corte por raio das lojas do mapa. Vive fora do widget de propósito: é a única regra de negócio do filtro de distância da home, e dentro de um `State` ela só era verificável abrindo o app com o GPS ligado. Aqui é uma função pura — mesma entrada, mesma saída, testável sem mapa, sem GPS e sem rede. O contrato, incluindo os casos em que ele NÃO corta: [raioKm] nulo é o 'Todos' do modal de filtros: devolve a lista inteira, sem corte. É escolha do usuário. Sem posição do usuário ([lat]/[lng] nulos) também devolve a lista inteira. Não há de onde medir distância, e um mapa vazio seria pior do que um mapa sem filtro. Vale registrar que este caso é silencioso: o chip '1 km' continua marcado no modal enquanto nada está sendo filtrado. Quem chama é que tem contexto pra avisar o usuário — ver [temPosicaoParaFiltrar]. Loja sem coordenadas é excluída quando há um raio ativo: não dá pra afirmar que ela está dentro de 1 km se não se sabe onde ela fica."
  - 💡 Explicação Leiga: A função devolve só as lojas dentro da distância escolhida. Sem GPS, ela devolve todas as lojas.

  > "`true` quando o raio escolhido está de fato sendo aplicado. Serve para a UI distinguir 'não há loja nenhuma dentro de 1 km' de 'o raio de 1 km não está valendo porque não sabemos onde você está' — dois estados que hoje produzem telas parecidas e exigem ações opostas do usuário."
  - 💡 Explicação Leiga: A função informa se o filtro de distância está realmente valendo.

### 📂 ARQUIVO: lib/features/store/data/services/categoria_service.dart

- ⚙️ Função: Busca a lista de categorias no servidor e guarda o resultado na memória.
- 💬 Comentários Removidos:

  > "Acesso a `GET /categorias`, com cache de processo. Por que o cache existe: A lista de categorias é praticamente imutável (muda quando o administrador cadastra uma nova, o que não acontece durante o uso do app) e é pedida por quatro telas independentes: a busca, o cadastro de loja, o painel do comerciante e o explorador do mapa da home. Cada uma criava seu próprio `CategoriaService` e chamava [getAll] no `initState`. Como as abas vivem juntas num `IndexedStack`, elas montam praticamente ao mesmo tempo: eram quatro requisições idênticas em voo, no exato momento em que o app também busca lojas, favoritos e posição do GPS. Duas defesas, não uma: Cache sozinho não resolveria: as quatro chamadas partem antes de qualquer uma responder, então não há o que consultar ainda. Por isso há também a deduplicação por [_emVoo] — a segunda chamada concorrente recebe a mesma `Future` da primeira, em vez de abrir outra requisição. O que este cache ainda não é: Vive só em memória: fechar o app o descarta. Persistir em disco fica para a camada offline-first, que vai guardar lojas e avaliações no mesmo lugar — criar agora um mecanismo próprio só para categorias seria mais um formato para migrar depois."
  - 💡 Explicação Leiga: Esta classe busca as categorias uma vez e guarda na memória. Quatro telas pedem a mesma lista ao mesmo tempo.

  > "`static`: o cache é do processo, não da instância — cada tela constrói o seu próprio `CategoriaService`, e um cache de instância não seria compartilhado por ninguém."
  - 💡 Explicação Leiga: A linha guarda a lista de forma compartilhada por todo o aplicativo.

  > "Requisição em andamento, se houver. É o que faz quatro chamadas simultâneas virarem uma só."
  - 💡 Explicação Leiga: A linha guarda a busca em andamento. Pedidos simultâneos recebem a mesma resposta.

  > "Teto de validade. Alto de propósito: na prática o app não fica 24h aberto, então isto é menos 'revalidar de vez em quando' e mais uma rede de segurança para uma sessão que ficou dias em segundo plano."
  - 💡 Explicação Leiga: A linha define 24 horas como validade da lista guardada.

  > "Busca as categorias, servindo do cache quando ele ainda vale. [forcarAtualizacao] ignora o cache e vai à rede — para um 'puxar para atualizar' ou para uma tela que precise ver uma categoria recém-criada."
  - 💡 Explicação Leiga: A função devolve as categorias guardadas, ou busca no servidor quando pedido.

  > "Também no caminho de erro: falha não pode deixar uma `Future` já rejeitada pendurada em [_emVoo], ou toda tentativa seguinte receberia a mesma falha sem nunca refazer a requisição. O erro em si continua subindo para quem chamou — as quatro telas já sabem exibi-lo."
  - 💡 Explicação Leiga: A linha limpa a busca em andamento mesmo quando ela falha.

  > "Zera o cache. Existe para os testes: [_cache] é estático e vazaria de um caso para o outro."
  - 💡 Explicação Leiga: A função apaga a lista guardada. Ela existe para os testes.

### 📂 ARQUIVO: lib/features/store/data/services/route_service.dart

- ⚙️ Função: Calcula o caminho a pé entre o usuário e uma loja.
- 💬 Comentários Removidos:

  > "Rota calculada entre dois pontos: o traçado pelas ruas e a distância total."
  - 💡 Explicação Leiga: Esta classe guarda o caminho desenhado e a distância.

  > "Calcula rotas pela API pública do OSRM (OpenStreetMap) — grátis e sem chave. Usa um Dio avulso porque a URL é externa (não passa pelo ApiClient, que tem baseUrl/autenticação da API interna do MapFood)."
  - 💡 Explicação Leiga: Esta classe consulta um serviço público de rotas. Ela usa uma conexão separada.

  > "Cache em memória das últimas rotas calculadas — evita recalcular (e esperar o round-trip do OSRM) quando o usuário volta a pedir a mesma rota, ex: sair e voltar pra tela 'Visualizar no mapa' da mesma loja. Compartilhado entre instâncias (static) porque cada tela cria seu próprio `RouteService()`."
  - 💡 Explicação Leiga: A linha guarda as últimas rotas calculadas, para não recalcular a mesma.

  > "Rota a pé entre [origem] e [destino]. Devolve null em qualquer falha — o chamador decide o fallback (ex: linha reta)."
  - 💡 Explicação Leiga: A função calcula o caminho a pé. Se falhar, quem chamou desenha uma linha reta.

  > "Move pro topo (mais recente) e devolve sem bater na rede."
  - 💡 Explicação Leiga: A linha devolve a rota guardada sem consultar a internet.

  > "GeoJSON usa [longitude, latitude]. O par é tipado como List antes de ser indexado — indexar direto no `dynamic` esconderia um payload malformado do OSRM até virar erro em runtime."
  - 💡 Explicação Leiga: A linha lê as coordenadas na ordem invertida usada pelo serviço.

### 📂 ARQUIVO: lib/features/store/data/services/store_service.dart

- ⚙️ Função: Busca, cria, atualiza e apaga lojas no servidor.
- 💬 Comentários Removidos:

  > "Envia a foto de capa da loja. O corpo da resposta do POST não é confiável, então busca a loja novamente pra devolver o estado atualizado. Usa bytes (não o path) porque o Flutter Web não expõe caminho de arquivo."
  - 💡 Explicação Leiga: A função envia a foto de capa e depois busca a loja de novo.

  > "Envia fotos para a galeria interna da loja (máx. 10 no backend)."
  - 💡 Explicação Leiga: A função envia até dez fotos para a galeria da loja.

  > "Lojas ativas com mediaAvaliacao/totalAvaliacoes já agregados (`GET /lojas/ativas/completa`, endpoint aditivo da API geral — o antigo `/lojas/ativas` devolvia a entidade pura, sem esses campos, daí o 'Novo' indevido nos cards)."
  - 💡 Explicação Leiga: A função busca as lojas abertas já com a nota média incluída.

  > "Ranking de popularidade (mais acessadas, via pi_acesso_loja) — já vem com a mesma agregação de avaliação do endpoint acima."
  - 💡 Explicação Leiga: A função busca as lojas mais visitadas.

  > "Detalhe de uma loja com a agregação de avaliação pronta — usado onde hoje só temos o `id` (ex: comerciante vendo a nota da própria loja) e não queremos mais calcular a média na mão no cliente."
  - 💡 Explicação Leiga: A função busca os dados de uma loja com a nota já calculada.

  > "Troca só o status (ATIVA/INATIVA). A rota geral `PUT /lojas/{id}` exige o objeto Loja completo (`@Valid`), então reenvia o estado que o chamador já tem em mãos com o status alterado. O backend continua rejeitando SUSPENSA vinda daqui (exclusiva de administrador). Recebe a [StoreDto] em vez do id: a versão anterior fazia `getById` seguido de `update` — um read-modify-write não atômico que abria janela para corrida com a ronda de GPS, que escreve na mesma entidade a cada deslocamento. Fechar a loja durante um PUT de posição em voo podia reverter o status recém-gravado."
  - 💡 Explicação Leiga: A função troca o status da loja. Ela usa os dados que já estão na tela, evitando conflito com o GPS.

  > "Atualiza apenas a posição da loja (ronda do comerciante), preservando todo o resto do cadastro — inclusive o endereço, que o payload montado à mão na tela deixava de fora."
  - 💡 Explicação Leiga: A função envia a nova posição sem apagar os outros dados da loja.

  > "Exclusão de loja — hard delete via o endpoint legado (mesmo caminho da Web): apaga a loja e cascade de avaliações/denúncias/acessos de vez, sem ficar 'meio excluída' só num dos dois clientes."
  - 💡 Explicação Leiga: A função apaga a loja e tudo ligado a ela.

### 📂 ARQUIVO: lib/features/store/presentation/controllers/active_stores_manager.dart

- ⚙️ Função: Mantém atualizada a lista de lojas abertas, consultando o servidor a cada 20 segundos.
- 💬 Comentários Removidos:

  > "Lista de lojas ativas ('perto de mim'), compartilhada entre as home pages de guest/consumidor/comerciante — antes cada uma buscava uma vez só no `initState` e ficava com o dado congelado enquanto a aba seguia viva no `IndexedStack` (ex: uma loja ficar online não aparecia até reiniciar o app). Como a API não expõe nenhum mecanismo de push (WebSocket/SSE), a 'reatividade' aqui é via polling: assim que a primeira tela começa a ouvir, refaz a busca periodicamente e notifica os ouvintes."
  - 💡 Explicação Leiga: Esta classe busca as lojas abertas de tempos em tempos. Sem isso, uma loja que abriu agora só apareceria ao reiniciar o app.

  > "Troca o service num teste — mesmo motivo do [FavoritesManager]: o singleton resolve o `ApiClient` antes de o teste poder substituí-lo."
  - 💡 Explicação Leiga: A linha permite trocar o mecanismo de busca nos testes.

  > "Sem `List.unmodifiable`: `_stores` é substituída em [load], nunca mutada, então devolvê-la direto é seguro. A cópia defensiva custava uma alocação por leitura — e o build da home lia este getter duas vezes por frame para montar o filtro de categoria."
  - 💡 Explicação Leiga: A linha devolve a lista diretamente, sem copiar. Copiar gastava memória a cada desenho da tela.

  > "Polling só faz sentido com o app à vista. Sem isto, o app continuava batendo em `GET /lojas/ativas/completa` a cada 20s com a tela desligada — 180 requisições por hora de lista completa, em rede móvel."
  - 💡 Explicação Leiga: A linha para as consultas quando o aplicativo sai da tela, economizando dados.

  > "Ao voltar, refaz a busca imediatamente: o que estava na tela pode estar minutos desatualizado."
  - 💡 Explicação Leiga: A linha busca a lista de novo assim que o usuário volta ao aplicativo.

  > "`hasListeners` do próprio ChangeNotifier, em vez de um contador manual que dessincroniza se `removeListener` for chamado com um listener que nunca foi registrado."
  - 💡 Explicação Leiga: A linha verifica se alguma tela está ouvindo, usando o mecanismo pronto do Flutter.

  > "Busca as lojas ativas na API. Seguro de chamar mais de uma vez — só mostra o loading (`isLoading`) na primeira vez; refreshes em segundo plano trocam a lista sem piscar um spinner pra quem já está vendo o mapa."
  - 💡 Explicação Leiga: A função busca as lojas. O carregamento só aparece na primeira vez.

  > "Mantém a última lista boa se a API estiver indisponível."
  - 💡 Explicação Leiga: A linha mantém a lista anterior quando o servidor não responde.

### 📂 ARQUIVO: lib/features/store/presentation/controllers/store_map_controller.dart

- ⚙️ Função: Comanda a câmera do mapa: zoom, centralizar e travar a rotação.
- 💬 Comentários Removidos:

  > "Permite que a tela dona do mapa comande a câmera sem conhecer o `MapController` do flutter_map — quem monta o `StoreMapView` cria um destes, passa adiante e chama [focarEm] / [centralizarNoUsuario]. Existe por causa da home: lá os controles de câmera são desenhados fora do mapa (para ficarem ancorados acima da bottom bar flutuante), e precisam de um jeito de falar com ele."
  - 💡 Explicação Leiga: Esta classe permite controlar o mapa de fora dele. Na tela principal os botões ficam fora do mapa.

  > "Trava de rotação do mapa. Fica aqui (e não só dentro do `StoreMapView`) porque na home o botão que a alterna vive fora do mapa."
  - 💡 Explicação Leiga: A linha guarda se a rotação do mapa está travada.

  > "Zoom da câmera, realimentado pelo [StoreMapView] a cada movimento do mapa. `ValueNotifier` e não um getter simples porque os botões de ampliar/reduzir precisam se apagar ao encostar no limite — e ler isso via `setState` reconstruiria o mapa a cada quadro de arrasto e de pinça."
  - 💡 Explicação Leiga: A linha guarda o nível de zoom atual. Os botões se apagam ao atingir o limite.

  > "Chamado pelo [StoreMapView] ao montar/desmontar."
  - 💡 Explicação Leiga: A função conecta o controlador ao mapa.

  > "Travar 'torto' não faz sentido: ao travar, volta o norte para cima."
  - 💡 Explicação Leiga: A linha volta o mapa para o norte quando a rotação é travada.

  > "Limites de zoom do app. Os mesmos valores alimentam o `MapOptions` do [StoreMapView], para que os botões de ampliar/reduzir e o gesto de pinça parem no mesmo lugar — botão que continua clicável sem fazer nada é exatamente o que confunde quem navega por leitor de tela."
  - 💡 Explicação Leiga: A linha define os limites de zoom. Os botões e o gesto de pinça param no mesmo ponto.

  > "Um nível por toque: é o passo dos apps de mapa, e cada toque dobra (ou divide por dois) a escala — grande o bastante pra ser perceptível sem exigir uma sequência longa de toques."
  - 💡 Explicação Leiga: A linha define que cada toque muda um nível de zoom.

  > "Nível anunciado ao leitor de tela: '3 de 15' é legível, '14.7' não."
  - 💡 Explicação Leiga: A linha converte o zoom em um número inteiro para o leitor de tela.

  > "Alternativa por toque ao gesto de pinça, que exige dois dedos e um movimento preciso — impossível com uma mão só, com mobilidade reduzida ou navegando por leitor de tela."
  - 💡 Explicação Leiga: A função amplia o mapa por toque, sem precisar do gesto de pinça.

  > "Mantém o centro: o zoom por botão não pode arrastar o mapa junto, senão a pessoa perde a referência do que estava olhando."
  - 💡 Explicação Leiga: A linha mantém o mapa no mesmo ponto ao mudar o zoom.

  > "Enquadra [alvo] deixando-o a [biasVertical] da altura visível, medida do topo (0.5 = centro da tela, 0.3 = um terço abaixo do topo). Serve para enquadrar um ponto fora do centro geométrico quando algo flutua sobre o mapa. Em vez de mexer na projeção interna do mapa, o deslocamento é convertido de pixels para graus de latitude pela resolução do zoom atual — a mesma conta que o Web Mercator usa."
  - 💡 Explicação Leiga: A função centraliza um ponto do mapa em uma altura escolhida da tela.

  > "Quantos pixels o alvo precisa subir em relação ao centro da tela."
  - 💡 Explicação Leiga: A linha calcula o deslocamento em pontos de tela.

  > "Resolução do Web Mercator no paralelo atual: metros por pixel."
  - 💡 Explicação Leiga: A linha calcula quantos metros cabem em cada ponto da tela.

  > "Centro ao sul do alvo → alvo sobe na tela. 111320 m ≈ 1 grau de latitude."
  - 💡 Explicação Leiga: A linha converte o deslocamento de metros para coordenadas.

  > "Centraliza na posição do usuário mantendo o zoom atual — ou subindo para um zoom de 'rua' se o mapa estiver muito afastado."
  - 💡 Explicação Leiga: A função centraliza o mapa na posição do usuário.

### 📂 ARQUIVO: lib/features/store/presentation/controllers/store_register_controller.dart

- ⚙️ Função: Guarda os dados preenchidos durante o cadastro de uma loja nova.
- 💬 Comentários Removidos:

  > "As três etapas do cadastro de loja. A divisão não é por tamanho de formulário, é por pergunta: quem é você, onde você fica, e como o cliente te encontra. Cada etapa responde uma, e é isso que permite parar no meio sem ficar com um pensamento pela metade."
  - 💡 Explicação Leiga: Esta lista define as três etapas do cadastro de loja.

  > "Estado do cadastro de loja — campos, fotos, categorias e em que etapa a pessoa está. Existe para que a página seja só desenho. Com o fluxo em etapas, o mesmo dado é lido e escrito de três telas diferentes, e manter tudo em `setState` espalharia a regra de 'esta etapa está completa?' pelos widgets."
  - 💡 Explicação Leiga: Esta classe guarda tudo o que foi preenchido no cadastro. A tela só desenha.

  > "etapas"
  - 💡 Explicação Leiga: Marca o início do trecho que controla as etapas.

  > "Endereço é opcional no MapFood — muitos comércios são ambulantes. Com a etapa em branco, o botão de avançar diz 'Pular por enquanto' em vez de fingir que há algo pendente ali."
  - 💡 Explicação Leiga: A linha informa se a etapa de endereço está vazia. O endereço não é obrigatório.

  > "fotos"
  - 💡 Explicação Leiga: Marca o início do trecho que guarda as fotos escolhidas.

  > "categorias"
  - 💡 Explicação Leiga: Marca o início do trecho que guarda as categorias escolhidas.

  > "Mensagem de falha da busca — `null` quando deu certo (inclusive com lista vazia, que é outro estado)."
  - 💡 Explicação Leiga: A linha guarda o erro ao buscar as categorias.

  > "Falha aqui não pode ser silenciosa: escolher categoria é obrigatório para concluir, e uma seção vazia deixa a pessoa presa olhando um botão que não funciona, sem nada para tocar."
  - 💡 Explicação Leiga: A função busca as categorias e guarda o erro se falhar.

  > "Devolve `false` quando o toque foi recusado por já estar no limite — quem chama avisa a pessoa."
  - 💡 Explicação Leiga: A função marca ou desmarca uma categoria. Ela recusa quando o limite foi atingido.

  > "envio e rascunho"
  - 💡 Explicação Leiga: Marca o início do trecho que controla o envio do cadastro.

  > "Erro do envio. É estado da tela, não notificação: fica visível junto do botão até ser corrigido, em vez de sumir sozinho como um toast."
  - 💡 Explicação Leiga: A linha guarda o erro do envio, que fica visível até ser resolvido.

  > "Alimenta o `UnsavedChangesGuard`. `ValueNotifier` separado para o guard reconstruir sozinho, sem passar pelo `notifyListeners` da página inteira a cada tecla digitada."
  - 💡 Explicação Leiga: A linha informa se existe algo digitado e não salvo.

  > "Impedimento da etapa atual, ou `null` se ela está pronta para avançar. Só cobre o que um `Form` não valida sozinho (foto e categorias); os campos de texto ficam com o `validator` de cada um, onde o erro aparece embaixo do campo certo."
  - 💡 Explicação Leiga: A função verifica se falta algo para avançar de etapa.

  > "Cria a loja e envia as fotos. Devolve a loja criada, ou `null` se falhou — nesse caso [erro] tem a mensagem. O aviso de fotos que falharam vem em [avisoFotos], porque a loja existe mesmo assim e mandar tudo de volta como erro faria a pessoa tentar cadastrar de novo."
  - 💡 Explicação Leiga: A linha guarda um aviso separado sobre fotos que não subiram. A loja é criada mesmo assim.

  > "`true` quando a loja nasceu sem coordenadas e, portanto, `INATIVA`."
  - 💡 Explicação Leiga: A linha informa que a loja foi criada sem posição no mapa.

  > "Sem localização a loja fica invisível no mapa mesmo com status ATIVA — melhor já nascer INATIVA e deixar claro que falta ativar pela ronda (que captura a posição por GPS) do que criar uma loja 'ativa' fantasma que ninguém encontra."
  - 💡 Explicação Leiga: A linha cria a loja como inativa quando não há endereço. Sem posição ela não apareceria no mapa.

  > "A loja foi criada: não há mais rascunho a proteger, e sem zerar isto o guard interceptaria a própria navegação de sucesso."
  - 💡 Explicação Leiga: A linha limpa o rascunho depois de criar a loja.

  > "Converte o endereço digitado em lat/lng, como ponto de referência inicial. A posição de verdade vem do GPS ao vivo quando a loja fica 'Aberta' (ver a ronda do comerciante); isso aqui é só um fallback para quem quis indicar uma área."
  - 💡 Explicação Leiga: A função transforma o endereço digitado em coordenadas.

  > "O pacote geocoding não tem implementação web."
  - 💡 Explicação Leiga: A linha pula essa conversão quando o app roda no navegador.

---

## 🏬 PARTE 19 — LOJAS E MAPA (TELAS)

### 📂 ARQUIVO: lib/features/store/presentation/pages/more_info_store.dart

- ⚙️ Função: Tela de detalhe de uma loja, com foto, dados, galeria e avaliações.
- 💬 Comentários Removidos:

  > "Tela de detalhe de um comércio. A página é composição: a capa, o resumo, as seções e o bloco de avaliação do consumidor moram em `widgets/store_detail/`. Antes tudo isso — inclusive o diálogo de denúncia e o formulário de avaliação — vivia neste arquivo, em 1195 linhas, com quatro estados de UI (recolhida, filtro de nota, histórico, rascunho) misturados aos dois carregamentos de rede que a página realmente coordena. O que sobrou aqui é exatamente isso: buscar as avaliações e o resumo da loja, e decidir quais seções cada papel de usuário vê. Deixa a capa da loja pronta no cache de memória antes de a tela de detalhe existir. A conta de tempo é esta: a transição de página leva ~300ms, e nesse intervalo a rede fica ociosa enquanto a tela nova é montada. Disparando o download no toque, ele corre durante a animação — e a capa costuma chegar antes do primeiro quadro da tela de destino. Sem `await` de propósito: esperar a foto para só então navegar transformaria um toque instantâneo numa espera de rede, que é exatamente o defeito que isto existe para evitar. Se a imagem não chegar a tempo, a tela abre como sempre abriu e a foto entra com o fade normal."
  - 💡 Explicação Leiga: A função começa a baixar a foto da loja no momento do toque. A foto costuma chegar antes de a tela abrir.

  > "A mesma largura que a capa usa lá dentro. Se as duas divergirem, o precache aquece uma entrada de cache que a tela não lê."
  - 💡 Explicação Leiga: A linha usa exatamente a mesma largura da tela de destino. Um valor diferente desperdiçaria o download.

  > "Abre a tela de detalhe de [store], pré-carregando a capa no caminho. É o jeito padrão de chegar em [MoreInfoStorePage] — use no lugar de montar o `Navigator.push` à mão, para o pré-carregamento não ficar de fora de um ponto de entrada novo."
  - 💡 Explicação Leiga: A função abre a tela de detalhe e já baixa a foto antes.

  > "Quantas avaliações a loja tem, segundo o dado que já chegou junto com ela. Começa em `widget.store.totalAvaliacoes` e é corrigido pelo resumo do backend. Existe porque nem toda tela de origem entrega esse número: quem abre o detalhe a partir de 'Minhas avaliações' ou do perfil do comerciante passa por `GET /lojas/{id}`, que devolve a entidade pura, sem a agregação. Ali `totalAvaliacoes` vem 0 — e a tela exibia '0 Avaliações' no topo enquanto listava cinco logo abaixo."
  - 💡 Explicação Leiga: A linha guarda o total de avaliações. Antes a tela mostrava zero mesmo listando várias.

  > "O número a exibir: a lista carregada é a fonte mais confiável; até ela chegar, vale o que já se sabia."
  - 💡 Explicação Leiga: A linha escolhe qual número mostrar, dando preferência à lista já carregada.

  > "Agregação de avaliação vinda do backend (Fase 4) — não é calculada no cliente. Começa com o que já veio em `widget.store` (pode já estar populado se a tela de origem usou o endpoint completo) e é atualizada com o dado mais fresco assim que a busca abaixo responde."
  - 💡 Explicação Leiga: A linha guarda a nota média vinda do servidor.

  > "Papel do usuário, lido do [SessionStore] — síncrono, sem I/O e sem `setState`."
  - 💡 Explicação Leiga: A linha lê da memória se quem está vendo é cliente, comerciante ou visitante.

  > "Guard de 'sair sem salvar': true enquanto o usuário tiver nota/comentário digitados na seção de avaliação sem enviar — a página inteira precisa saber disso porque a avaliação é só uma seção dela, não uma tela própria. ValueNotifier (não bool + setState) pra não reconstruir a página inteira a cada tecla digitada — o rebuild fica isolado no UnsavedChangesGuard."
  - 💡 Explicação Leiga: A linha informa se existe uma avaliação escrita e não enviada.

  > "Spinner só quando não há nada na tela para olhar — primeira carga ou 'Tentar novamente' depois de um erro. Recarregar após enviar uma avaliação mantém a lista visível: trocá-la por um spinner faria a seção inteira saltar logo depois do toque em 'Enviar'."
  - 💡 Explicação Leiga: A linha só mostra o carregamento quando a lista está vazia.

  > "Busca a agregação de avaliação pronta do backend — garante o selo de nota correto independente de `widget.store` ter vindo de uma tela que já usa o endpoint novo ou de uma que ainda não (ex: Favoritos)."
  - 💡 Explicação Leiga: A função busca a nota média correta no servidor.

  > "O total vinha junto e era descartado — é o que conserta o '0 Avaliações' nas telas que abrem o detalhe sem a agregação."
  - 💡 Explicação Leiga: A linha aproveita o total que já vinha na resposta e antes era jogado fora.

  > "Mantém o que já tinha (de widget.store, ou 'Novo') se a busca falhar."
  - 💡 Explicação Leiga: A linha mantém a nota anterior quando a busca falha.

  > "Puxar para atualizar: as duas buscas da tela, em paralelo (são independentes — em série o gesto duraria a soma das duas)."
  - 💡 Explicação Leiga: A função busca as avaliações e o resumo ao mesmo tempo.

  > "As avaliações e a nota média são o que muda nesta tela enquanto ela está aberta — outra pessoa pode ter avaliado agora."
  - 💡 Explicação Leiga: A linha liga o gesto de puxar para atualizar as avaliações.

  > "Respiro de rodapé: a tela termina numa área de digitação (o comentário da avaliação), que precisa de espaço para subir acima do teclado."
  - 💡 Explicação Leiga: A linha reserva espaço no fim da tela para o teclado não cobrir o campo.

  > "Visitante também vê o formulário, mas em modo vitrine: qualquer toque abre a parede de login (ver ConsumerReviewSection)."
  - 💡 Explicação Leiga: A linha mostra o formulário de avaliação também para visitantes, mas sem funcionar.

### 📂 ARQUIVO: lib/features/store/presentation/pages/store_advanced_page.dart

- ⚙️ Função: Tela com as ações raras e perigosas da loja: inativar e excluir.
- 💬 Comentários Removidos:

  > "O que fica fora do caminho diário: ações raras e as que não têm volta. A separação é o ponto da tela. No painel, tudo está a um toque porque é usado todo dia; excluir a loja não pode dividir esse espaço com 'trocar a foto' — dois toques de distância é o que impede o engano. 'Inativar loja' mora aqui pelo mesmo motivo, mas do outro lado da linha: é a saída de quem quer sumir do mapa por um tempo, e precisa aparecer antes da exclusão para ser encontrada por quem chegou pensando em apagar tudo. Ela grava o mesmo `INATIVA` do botão 'Fechar loja' do painel — a diferença é de intenção (parar por tempo indeterminado × encerrar o dia), não de estado."
  - 💡 Explicação Leiga: Esta classe reúne as ações perigosas em uma tela separada. Isso evita apagar a loja por engano.

  > "Loja alterada no backend (aqui, só o status) — o painel que abriu esta tela precisa refletir a mudança sem esperar um recarregamento."
  - 💡 Explicação Leiga: A linha avisa a tela anterior quando o status muda.

  > "`true` avisa quem abriu esta tela que a lista de lojas mudou."
  - 💡 Explicação Leiga: A linha avisa que a loja foi apagada ao fechar a tela.

  > "A API recusa excluir loja SUSPENSA (403 com mensagem própria) — o botão já não aparece nesse caso, mas o status pode ter mudado enquanto a tela estava aberta."
  - 💡 Explicação Leiga: A linha mostra o erro quando o servidor recusa apagar a loja.

  > "Sem esta explicação, o comerciante encontra uma loja fora do mapa, sem botão de reabrir e sem opção de excluir — e não tem como saber por quê."
  - 💡 Explicação Leiga: A linha explica que a loja foi suspensa pela moderação.

  > "Reativar não cabe aqui: a loja só deve voltar para ATIVA junto de uma posição fresca, senão ela fica 'ativa' no banco e invisível no mapa (o filtro de proximidade ignora loja sem lat/long). Quem faz isso direito é o 'Abrir loja' do painel, que exige o GPS antes."
  - 💡 Explicação Leiga: A linha explica que reativar a loja só pode ser feito pelo botão principal, que pede o GPS.

  > "Bloco informativo das situações em que não há ação a oferecer (loja suspensa pela moderação, ou inativa e reativável só pelo painel)."
  - 💡 Explicação Leiga: Esta classe desenha um aviso explicativo quando não há botão a oferecer.

### 📂 ARQUIVO: lib/features/store/presentation/pages/store_edit_page.dart

- ⚙️ Função: Tela onde o comerciante edita nome, fotos, endereço e categorias da loja.
- 💬 Comentários Removidos:

  > "Edição do perfil público da loja — foto, dados, endereço e categorias. É uma página empurrada, e não um modo da tela de gestão. Antes, consultar e editar dividiam a mesma tela: para ver o nome da loja, o painel montava um formulário inteiro e uma barra flutuante de salvar. Isso é o oposto do que um painel precisa ser — ele responde perguntas rápidas, e formulário é uma tarefa com começo, meio e fim. Devolve a [StoreDto] atualizada pelo `Navigator.pop` quando algo é salvo, ou `null` quando a pessoa sai sem salvar."
  - 💡 Explicação Leiga: Esta classe desenha a tela de editar a loja. Ela é uma tela separada, não um modo do painel.

  > "Fotos escolhidas nesta sessão, ainda não enviadas. As já salvas vivem em `_store.imagemUrl`/`_store.galeria` e são removidas direto no servidor."
  - 💡 Explicação Leiga: A linha guarda as fotos escolhidas que ainda não foram enviadas.

  > "Alimenta o `UnsavedChangesGuard` sem reconstruir a tela a cada tecla."
  - 💡 Explicação Leiga: A linha informa se existem mudanças não salvas.

  > "`true` assim que algo é persistido — o painel precisa saber que a loja mudou mesmo se a pessoa sair pelo gesto de voltar depois de uma remoção de foto (que grava na hora, sem passar pelo 'Salvar')."
  - 💡 Explicação Leiga: A linha marca que algo já foi salvo no servidor.

  > "Falha aqui não pode ser silenciosa: sem categorias na tela, quem abre a edição vê a seção vazia e conclui que perdeu as que já estavam salvas."
  - 💡 Explicação Leiga: A função busca as categorias e mostra o erro se falhar.

  > "`imagemUrl`, não o getter `capaUrl`: este último cai para a primeira foto da galeria quando não há capa definida, e ali 'remover capa' chamaria o endpoint de capa para uma foto que na verdade é da galeria — a chamada volta sem efeito e a foto continua na tela."
  - 💡 Explicação Leiga: A linha usa a capa de verdade, e não a primeira foto da galeria.

  > "Converte o endereço digitado em lat/lng quando ele muda — ponto de referência inicial. A posição de verdade vem do GPS da ronda."
  - 💡 Explicação Leiga: A função transforma o endereço digitado em coordenadas.

  > "O pacote geocoding não tem implementação web."
  - 💡 Explicação Leiga: A linha pula essa conversão no navegador.

  > "Salva direto, sem diálogo de 'deseja confirmar?'. Confirmar aqui pediria duas confirmações para uma ação explícita e reversível, enquanto o descarte — esse sim destrutivo — sairia sem perguntar nada. A fricção fica do lado certo: ver `_cancelar`."
  - 💡 Explicação Leiga: A função salva sem pedir confirmação. A confirmação existe apenas ao descartar.

  > "Descartar é o que não tem volta — é aqui que a confirmação faz sentido."
  - 💡 Explicação Leiga: A função pede confirmação antes de jogar fora as alterações.

  > "A capa de verdade, não o getter `capaUrl` (que cai para a primeira foto da galeria): no editor, a mesma imagem apareceria ao mesmo tempo como capa e como item da galeria, sugerindo uma capa que não existe."
  - 💡 Explicação Leiga: A linha mostra apenas a capa real no editor.

### 📂 ARQUIVO: lib/features/store/presentation/pages/store_map_page.dart

- ⚙️ Função: Mostra o mapa em tela cheia com a rota a pé até a loja escolhida.
- 💬 Comentários Removidos:

  > "Tela cheia com o mapa focado numa única loja — destino do botão 'Visualizar no mapa' na tela de detalhe. Mostra a posição atual do usuário, traça a rota a pé até a loja (OSRM; linha reta como fallback) e exibe a distância."
  - 💡 Explicação Leiga: Esta classe desenha o mapa com o caminho até a loja.

  > "Espelha `_carregandoRota` como ValueListenable pro UnsavedChangesGuard — ele já muda via setState por outros motivos de UI (o pill de loading no mapa), então aqui é só refletir o mesmo valor, sem custo extra de rebuild."
  - 💡 Explicação Leiga: A linha informa que a rota está sendo calculada, para o aviso de saída funcionar.

  > "`getCurrentPosition` espera um fix 'fresco' de GPS — isso, e não o cálculo da rota em si, é o que demora (às vezes vários segundos), mesmo quando a rota já está no cache do RouteService. Por isso, se já existe uma última posição conhecida (leitura instantânea, sem esperar o hardware), traça a rota com ela primeiro — na prática cai direto no cache quando é a mesma loja de uma visita recente — e só depois refina com a posição atual."
  - 💡 Explicação Leiga: A linha usa a última posição conhecida para desenhar a rota na hora. Depois ela é corrigida com a posição atual.

  > "Busca (ou pega do cache) a rota entre [origem] e [destino] e atualiza o estado da tela. Chamado até duas vezes por carregamento — uma vez (opcional) com a última posição conhecida, pra sentir instantâneo, e outra com o fix atual do GPS, pra corrigir caso o usuário tenha andado."
  - 💡 Explicação Leiga: A função calcula a rota e atualiza a tela.

  > "OSRM indisponível — linha reta como fallback."
  - 💡 Explicação Leiga: A linha desenha uma linha reta quando o serviço de rotas não responde.

  > "maybePop (não pop) consulta o PopScope do UnsavedChangesGuard antes de sair — Navigator.pop força a saída e só avisa o guard depois de já ter saído, então o diálogo nunca chegava a aparecer pelo botão visual (só pelo gesto/botão físico de voltar)."
  - 💡 Explicação Leiga: A linha faz o botão de voltar perguntar antes de cancelar o cálculo da rota.

  > "Sem override de cor: legenda() já resolve pra secondaryText."
  - 💡 Explicação Leiga: A linha usa a cor padrão do estilo de legenda.

  > "Elemento flutuante sobre o mapa — cardSurface (Lote 4B)."
  - 💡 Explicação Leiga: A linha usa a cor de cartão no bloco que flutua sobre o mapa.

  > "Sem override de cor: legenda() já resolve pra secondaryText."
  - 💡 Explicação Leiga: A linha usa a cor padrão do estilo de legenda.

### 📂 ARQUIVO: lib/features/store/presentation/pages/store_register_page.dart

- ⚙️ Função: Cadastro da loja em três etapas, obrigatório para o comerciante novo.
- 💬 Comentários Removidos:

  > "Cadastro da loja — a primeira tela obrigatória de quem entra como comerciante (o app redireciona para cá enquanto não houver loja). É um fluxo em três etapas, e não um formulário só, porque este é o momento de conversão: quem chega aqui ainda não sabe se o app vale o esforço, e uma tela com seis campos, editor de fotos e seletor de categorias empilhados responde 'muito' antes de responder 'o quê'. Cada etapa faz uma pergunta — quem é você, onde você fica, como o cliente te encontra — e o botão que conclui está sempre visível no rodapé, nunca a uma rolagem de distância. O estado vive todo em [StoreRegisterController]; esta página é desenho e navegação entre as etapas."
  - 💡 Explicação Leiga: Esta classe desenha o cadastro da loja em três etapas.

  > "Um `Form` por etapa. É o que faz a divulgação progressiva funcionar: 'Continuar' valida só os campos que a pessoa acabou de ver, em vez de acusar erro num campo de outra etapa que ela nem abriu ainda."
  - 💡 Explicação Leiga: A linha cria uma validação separada para cada etapa.

  > "Impedimento da etapa atual (foto faltando, nenhuma categoria). Fica na tela até ser resolvido, junto do rodapé que o disparou — um toast some antes de a pessoa entender o que fazer."
  - 💡 Explicação Leiga: A linha guarda o aviso do que falta na etapa atual.

  > "O controller e o `temRascunho` notificam por canais diferentes: o primeiro em toda mudança de estado, o segundo só quando o formulário passa de vazio para preenchido (ele existe justamente para não reconstruir a tela a cada tecla). O `PopScope` depende dos dois — sem escutar o rascunho aqui, digitar o nome da loja não atualizaria o `canPop`, e o primeiro gesto de voltar sairia da tela levando o que foi escrito."
  - 💡 Explicação Leiga: A linha escuta as duas fontes de mudança. Sem isso o gesto de voltar apagaria o que foi digitado.

  > "O `PageView` é escravo do controller: quem manda na etapa é o estado, e a animação apenas segue. Sem isso, os dois viram donos da mesma verdade e divergem no primeiro gesto interrompido."
  - 💡 Explicação Leiga: A função sincroniza a animação com a etapa atual.

  > "Fecha o teclado antes de trocar de etapa: com ele aberto, a etapa nova entra espremida e a pessoa vê meia tela de conteúdo."
  - 💡 Explicação Leiga: A linha fecha o teclado ao avançar de etapa.

  > "Voltar recua uma etapa antes de tentar sair do cadastro. Só na primeira etapa a saída é de verdade — e aí sim o rascunho é defendido. Um `PopScope` só, em vez do [UnsavedChangesGuard]: aninhar o guard aqui registraria dois interceptadores na mesma rota, e um gesto de voltar na etapa 2 recuaria a etapa e abriria o diálogo de descarte junto."
  - 💡 Explicação Leiga: A função faz o botão de voltar recuar uma etapa. Só na primeira etapa ele sai da tela.

  > "O progresso mora no AppBar: fica fixo enquanto o conteúdo da etapa rola por baixo, que é o único jeito de 'quanto falta' continuar respondido no meio do preenchimento."
  - 💡 Explicação Leiga: A linha coloca a barra de progresso fixa no topo.

  > "Navega só pelo rodapé: arrastar lateralmente pularia a validação da etapa e deixaria campos obrigatórios para trás."
  - 💡 Explicação Leiga: A linha impede trocar de etapa arrastando o dedo.

  > "Endereço é opcional: com a etapa em branco, 'Continuar' sugeriria que falta algo ali. 'Pular' diz a verdade — dá para seguir sem preencher."
  - 💡 Explicação Leiga: A linha troca o texto do botão para "Pular" quando o endereço está vazio.

  > "Moldura comum das etapas: título, apoio e conteúdo rolável. A hierarquia é só tipografia e espaço — sem card, sem borda, sem divisória. Numa etapa que faz uma pergunta de cada vez, moldura é ruído: não há nada de que separar o conteúdo."
  - 💡 Explicação Leiga: Esta classe desenha o título e o conteúdo de cada etapa.

  > "Nesta tela não há foto salva no servidor: os dois caminhos de remoção caem no mesmo descarte local."
  - 💡 Explicação Leiga: A linha apaga a foto apenas do celular, porque ela ainda não foi enviada.

  > "O limite já é barrado pelo próprio picker (via `onLimiteExcedido`), então aqui o toque nunca chega recusado."
  - 💡 Explicação Leiga: A linha marca ou desmarca uma categoria. O limite é controlado em outro lugar.

  > "Última coisa antes de concluir: como a loja entra no ar. É a mecânica que mais confunde quem chega — sem ela, o comerciante termina o cadastro achando que já está no mapa."
  - 💡 Explicação Leiga: A linha explica que a loja só aparece no mapa depois de ser aberta.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/category_picker.dart

- ⚙️ Função: Desenha as etiquetas para escolher as categorias da loja.
- 💬 Comentários Removidos:

  > "Seleção de categorias da loja — os quatro estados de uma vez. Nasceu de uma duplicação real: cadastro de loja e edição de loja tinham cada um a sua cópia dos chips, com raio, peso de fonte e tratamento de erro diferentes; a correção de 'categorias não aparecem' precisou ser escrita duas vezes, em dois arquivos, com dois textos distintos. A falha aqui nunca pode ser silenciosa: escolher categoria é obrigatório para concluir o cadastro, então uma seção vazia deixa a pessoa presa olhando um botão que não funciona, sem nada para tocar."
  - 💡 Explicação Leiga: Esta classe desenha as etiquetas de categoria. Ela é usada no cadastro e na edição da loja.

  > "IDs escolhidos. Em modo leitura, é o que se mostra — e só isso."
  - 💡 Explicação Leiga: A linha guarda as categorias escolhidas.

  > "Mensagem de falha da busca. `null` quando a chamada deu certo (inclusive quando devolveu lista vazia, que é outro estado)."
  - 💡 Explicação Leiga: A linha guarda o erro da busca de categorias.

  > "`null` deixa o seletor em somente-leitura: mostra as categorias já escolhidas como selos, sem oferecer toque."
  - 💡 Explicação Leiga: A linha desliga o toque quando o seletor é só para leitura.

  > "Disparado ao tocar numa categoria não escolhida com o limite já cheio."
  - 💡 Explicação Leiga: A linha avisa a tela quando o limite de categorias é atingido.

  > "200 com lista vazia é diferente de falha: não adianta oferecer 'tentar novamente' para algo que respondeu."
  - 💡 Explicação Leiga: A linha mostra uma mensagem diferente quando o servidor respondeu com lista vazia.

  > "10 de padding vertical dá ~40px de alvo com a fonte de caption — abaixo disso o chip fica difícil de acertar com o polegar."
  - 💡 Explicação Leiga: A linha define o espaço interno da etiqueta, garantindo área de toque suficiente.

  > "Branco sobre a cor de identidade da categoria vale nos dois temas: a cor do chip selecionado não muda com o brightness."
  - 💡 Explicação Leiga: A linha usa texto branco na etiqueta selecionada, em ambos os temas.

  > "Placeholders com a forma dos chips durante o carregamento — um spinner solto no meio da seção não diz o que está vindo, e a seção 'pula' de altura quando os chips chegam."
  - 💡 Explicação Leiga: Esta classe desenha formas cinzas no lugar das etiquetas enquanto elas carregam.

  > "Esqueleto dos chips que vão ocupar este espaço: acompanha a mesma escala deles, senão a lista salta ao terminar de carregar."
  - 💡 Explicação Leiga: A linha usa a mesma altura das etiquetas reais.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/em_alta_list_widget.dart

- ⚙️ Função: Desenha a seção "Em Alta" com as lojas mais bem avaliadas.
- 💬 Comentários Removidos:

  > "Cabeçalho ('Em Alta'). Fica separado da lista pra que ela abaixo continue sendo um sliver de verdade."
  - 💡 Explicação Leiga: Esta classe desenha apenas o título da seção.

  > "Chama para o que a seção é (as lojas mais bem avaliadas), não para o que ela faz — daí a fogueira, e não um gráfico de linha."
  - 💡 Explicação Leiga: A linha escolhe o ícone de fogo para o título.

  > "Lista vertical (mesmo formato de card usado na busca filtrada por categoria, via `StoreListItemWidget`) com as lojas de avaliação acima de 4.5."
  - 💡 Explicação Leiga: Esta classe desenha a lista de lojas com nota acima de 4,5.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/home_filter_modal.dart

- ⚙️ Função: Painel que permite filtrar o mapa por categoria e por distância.
- 💬 Comentários Removidos:

  > "km; null representa 'Todos' (sem filtro de distância)."
  - 💡 Explicação Leiga: A linha lista as distâncias disponíveis. O valor vazio significa sem limite.

  > "Quantas categorias podem ficar marcadas ao mesmo tempo. O teto existe porque o filtro é um recorte: marcar tudo é o mesmo que não marcar nada, e a faixa de chips sobre o mapa não comporta um resumo de muitos itens. Três é o que ainda cabe no rótulo do botão e continua sendo uma escolha."
  - 💡 Explicação Leiga: A linha limita a três o número de categorias marcadas ao mesmo tempo.

  > "Categorias marcadas. Vazio é 'todas' — o estado sem recorte, que antes era o valor sentinela `'Todos'` numa `String` única."
  - 💡 Explicação Leiga: A linha guarda as categorias marcadas. Nenhuma marcada significa todas.

  > "Modal de categoria + distância da aba 'Início' (guest/consumidor/comerciante). Trocar um chip aqui não afeta o mapa até o usuário tocar em 'Aplicar filtros' — só nesse momento o resultado é devolvido pra quem chamou."
  - 💡 Explicação Leiga: A função abre o painel de filtros. As mudanças só valem ao tocar em "Aplicar".

  > "Cópia do conjunto recebido: o modal é um rascunho até 'Aplicar filtros', e mutar o conjunto do chamador aplicaria cada toque na hora — inclusive se o usuário fechasse o sheet arrastando, que é justamente o gesto de desistir."
  - 💡 Explicação Leiga: A linha faz uma cópia dos filtros. Fechar o painel arrastando descarta as mudanças.

  > "Marca/desmarca uma categoria. 'Todos' não alterna: ele limpa, porque não é uma opção ao lado das outras e sim a ausência de recorte."
  - 💡 Explicação Leiga: A função marca ou desmarca uma categoria. Tocar em "Todos" limpa todas.

  > "Aviso, não erro: a escolha anterior continua válida e nada falhou — só existe um teto. Pintar isso de vermelho trataria um limite de produto como defeito."
  - 💡 Explicação Leiga: A linha mostra um aviso amarelo ao atingir o limite, e não um erro vermelho.

  > "A cor de identidade da categoria substitui o `selectedSurface` padrão."
  - 💡 Explicação Leiga: A linha pinta a etiqueta marcada com a cor da própria categoria.

  > "Um tom abaixo do `surface` do sheet, mesmo raciocínio das superfícies aninhadas do Lote 4A/2 — senão o chip não-selecionado fica quase invisível contra o próprio fundo do modal."
  - 💡 Explicação Leiga: A linha usa um fundo mais escuro nas etiquetas não marcadas.

  > "O teto precisa ser visível antes de ser atingido: só avisar no toque da quarta categoria faz o limite parecer um erro do app em vez de uma regra conhecida."
  - 💡 Explicação Leiga: A linha escreve o limite na tela antes de ele ser atingido.

  > "'Todos' não é uma categoria de verdade — mantém o par preto/branco que já inverte corretamente no tema escuro (cardSurface escuro deixaria um preto sólido 'sumir'). Categorias de verdade usam a própria cor de identidade."
  - 💡 Explicação Leiga: A linha usa preto e branco na opção "Todos", diferente das categorias.

  > "'Todos' acende quando nenhuma categoria está marcada — é a representação do conjunto vazio, não um item do conjunto."
  - 💡 Explicação Leiga: A linha acende a opção "Todos" quando nenhuma categoria está marcada.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/home_map_explorer.dart

- ⚙️ Função: Desenha a aba principal com o mapa em tela cheia e os filtros por cima.
- 💬 Comentários Removidos:

  > "Aba 'Início' de guest, consumidor e comerciante: o mapa em tela cheia. Sobre o mapa flutuam apenas a busca/filtro, a faixa de categorias e os controles de câmera. O painel arrastável de 'comércios próximos' que existia aqui foi removido: o mapa com os pins já é a lista, e a busca continua sendo o caminho para ver os comércios em formato de lista."
  - 💡 Explicação Leiga: Esta classe desenha o mapa em tela cheia com a busca e os filtros por cima.

  > "Categorias em foco, no máximo [maxCategoriasFiltro]. Conjunto vazio é 'todas' — o estado sem recorte, que antes era o valor sentinela `'Todos'` numa `String` única. Com mais de uma marcada o critério é OR: aparece a loja que tenha qualquer das categorias. AND devolveria lista vazia quase sempre — a maioria das lojas tem uma ou duas categorias, então exigir as três marcadas ao mesmo tempo esvaziaria o mapa."
  - 💡 Explicação Leiga: A linha guarda as categorias marcadas. Aparece a loja que tiver qualquer uma delas.

  > "Sem categorias carregadas, a home continua funcionando só com 'Todos' — o filtro é um atalho, não um requisito para ver o mapa."
  - 💡 Explicação Leiga: A linha mantém o mapa funcionando mesmo se as categorias não carregarem.

  > "Marca/desmarca uma categoria pela faixa de chips sobre o mapa — mesma regra do modal, incluindo o teto: os dois controles editam o mesmo conjunto, e um que aceitasse a quarta categoria tornaria o limite do outro uma formalidade."
  - 💡 Explicação Leiga: A função marca ou desmarca uma categoria, respeitando o mesmo limite do painel de filtros.

  > "Só a posição do usuário interessa aqui — é o que o botão de recentralizar precisa. A lista de lojas no raio fica com o mapa."
  - 💡 Explicação Leiga: A função guarda apenas a posição do usuário.

  > "Véu no topo: garante contraste da busca sobre qualquer tile — telhado branco, praça clara, área de mata escura."
  - 💡 Explicação Leiga: A linha desenha um escurecimento no topo do mapa, para a busca ficar legível.

  > "Cobre busca + faixa de categorias."
  - 💡 Explicação Leiga: A linha define 210 pontos de altura para esse escurecimento.

  > "O filtro é aplicado DENTRO do builder, e não no build do State: aqui ele lê a lista no mesmo instante em que reage à notificação do manager. Calculado lá fora, o valor ficava preso na closure da primeira montagem (quase sempre vazia) e o mapa só saía do vazio de carona num setState de outra origem — com GPS negado, nunca. OR entre as categorias marcadas: basta a loja ter uma delas. Sem nenhuma marcada não há recorte — o mapa mostra tudo."
  - 💡 Explicação Leiga: A linha aplica o filtro no momento certo. Antes o mapa podia ficar vazio para sempre.

  > "Os controles vivem fora do mapa nesta tela, ancorados acima da bottom bar flutuante do app."
  - 💡 Explicação Leiga: A linha desliga os botões internos do mapa, porque a tela desenha os seus.

  > "O banner de 'sem lojas' colidia com a barra de busca flutuante."
  - 💡 Explicação Leiga: A linha desliga o aviso de "sem lojas" nesta tela.

  > "Busca + filtro num único pill flutuante, com sombra de nível 2 (a de 'flutua sobre outro conteúdo') e superfície do tema — nunca branco literal, que sumiria no tema escuro."
  - 💡 Explicação Leiga: A função desenha a barra de busca flutuante sobre o mapa.

  > "Altura mínima: a barra vive numa Column dentro de SafeArea, então tem para onde crescer quando a fonte do sistema aumenta."
  - 💡 Explicação Leiga: A linha define a altura mínima da barra em 52 pontos.

  > "Decorativo: o rótulo da área de toque já diz 'Buscar'."
  - 💡 Explicação Leiga: A linha esconde o ícone de lupa do leitor de tela.

  > "O leitor de tela não vê o selo de contagem: sem isto, o botão seria anunciado igual com e sem filtro aplicado."
  - 💡 Explicação Leiga: A linha faz o leitor de tela anunciar quantas categorias estão filtrando.

  > "Quantas categorias estão recortando o mapa. Com a tira horizontal rolável, as marcadas podem estar todas fora da vista — sem este selo, um mapa filtrado é indistinguível de um mapa vazio."
  - 💡 Explicação Leiga: A linha desenha um número indicando quantos filtros estão ativos.

  > "Faixa de categorias sobre o mapa. Cada pílula se recorta da cartografia pelo fundo opaco + borda do próprio [AppChoiceChip], reforçados pelo véu em gradiente que cobre esta faixa — sem sombra. Teto de escala da faixa de categorias. Ela é uma tira horizontal flutuando sobre o mapa: diferente da barra de busca, não tem para onde crescer — cada ponto a mais de altura é um ponto a menos de mapa visível, que é o conteúdo principal desta tela. Acima de 1,5× a faixa passaria a competir com o próprio mapa."
  - 💡 Explicação Leiga: A linha limita o crescimento da faixa de categorias sobre o mapa.

  > "O teto entra nos dois lugares de propósito: na altura da faixa e na escala do texto dentro dela. Limitar só um dos dois é o que produz ou texto cortado (faixa parada, texto crescendo) ou faixa com sobra (faixa crescendo, texto parado)."
  - 💡 Explicação Leiga: A linha limita a altura e o texto ao mesmo tempo, para os dois crescerem juntos.

  > "Sem sombra. A pílula já se recorta da cartografia pelo fundo opaco + borda do próprio AppChoiceChip, e o véu em gradiente logo acima cobre justamente esta faixa. A sombra que existia aqui só empilhava um halo escuro atrás de cada chip — visível como sujeira entre um chip e outro, não como profundidade."
  - 💡 Explicação Leiga: A linha desenha as etiquetas sem sombra.

  > "'Todos' acende quando nada está marcado — ele representa o conjunto vazio, não é um item dele."
  - 💡 Explicação Leiga: A linha acende a opção "Todos" quando nenhum filtro está ativo.

  > "Controles de câmera ancorados acima da bottom bar flutuante — sem isso eles nasceriam atrás dela."
  - 💡 Explicação Leiga: A função desenha os botões do mapa acima da barra de navegação.

  > "Acima da bottom bar fixa, incluindo a área segura do aparelho — a barra agora encosta na borda inferior da tela."
  - 💡 Explicação Leiga: A linha calcula a altura reservada para a barra do rodapé.

  > "Ampliar/reduzir por toque: nesta tela o mapa ocupa a tela inteira e a pinça era a única forma de mudar o zoom."
  - 💡 Explicação Leiga: A linha desenha os botões de ampliar e reduzir.

  > "Trava de rotação: vive aqui (e não dentro do mapa) porque os controles internos do StoreMapView estão desligados nesta tela."
  - 💡 Explicação Leiga: A linha desenha o botão que trava a rotação do mapa.

  > "Sem posição ainda, o botão é anunciado como desabilitado em vez de aceitar o toque e não fazer nada."
  - 💡 Explicação Leiga: A linha desativa o botão de centralizar enquanto não há posição do GPS.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/home_section_title.dart

- ⚙️ Função: Desenha o título com ícone das seções da tela de busca.
- 💬 Comentários Removidos:

  > "Cabeçalho das seções de navegação da busca ('Perto de você', 'Em Alta'). Existe porque os dois títulos eram um `Text` solto em arquivos diferentes, com o mesmo `copyWith(fontWeight: w800, color: primaryText)` copiado nos dois — e o ícone teria virado uma terceira cópia da mesma linha. O ícone é decorativo: `ExcludeSemantics` o tira da árvore de acessibilidade, porque o título ao lado já diz o que a seção é. Sem isso o leitor de tela anunciaria um nó de imagem sem rótulo antes de cada seção."
  - 💡 Explicação Leiga: Esta classe desenha o título das seções. O ícone é escondido do leitor de tela.

  > "Acompanha a fonte: um ícone de tamanho fixo ao lado de um título que cresce descola do texto e passa a ler como sujeira."
  - 💡 Explicação Leiga: A linha faz o ícone crescer junto com o título.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/map_controls.dart

- ⚙️ Função: Desenha os botões redondos que flutuam sobre o mapa.
- 💬 Comentários Removidos:

  > "Botão circular flutuante sobre o mapa (ampliar, reduzir, centralizar, travar rotação). Superfície do tema + borda de 1px + sombra nível 2: a borda é o que garante o recorte sobre um tile claro, e a sombra o que garante sobre um tile escuro — sozinhas, cada uma some numa das duas situações. Acessibilidade: 48×48 sempre, acima do mínimo de 44×44 recomendado pela Apple e do 48×48 do Material. Um dos dois botões de mapa que este widget substituiu media 40×40. [tooltip] é o rótulo do leitor de tela, então ele descreve a ação ('Ampliar o mapa'), não o desenho do ícone. Desabilitado é anunciado, não só apagado: com [onTap] nulo o `InkWell` marca o nó como botão desabilitado, e o leitor de tela avisa em vez de deixar a pessoa tocando num controle inerte. O ripple do `InkWell` é o feedback de pressão — e some se o dedo sair do alvo antes de soltar, tornando visível que o toque foi cancelado."
  - 💡 Explicação Leiga: Esta classe desenha os botões redondos do mapa. Eles têm borda e sombra para serem vistos sobre qualquer parte do mapa.

  > "Alvo de toque. Ver nota de acessibilidade na descrição da classe."
  - 💡 Explicação Leiga: A linha define 48 pontos como tamanho do botão.

  > "Descreve a ação; vira o rótulo do leitor de tela."
  - 💡 Explicação Leiga: A linha guarda o texto lido em voz alta pelo leitor de tela.

  > "`null` desabilita — o botão apaga e é anunciado como desabilitado."
  - 💡 Explicação Leiga: A linha desativa o botão quando nenhuma ação é informada.

  > "Estado ligado (ex: rotação travada): pinta com a cor de marca."
  - 💡 Explicação Leiga: A linha pinta o botão de vermelho quando ele está ativo.

  > "Ativo: a borda vira a própria cor de marca, e o vermelho passa a ocupar o círculo inteiro. Com `colors.border` fixo, o estado ligado ficava com um anel escuro em volta — no tema escuro lia como uma moldura preta cercando o botão, e não como um botão vermelho."
  - 💡 Explicação Leiga: A linha pinta também a borda de vermelho quando o botão está ativo.

  > "Sem sombra quando desabilitado: um botão inerte não deve continuar parecendo que flutua e convida ao toque."
  - 💡 Explicação Leiga: A linha remove a sombra do botão desativado.

  > "Par ampliar/reduzir do mapa. Existe porque o gesto de pinça é a única forma de mudar o zoom num mapa sem estes botões, e ele exige dois dedos e um movimento contínuo preciso — inviável com uma mão ocupada, com tremor ou mobilidade reduzida nas mãos, e inalcançável para quem navega por leitor de tela, que não emite gestos de múltiplos toques no canvas do mapa. Os botões se apagam ao encostar nos limites de [StoreMapController], que são os mesmos aplicados à pinça — assim os dois caminhos param no mesmo lugar e o botão nunca fica clicável sem fazer nada."
  - 💡 Explicação Leiga: Esta classe desenha os botões de mais e menos. Eles substituem o gesto de pinça, que exige dois dedos.

  > "Anunciado nos dois botões: sem enxergar o mapa, 'ampliei' não diz nada — 'nível 9 de 16' diz onde a pessoa está na escala."
  - 💡 Explicação Leiga: A linha faz o leitor de tela anunciar o nível de zoom atual.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/nearby_stores_section.dart

- ⚙️ Função: Mostra o mapa com as lojas próximas e acompanha a posição do usuário.
- 💬 Comentários Removidos:

  > "Mapa de lojas próximas em tela cheia, usado na aba 'Início' de guest, consumidor e comerciante. Mantém sua própria assinatura de GPS (só em primeiro plano) pra atualizar a posição do usuário conforme ele anda, recalculando quais lojas caem dentro do raio. O raio em si é controlado de fora (modal de filtros da home) — este widget só aplica o corte."
  - 💡 Explicação Leiga: Esta classe desenha o mapa e acompanha o usuário andando.

  > "Lojas já filtradas por categoria pelo widget pai — este widget só aplica o filtro de distância por cima."
  - 💡 Explicação Leiga: A linha recebe as lojas já filtradas por categoria.

  > "Raio em km escolhido no modal de filtros; null = 'Todos' (sem corte)."
  - 💡 Explicação Leiga: A linha guarda a distância máxima escolhida.

  > "Loja destacada no mapa (pin maior)."
  - 💡 Explicação Leiga: A linha guarda qual loja deve aparecer com o marcador maior.

  > "Avisa quem monta esta seção sobre o resultado do corte por raio e a posição do usuário — assim a tela dona do mapa reage a essas mudanças (ex: o botão de recentralizar da home) sem abrir uma segunda assinatura de GPS nem duplicar o cálculo de distância."
  - 💡 Explicação Leiga: A linha avisa a tela de cima sobre a posição e as lojas filtradas.

  > "No Flutter Web o prompt é nativo do navegador, fora do canvas do Flutter — sem timeout, um usuário que não percebe/ignora esse prompt trava este `await` pra sempre (e junto com ele, qualquer outro widget esperando o mesmo tipo de permissão, ex: SearchPage)."
  - 💡 Explicação Leiga: A linha define um tempo limite para o pedido de permissão de localização.

  > "O diálogo de permissão do SO pode levar segundos pra ser respondido — se o widget já foi descartado nesse meio-tempo, não assina o stream (senão a subscription nunca é cancelada e o GPS fica ligado à toa)."
  - 💡 Explicação Leiga: A linha cancela a ligação do GPS se a tela já foi fechada.

  > "Segue sem posição inicial — o mapa cai no fallback padrão."
  - 💡 Explicação Leiga: A linha segue sem posição quando o GPS falha.

  > "getCurrentPosition acima também pode ter levado um tempo — confere de novo antes de assinar o stream compartilhado."
  - 💡 Explicação Leiga: A linha verifica de novo se a tela ainda existe.

  > "Stream compartilhado com a ronda do comerciante — um único consumo de GPS mesmo com as duas telas vivas no IndexedStack."
  - 💡 Explicação Leiga: A linha usa a mesma ligação de GPS de outras telas.

  > "Sempre atualiza o marcador ao vivo — barato, não reconstrói a seção nem os marcadores de loja do StoreMapView."
  - 💡 Explicação Leiga: A linha move a bolinha azul sem redesenhar o mapa inteiro.

  > "Só reconstrói a lista de lojas/câmera se andou o suficiente pra fazer diferença no filtro de raio — evita rebuild em massa a cada tick de GPS."
  - 💡 Explicação Leiga: A linha só refaz o filtro quando o usuário andou o bastante.

  > "Sem GPS disponível — mapa mostra todas as lojas recebidas, sem filtro de raio."
  - 💡 Explicação Leiga: A linha mostra todas as lojas quando não há GPS.

  > "O corte em si mora em `data/nearby_filter.dart` — função pura, coberta por teste. Aqui fica só a ligação com o estado do widget (a posição do GPS e o raio vindo do modal de filtros)."
  - 💡 Explicação Leiga: A linha aplica o filtro de distância chamando a função de outro arquivo.

  > "Notifica fora do frame de build: chamar setState do pai durante o build do filho é erro de framework."
  - 💡 Explicação Leiga: A linha avisa a tela de cima depois de o desenho terminar.

  > "A bottom bar flutuante (glass) e a busca/filtro flutuantes ficam por cima do mapa aqui — sem esse respiro, os controles de câmera e o banner de 'sem lojas' ficariam embaixo deles."
  - 💡 Explicação Leiga: A linha reserva espaço para os botões não ficarem escondidos.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/perto_de_voce_carrossel_widget.dart

- ⚙️ Função: Desenha o carrossel horizontal com as lojas mais próximas.
- 💬 Comentários Removidos:

  > "Carrossel 'Perto de você' — lojas ordenadas por distância até o usuário."
  - 💡 Explicação Leiga: Esta classe desenha o carrossel de lojas próximas.

  > "Mesma seta da rota usada no mapa e no detalhe da loja: aqui ela diz 'isto é medido a partir de onde você está'."
  - 💡 Explicação Leiga: A linha usa o ícone de seta no título da seção.

  > "Carrossel horizontal: o card interno tem foto + texto, então a altura acompanha a escala. Com teto, porque um PageView que cresce sem limite empurra o resto da home para fora da primeira dobra."
  - 💡 Explicação Leiga: A linha define a altura do carrossel, com limite de crescimento.

  > "Card 'imersivo': a foto preenche o card inteiro, com nome/endereço e nota/categorias sobrepostos num gradiente escuro — sem CTA em pill (o card inteiro já é clicável, o botão 'Ver loja' quebrava a estética minimalista sem agregar nada que o tap no card não fizesse). Casca de foto+gradiente vem de `PhotoHeroCard` — este widget só monta o conteúdo (badges, texto) específico do card de destaque."
  - 💡 Explicação Leiga: Esta classe desenha o cartão com foto inteira. O cartão todo é clicável, sem botão separado.

  > "Bem mais aberto que o AppRadius.xl (24) padrão do resto do app — mesmo valor do card do 'Em Alta', de propósito, pra esses dois se destacarem como os cards 'hero' da home."
  - 💡 Explicação Leiga: A linha usa cantos mais arredondados neste cartão, para ele se destacar.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_card_badges.dart

- ⚙️ Função: Desenha as etiquetas pequenas de nota e categoria sobre os cartões de loja.
- 💬 Comentários Removidos:

  > "Pill branca flutuante com estrela + nota, para sobrepor no canto da foto do card (mesmo padrão do badge de rating dos cards de listagem do anexo de referência visual)."
  - 💡 Explicação Leiga: Esta classe desenha a etiqueta branca com a estrela e a nota.

  > "Chip cápsula cinza-claro para atributos secundários (categoria, etc.), mesmo tratamento visual dos chips de atributo ('3 quartos', '2 vagas') do anexo de referência."
  - 💡 Explicação Leiga: Esta classe desenha uma etiqueta cinza com informação secundária.

  > "Um tom abaixo do cardSurface do card que envolve este chip (ver mesmo raciocínio em image_picker_sheet.dart, Lote 2)."
  - 💡 Explicação Leiga: A linha usa um fundo mais escuro que o cartão em volta.

  > "Sem override de cor: legenda() já resolve pra secondaryText."
  - 💡 Explicação Leiga: A linha usa a cor padrão do estilo de legenda.

  > "Chip cápsula com contorno fino e texto preto em negrito — mesmo tratamento dos chips de atributo ('3 quartos', '2 vagas', '145 m²') do card de listagem do anexo de referência."
  - 💡 Explicação Leiga: Esta classe desenha uma etiqueta com contorno fino e texto em negrito.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/consumer_review_section.dart

- ⚙️ Função: Mostra as avaliações que o usuário já fez nesta loja e o formulário para avaliar.
- 💬 Comentários Removidos:

  > "O que o consumidor faz nesta loja: o que ele já avaliou e o formulário para avaliar de novo. Antes os dois viviam dentro do mesmo card, com o histórico empilhado acima do formulário e um divisor entre eles. Dois blocos de propósitos diferentes dividindo uma caixa só, com dois cabeçalhos de mesmo peso disputando espaço — e foi no cabeçalho do histórico, comprimido por dois paddings de cada lado, que a linha estourou. Agora são dois cards: o histórico (recolhível, e ausente para quem nunca avaliou) e o formulário. O estado continua num lugar só porque enviar uma avaliação recarrega o histórico logo em seguida."
  - 💡 Explicação Leiga: Esta classe mostra dois blocos separados: o histórico e o formulário de avaliação.

  > "'CONSUMIDOR' usa o formulário normalmente; 'GUEST' vê o mesmo bloco, mas inerte — o toque em qualquer parte dele abre a parede de login."
  - 💡 Explicação Leiga: A linha guarda o tipo de usuário. O visitante vê o formulário, mas não consegue usá-lo.

  > "Histórico de avaliações que o próprio consumidor já fez para esta loja. Múltiplas avaliações são permitidas (API geral não bloqueia duplicidade nem faz upsert) — cada envio soma uma nova linha ao histórico, em vez de sobrescrever a anterior."
  - 💡 Explicação Leiga: A linha guarda as avaliações já feitas. O usuário pode avaliar a mesma loja várias vezes.

  > "Visitante não tem token: GET /avaliacoes/minhas responderia 401, que além de inútil aqui passa pelo ErrorInterceptor. Nada de histórico pra buscar — sai direto do estado de carregamento."
  - 💡 Explicação Leiga: A linha pula a busca do histórico quando o usuário não está logado.

  > "Busca todas as avaliações do consumidor autenticado (GET /avaliacoes/minhas) e filtra pelo lojaId no client-side — não existe endpoint que devolva só as avaliações de uma loja específica."
  - 💡 Explicação Leiga: A função busca todas as avaliações do usuário e filtra as desta loja dentro do celular.

  > "Limpa o formulário: cada envio é uma nova avaliação no histórico, não uma edição da anterior."
  - 💡 Explicação Leiga: A linha limpa o formulário depois de enviar.

  > "Enquanto o histórico não responde, um bloco de aviso do tamanho de uma linha. Sem ele, quem já avaliou vê o formulário e, meio segundo depois, um card inteiro nascendo acima e empurrando a tela."
  - 💡 Explicação Leiga: A linha reserva espaço enquanto o histórico carrega, para a tela não pular.

  > "`compact`: sem avatar nem nome. Todas são desta mesma pessoa, e o cabeçalho logo acima já diz isso."
  - 💡 Explicação Leiga: A linha desenha as avaliações sem foto e sem nome, porque são todas do mesmo usuário.

  > "Formulário de avaliação. Para o visitante ele é exibido igual, mas dentro de um `AbsorbPointer`: as estrelas não marcam, o campo não recebe foco (nem abre teclado) e o botão não envia — o toque é capturado pelo `GestureDetector` de fora, que abre a parede de login. Mostrar o formulário desabilitado, e não escondê-lo, é o que faz o visitante descobrir que avaliar existe."
  - 💡 Explicação Leiga: A função desenha o formulário. Para visitantes ele fica inerte e o toque pede login.

  > "Seletor de nota. Cinco alvos de toque de 44dp com a estrela Phosphor — antes eram `IconButton`s com a estrela do Material, o único lugar da tela onde as duas famílias de ícone apareciam lado a lado."
  - 💡 Explicação Leiga: Esta classe desenha as cinco estrelas para escolher a nota.

  > "Trilho da nota, não uma estrela 'meio marcada': o amarelo cheio no estado vazio confundia os dois."
  - 💡 Explicação Leiga: A linha deixa as estrelas não escolhidas em cinza, e não em amarelo claro.

  > "Reserva a linha mesmo sem nota escolhida: sem isso o card inteiro pula de altura no primeiro toque em uma estrela."
  - 💡 Explicação Leiga: A linha reserva o espaço do texto da nota, para o cartão não pular.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/report_store_dialog.dart

- ⚙️ Função: Abre o formulário para denunciar uma loja.
- 💬 Comentários Removidos:

  > "Abre o formulário de denúncia de uma loja."
  - 💡 Explicação Leiga: A função mostra o formulário de denúncia.

  > "Guard de 'sair sem salvar': só considera alterado se o usuário fugiu do motivo padrão ou escreveu alguma descrição — evita perguntar confirmação pra quem só abriu o dialog e fechou sem preencher nada. ValueNotifier (não bool simples) pra não reconstruir o dialog inteiro a cada tecla — o rebuild fica isolado no ValueListenableBuilder do UnsavedChangesGuard."
  - 💡 Explicação Leiga: A linha só considera que há rascunho se o usuário mexeu em algo.

  > "O formulário sempre abre em branco: o backend (contrato legado) não tem checagem de duplicidade nem endpoint pra pré-carregar denúncia existente."
  - 💡 Explicação Leiga: A linha começa a escutar o campo de descrição. O formulário sempre abre vazio.

  > "POST /denuncias (contrato legado) não extrai o consumidor do JWT — precisa do id da sessão local no corpo da requisição."
  - 💡 Explicação Leiga: A linha lê o número do usuário da memória, porque o servidor exige que ele seja enviado.

  > "pop() direto (não maybePop): já foi salvo, então fecha sem passar pela confirmação de 'sair sem salvar' do PopScope abaixo."
  - 💡 Explicação Leiga: A linha fecha o formulário sem perguntar, porque a denúncia já foi enviada.

  > "Não fecha o dialog aqui — um erro de validação (ex: descrição muito longa) fechava o dialog e descartava o texto digitado sem explicar o motivo. Mantém o formulário aberto pro usuário corrigir e reenviar."
  - 💡 Explicação Leiga: A linha mostra o erro sem fechar o formulário, para o texto não ser perdido.

  > "Mesma superfície rebaixada do AppFormField logo abaixo: os dois são campos, e antes o seletor usava `surface` (a cor do próprio dialog) com uma borda vermelha que o fazia parecer um campo em estado de erro."
  - 💡 Explicação Leiga: A linha usa a mesma cor de fundo dos campos de digitar.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/review_card.dart

- ⚙️ Função: Desenha o cartão de uma avaliação, com autor, nota, comentário e data.
- 💬 Comentários Removidos:

  > "Uma avaliação, na lista pública da loja ou no histórico do próprio usuário. O mesmo card serve aos dois lugares, em larguras diferentes — e era daí que vinha o estouro de linha: dentro do card 'Suas avaliações anteriores' ele perde dois paddings de cada lado, e o par nome + data, que cabia na lista pública, não cabia mais. Duas correções, uma de layout e uma de conteúdo: o nome é `Expanded` com reticências, então nome longo encurta em vez de empurrar a data para fora; no histórico próprio ([compact]), autor e avatar saem. O nome ali é sempre o de quem está lendo, e a seção já diz isso no título — repetir consumia justamente a largura que faltava."
  - 💡 Explicação Leiga: Esta classe desenha o cartão de avaliação. No histórico próprio ela esconde o nome e a foto.

  > "Versão sem autor, para o histórico do próprio usuário."
  - 💡 Explicação Leiga: A linha liga o modo compacto, sem nome e sem foto.

  > "Dentro de uma seção que já rola, o card não precisa levantar do papel — a superfície rebaixada agrupa sem virar um objeto solto."
  - 💡 Explicação Leiga: A linha remove a sombra do cartão no modo compacto.

  > "Foto de quem avaliou, com a inicial do nome como fallback. A inicial deixou de ser o único estado possível: a foto do consumidor vem no mesmo JSON da avaliação (ver `ConsumidorResumido.imagemUrl`) e agora é desenhada quando existe. O fallback continua valendo para quem nunca enviou foto, para a foto que falhou em carregar e para o histórico próprio, onde o autor é sempre quem lê."
  - 💡 Explicação Leiga: Esta classe desenha a foto de quem avaliou, ou a inicial do nome.

  > "O nome do autor é lido pelo Text ao lado; anunciar a foto de novo repetiria a mesma informação no leitor de tela."
  - 💡 Explicação Leiga: A linha esconde a foto do leitor de tela, porque o nome já está escrito.

  > "brandContent e não brand puro: sobre o vermelho a 12% (que é quase a superfície do card) o vermelho cheio reprova em contraste no tema escuro."
  - 💡 Explicação Leiga: A linha usa o vermelho ajustado para texto na inicial do nome.

  > "Data relativa ('Ontem', 'Há 3 semanas'). Data absoluta numa avaliação diz pouco: o que interessa é se a experiência é recente."
  - 💡 Explicação Leiga: A função escreve há quanto tempo a avaliação foi feita.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/section_header.dart

- ⚙️ Função: Desenha o título de cada seção da tela de detalhe da loja.
- 💬 Comentários Removidos:

  > "Cabeçalho das seções da tela de detalhe da loja. Existe porque a tela tinha quatro cabeçalhos montados à mão, cada um com um nível tipográfico diferente (h1 para 'Avaliações', h2 para 'Sobre o local', h1 de novo dentro de um card) — e nenhum com o título em `Expanded`. Era dessa falta que vinha o estouro da linha: o título ocupava a largura que quisesse e empurrava o resto da linha para fora da tela. Aqui o título é sempre `Expanded` e sempre `h2`. Um cabeçalho de seção não pode competir com o nome da loja no topo da tela, que é o h1."
  - 💡 Explicação Leiga: Esta classe desenha o título das seções. Ele nunca empurra o resto da linha para fora da tela.

  > "Linha de apoio ('12 avaliações', 'Carregando...'). Fica sob o título."
  - 💡 Explicação Leiga: A linha guarda o texto pequeno abaixo do título.

  > "Conteúdo à direita — um contador, um selo de nota. Recebe o espaço que sobra do título, nunca o contrário."
  - 💡 Explicação Leiga: A linha guarda o que aparece à direita do título.

  > "`null` deixa o cabeçalho estático. Preenchido, desenha o caret que gira e o cabeçalho inteiro vira o alvo de toque."
  - 💡 Explicação Leiga: A linha transforma o título em um botão de abrir e fechar a seção.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/store_detail_hero.dart

- ⚙️ Função: Desenha a foto de capa da loja como cabeçalho que encolhe ao rolar a tela.
- 💬 Comentários Removidos:

  > "Capa da loja como cabeçalho colapsável da tela de detalhe. Antes a tela tinha uma `SliverAppBar` vazia e, logo abaixo, um bloco de 260px com a capa. Rolar a página levava a foto embora e deixava no topo uma barra sem nada além de dois botões — em nenhum momento da rolagem dava para saber de qual comércio era aquela tela. Agora a foto é o próprio cabeçalho: expandida, carrega o nome e o endereço sobre um scrim; colapsada, entrega o nome à barra. A troca é comandada pela altura real do `flexibleSpace` (via [LayoutBuilder]), não por um `ScrollController` paralelo — o sliver já sabe o quanto encolheu."
  - 💡 Explicação Leiga: Esta classe desenha a foto no topo. Ao rolar, a foto encolhe e o nome da loja vai para a barra.

  > "Altura da capa aberta. 280 é o ponto em que a foto ainda é o assunto da tela e o conteúdo abaixo já se anuncia — acima disso, a primeira dobra vira só imagem."
  - 💡 Explicação Leiga: A linha define 280 pontos como altura da foto aberta.

  > "Largura com que a capa é decodificada. É um método estático, e não um número solto dentro de [_Capa], porque o precache disparado antes da navegação (ver `abrirDetalheDaLoja`) precisa usar exatamente este valor: a largura entra na chave do cache de imagem, e divergir aqui faria o pré-carregamento aquecer uma entrada que esta tela nunca leria — sem erro nenhum aparecendo, só a lentidão de volta."
  - 💡 Explicação Leiga: A função devolve a largura da foto. O mesmo valor é usado ao baixar a foto antecipadamente.

  > "A barra fixa não escurece ao ter conteúdo por baixo: ela já muda de estado ao colapsar (ganha o nome da loja), e o tint do Material 3 por cima disso lê como uma terceira cor de fundo aparecendo do nada."
  - 💡 Explicação Leiga: A linha desliga o escurecimento automático da barra ao rolar.

  > "A barra 'colapsada' é a altura da toolbar mais o recorte do sistema; a margem de 8 evita que o nome pisque no último pixel da animação."
  - 💡 Explicação Leiga: A linha calcula quando a barra está totalmente encolhida.

  > "O título não escala junto com a barra: ele só aparece quando ela já está colapsada, e crescer nesse instante pareceria um salto."
  - 💡 Explicação Leiga: A linha mantém o tamanho do título fixo durante a animação.

  > "Abre espaço para o botão de voltar e para o de favoritar — sem isso o nome nasce por baixo dos dois."
  - 💡 Explicação Leiga: A linha reserva espaço nas laterais para os botões.

  > "O bloco de texto sobre a foto some quando a barra colapsa — a partir daí quem carrega o nome é o título da própria barra."
  - 💡 Explicação Leiga: A linha esconde o texto sobre a foto quando a barra encolhe.

  > "Scrim só na metade de baixo, que é onde o texto cai. Um véu no quadro inteiro escureceria a foto sem necessidade — e a foto do comércio é o motivo de este cabeçalho existir."
  - 💡 Explicação Leiga: A linha escurece apenas a metade inferior da foto.

  > "Branco a 85%: um degrau abaixo do nome, sem cair no cinza (que sobre foto some)."
  - 💡 Explicação Leiga: A linha usa branco levemente transparente no endereço.

  > "Placeholder da loja sem capa. Gradiente da marca, e não a superfície cinza de antes: o texto do cabeçalho é branco: sobre cinza-claro ele sumiria, e o hero perderia justamente a função de dizer onde você está."
  - 💡 Explicação Leiga: Esta classe desenha um degradê vermelho quando a loja não tem foto.

  > "Botão circular sobre a capa. Superfície do tema (não vidro translúcido) de propósito: ele continua na tela depois que a barra colapsa, e um círculo translúcido sobre a superfície opaca da barra desapareceria."
  - 💡 Explicação Leiga: Esta classe desenha os botões redondos sobre a foto, com fundo sólido.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/store_detail_overview.dart

- ⚙️ Função: Desenha as ações e o resumo numérico da loja na tela de detalhe.
- 💬 Comentários Removidos:

  > "Ações da loja: ver no mapa e denunciar. As duas eram tratadas como coisas de naturezas diferentes — 'Visualizar no mapa' era um `FloatingActionButton` fixo no rodapé, cobrindo o conteúdo durante toda a rolagem, e 'Denunciar' era um pill vermelho colado ao lado do nome da loja, disputando atenção com o título. Aqui elas viram o que são: duas ações, numa linha, com pesos diferentes."
  - 💡 Explicação Leiga: Esta classe desenha os botões de ver no mapa e denunciar, lado a lado.

  > "'CONSUMIDOR', 'GUEST', 'COMERCIANTE' ou 'ADMINISTRADOR' — só os dois primeiros veem 'Denunciar' (o visitante cai na parede de login ao tocar, mas vê que a ação existe)."
  - 💡 Explicação Leiga: A linha guarda o tipo de usuário. O botão de denunciar só aparece para clientes e visitantes.

  > "Sem coordenadas não há o que mostrar: o mapa abria vazio e a rota nem chegava a ser calculada. Desabilitado, o botão ainda comunica que a função existe."
  - 💡 Explicação Leiga: A linha desativa o botão do mapa quando a loja não tem posição.

  > "Resumo numérico da loja: nota, avaliações, fotos. Eram quatro colunas, e a quarta era 'No mapa: Sim/Não' — um dado que não é métrica e que agora vive onde importa, no estado do botão 'Ver no mapa'. Quatro colunas dividindo 360dp era também o aperto que fazia os rótulos competirem por espaço assim que a fonte do sistema crescia."
  - 💡 Explicação Leiga: Esta classe desenha três números: nota, quantidade de avaliações e de fotos.

  > "Nota média mais fresca (vem do resumo do backend), com fallback para a que veio junto da loja."
  - 💡 Explicação Leiga: A linha guarda a nota média mais atualizada.

  > "Total de avaliações mais fresco, pelo mesmo motivo de [media]. Ler `store.totalAvaliacoes` direto daqui era o bug: quem chega ao detalhe por `GET /lojas/{id}` (entidade pura, sem agregação) via '0 Avaliações' neste resumo enquanto a seção logo abaixo listava várias."
  - 💡 Explicação Leiga: A linha guarda o total de avaliações mais atualizado.

  > "O divisor acompanha a altura do conteúdo ao lado; parado em 32 ele viraria um risco curto no meio de uma coluna alta."
  - 💡 Explicação Leiga: A linha faz a linha divisória crescer junto com o conteúdo.

  > "Categorias da loja, cada uma com a cor e o ícone que o app já usa para ela nos filtros e nos cards de lista — antes eram chips só de texto, sem relação visual nenhuma com a mesma categoria vista na busca."
  - 💡 Explicação Leiga: Esta classe desenha as categorias da loja com a mesma cor e ícone usados na busca.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/store_gallery_strip.dart

- ⚙️ Função: Desenha a fileira horizontal com as fotos da loja.
- 💬 Comentários Removidos:

  > "Tira horizontal com as fotos da loja. A página desenhava isto inline mesmo quando não havia foto nenhuma: o cabeçalho anunciava '0 fotos' e, abaixo, 140px de nada. Aqui, galeria vazia simplesmente não é uma seção."
  - 💡 Explicação Leiga: Esta classe desenha a fileira de fotos. Sem fotos, a seção não aparece.

  > "Lado do tile. Quadrado de 140 é o tamanho em que três fotos se anunciam na largura de um celular, com a terceira cortada — o corte é o que convida a arrastar."
  - 💡 Explicação Leiga: A linha define 140 pontos para cada foto. A terceira aparece cortada, convidando a arrastar.

  > "Resolvida uma vez: é a lista que o visualizador em tela cheia recebe, e o índice do tile tocado precisa apontar para a posição certa dentro dela (URLs inválidas mudam a numeração)."
  - 💡 Explicação Leiga: A linha monta a lista de fotos válidas uma vez só, para a numeração ficar correta.

  > "O tile tem 140dp — sem `displayWidth`, cada foto seria decodificada no tamanho original."
  - 💡 Explicação Leiga: A linha reduz cada foto para o tamanho em que ela aparece.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_detail/store_reviews_section.dart

- ⚙️ Função: Desenha a lista pública de avaliações da loja, com filtro por nota.
- 💬 Comentários Removidos:

  > "As avaliações públicas da loja: cabeçalho, filtro por nota e a lista. O estado de 'recolhida' e o filtro por estrelas moravam na página, junto com o carregamento da capa, da galeria e do resumo da loja. Trazidos para cá, tocar num chip de filtro deixa de reconstruir a tela inteira — e a página volta a ser só composição."
  - 💡 Explicação Leiga: Esta classe desenha as avaliações públicas. Filtrar por nota não redesenha a tela inteira.

  > "Quantas avaliações a loja tem, segundo o dado que a página já tinha em mãos antes de a lista chegar. O cabeçalho dizia 'Carregando...' durante a busca — uma informação que o app já possuía desde a listagem. Mostrar '12 avaliações' de cara, e só então preencher a lista, é a diferença entre uma tela que está trabalhando e uma que parece vazia."
  - 💡 Explicação Leiga: A linha guarda o total já conhecido, para mostrar o número antes de a lista chegar.

  > "Teto de escala da faixa de filtros. Tira horizontal dentro da lista de avaliações: crescer sem limite empurraria as próprias avaliações para fora da tela, que é o conteúdo que o filtro existe para organizar."
  - 💡 Explicação Leiga: A linha limita o crescimento da faixa de filtros.

  > "`null` significa 'todas'. A API sempre devolve a lista completa; o filtro é só client-side."
  - 💡 Explicação Leiga: A linha guarda o filtro de nota. O filtro é aplicado dentro do celular.

  > "Durante a carga vale o total que a página já conhecia; depois, a lista."
  - 💡 Explicação Leiga: A linha escolhe qual total mostrar conforme a lista já ter chegado ou não.

  > "'Carregando...' só quando de fato não se sabe o número — nas telas que chegam aqui sem a agregação do backend."
  - 💡 Explicação Leiga: A linha só escreve "Carregando" quando o número é realmente desconhecido.

  > "O teto entra nos dois lugares de propósito: na altura da faixa e na escala do texto dentro dela. Limitar só um dos dois é o que produz ou texto cortado (faixa parada, texto crescendo) ou faixa com sobra."
  - 💡 Explicação Leiga: A linha limita a altura e o texto ao mesmo tempo.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_form_fields.dart

- ⚙️ Função: Reúne os campos de nome, descrição e endereço usados no cadastro e na edição da loja.
- 💬 Comentários Removidos:

  > "Os campos de loja que o cadastro e a edição preenchem — os mesmos dos dois lados, agora escritos uma vez só. Nasceu do mesmo problema que originou o `CategoryPicker`: cadastro e edição mantinham cópias dos mesmos blocos, e cada ajuste feito de um lado deixava o outro para trás (rótulos, ícones e validação já haviam divergido)."
  - 💡 Explicação Leiga: Este arquivo reúne os campos usados nas duas telas de loja.

  > "Nome e descrição — o que aparece no card da loja para o cliente."
  - 💡 Explicação Leiga: Esta classe desenha os campos de nome e descrição.

  > "No cadastro a descrição é obrigatória (é a primeira impressão da loja); na edição, não — quem já tem loja publicada não pode ser impedido de salvar por um campo que estava vazio desde antes."
  - 💡 Explicação Leiga: A linha define se a descrição é obrigatória. Ela só é exigida no cadastro.

  > "CEP, rua, cidade e UF — com o autofill do ViaCEP embutido. O autofill mora aqui dentro, e não em cada tela: ele é comportamento deste bloco de campos, não da página que o hospeda. Antes eram duas cópias da mesma rotina (`_onCepChanged`), cada uma com seu `bool _buscandoCep` no estado da tela, só para acender o mesmo spinner no mesmo campo."
  - 💡 Explicação Leiga: Esta classe desenha os campos de endereço e preenche sozinha pelo CEP.

  > "Valida o formato do CEP quando preenchido. O campo continua opcional nos dois fluxos — muitos comércios daqui são ambulantes, sem endereço fixo."
  - 💡 Explicação Leiga: A linha liga a validação do formato do CEP. O campo continua opcional.

  > "Avisa a tela que algum campo mudou por autofill. Digitação já é ouvida pelos próprios controllers; o preenchimento automático não passa por eles como entrada do usuário, então quem controla 'tem alterações não salvas' precisa deste aviso."
  - 💡 Explicação Leiga: A linha avisa a tela quando o endereço é preenchido automaticamente.

  > "Ao completar 8 dígitos, busca no ViaCEP e preenche rua/cidade/UF (tudo continua editável depois). Falha é silenciosa: quem digitou o CEP segue preenchendo à mão, sem um erro que não tem o que resolver."
  - 💡 Explicação Leiga: A função busca o endereço ao completar os oito dígitos do CEP.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_gallery_viewer.dart

- ⚙️ Função: Mostra as fotos da loja em tela cheia, com deslize entre elas.
- 💬 Comentários Removidos:

  > "Visualização fullscreen da galeria de fotos de uma loja — swipe lateral entre todas as fotos (a partir da foto tocada na lista horizontal) e avanço automático a cada alguns segundos, reiniciado a cada troca de página (manual ou automática) para não brigar com o gesto do usuário."
  - 💡 Explicação Leiga: Esta classe mostra as fotos em tela cheia. Elas trocam sozinhas e também pelo dedo.

  > "Sem `displayWidth`: esta tela dá zoom de até 4x na foto, e decodificá-la na largura da tela devolveria um borrão ao primeiro pinçar."
  - 💡 Explicação Leiga: A linha carrega a foto no tamanho original, porque esta tela permite ampliar.

  > "A foto é o próprio conteúdo desta tela — sem texto ao redor que sirva de rótulo implícito."
  - 💡 Explicação Leiga: A linha dá uma descrição falada para cada foto, como "Foto 1 de 5".

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_list_widgets.dart

- ⚙️ Função: Desenha a lista vertical de lojas com miniatura, nome e nota.
- 💬 Comentários Removidos:

  > "Lista 'corrida', sem card individual — itens separados por um divisor fino em vez de cada um virar sua própria caixa com sombra (inspirado num layout de lista de reserva/hospedagem: miniatura + coração sobreposto, título, linha de detalhe, pill + nota na base)."
  - 💡 Explicação Leiga: A linha desenha uma lista contínua, separada por linhas finas em vez de cartões.

  > "Um tom abaixo do mainBackground da página, senão o placeholder fica invisível antes da imagem carregar."
  - 💡 Explicação Leiga: A linha usa um fundo mais escuro atrás da miniatura que ainda está carregando.

  > "Sem `semanticLabel`: decorativa, o nome da loja já aparece como texto no card."
  - 💡 Explicação Leiga: A linha deixa a miniatura sem descrição falada.

  > "O selo redondo com a cor da categoria saiu daqui. Ele transbordava a miniatura (bottom/right negativos), colidia com o divisor da lista e repetia uma informação que a pessoa já escolheu no filtro logo acima — dentro de 'Espetinhos', um ícone de espetinho em cada item não informa nada."
  - 💡 Explicação Leiga: A etiqueta de categoria foi removida dos itens da lista, porque repetia o filtro já escolhido.

  > "O nome é o que identifica o item da lista: em escala alta, uma linha só o reduziria a 'Padaria do Se…'. O card não tem altura fixa, então a segunda linha cabe sem quebrar nada."
  - 💡 Explicação Leiga: A linha permite que o nome da loja use duas linhas.

  > "Com o endereço em duas linhas, `center` (o padrão) descolaria o pin do começo do texto."
  - 💡 Explicação Leiga: A linha alinha o ícone de local no topo do endereço.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_map_view.dart

- ⚙️ Função: Desenha o mapa com os marcadores das lojas e a posição do usuário.
- 💬 Comentários Removidos:

  > "Mapa com pins das lojas, reaproveitado na home (guest/consumer) e no botão 'Visualizar no mapa' da tela de detalhe de uma loja. Lojas sem latitude/longitude (cadastradas antes dessa feature existir, ou com endereço que o geocoding não conseguiu resolver) são ignoradas. A câmera segue o centro rastreado (loja em foco ou posição do usuário): quando ele muda entre rebuilds — ex: novo fix de GPS da NearbyStoresSection ou da ronda do comerciante — o mapa recentraliza preservando o zoom que o usuário ajustou manualmente. `MapOptions.initialCenter` sozinho não faz isso, pois o flutter_map só o lê no primeiro build."
  - 💡 Explicação Leiga: Esta classe desenha o mapa com os marcadores. Lojas sem posição não aparecem.

  > "Posição 'ao vivo' do usuário — desenha o marker 'minha posição' (bolinha azul) num MarkerLayer isolado via ValueListenableBuilder. Propositalmente um ValueListenable em vez de double/double: assim, quem alimenta isso a cada tick de GPS (ex: NearbyStoresSection) atualiza só esse marcador, sem reconstruir StoreMapView inteiro nem os marcadores das lojas."
  - 💡 Explicação Leiga: A linha recebe a posição do usuário. Apenas a bolinha azul é redesenhada quando ela muda.

  > "Traçado de rota (ex: usuário → loja no 'Visualizar no mapa'), desenhado sob os markers."
  - 💡 Explicação Leiga: A linha recebe os pontos que formam o caminho desenhado.

  > "Espaço reservado abaixo dos botões flutuantes de câmera (centralizar / travar rotação), pra não ficarem escondidos atrás de bottom bars ou pills que ficam por cima do mapa em algumas telas."
  - 💡 Explicação Leiga: A linha reserva espaço embaixo dos botões do mapa.

  > "Distância do topo pro banner de 'sem lojas com localização' — precisa crescer quando há uma busca/filtro flutuante por cima do mapa, senão o banner nasce embaixo desses controles."
  - 💡 Explicação Leiga: A linha define a distância do aviso até o topo da tela.

  > "Comando externo da câmera (ver [StoreMapController]). A home usa para focar um pin acima do sheet e para o botão de recentralizar, que lá vive fora do mapa."
  - 💡 Explicação Leiga: A linha recebe o controlador que comanda a câmera de fora.

  > "Toque num pin. `null` mantém o comportamento padrão — abrir a tela da loja —, que é o certo nas telas onde o mapa é a única coisa na tela."
  - 💡 Explicação Leiga: A linha define o que acontece ao tocar em um marcador.

  > "Desliga os botões de câmera internos. A home desenha os seus, ancorados acima da bottom bar flutuante do app."
  - 💡 Explicação Leiga: A linha permite desligar os botões internos do mapa.

  > "Banner de 'nenhuma loja com localização por aqui'. Desligado na home, onde ele colidia com a barra de busca flutuante."
  - 💡 Explicação Leiga: A linha permite desligar o aviso de "sem lojas".

  > "Fallback quando não há localização do usuário nem lojas com pin — evita renderizar o mapa centralizado em (0,0), no meio do oceano."
  - 💡 Explicação Leiga: A linha define uma posição inicial do Rio de Janeiro quando não há nenhuma referência.

  > "Só recentraliza se o centro rastreado andou mais que isso — evita micro-movimentos de ruído de GPS mexendo na câmera o tempo todo."
  - 💡 Explicação Leiga: A linha só move o mapa quando a posição mudou mais de dez metros.

  > "Controller da tela quando ela fornece um; senão, um próprio. Ter sempre um evita duplicar aqui dentro o estado de zoom/rotação que ele já guarda — os controles de zoom precisam desse estado tanto na home (onde vivem fora do mapa) quanto nas telas que usam os botões internos."
  - 💡 Explicação Leiga: A linha usa o controlador recebido, ou cria um próprio.

  > "`true` quando o controller nasceu aqui — só nesse caso ele é descartado aqui; o da tela pertence a quem o criou."
  - 💡 Explicação Leiga: A linha marca se o controlador foi criado aqui, para saber quem deve descartá-lo.

  > "Centro que o mapa deve seguir, na mesma ordem de prioridade usada pra escolher o centro inicial. Null quando não há nada a seguir (câmera fica livre pro usuário)."
  - 💡 Explicação Leiga: A linha calcula qual ponto o mapa deve acompanhar.

  > "Com controller externo, quem enquadra o foco é a tela — ela precisa deslocar o alvo para cima do sheet, e centralizar aqui desfaria isso."
  - 💡 Explicação Leiga: A linha deixa a tela comandar o enquadramento quando ela tem um controlador próprio.

  > "Com controller externo, quem alterna a trava é o botão da tela (fora do mapa) — este listener traz a decisão de volta para cá, que é onde as `interactionOptions` do FlutterMap são montadas."
  - 💡 Explicação Leiga: A linha escuta a trava de rotação comandada de fora.

  > "Quando uma rota chega (ex: usuário → loja no 'Visualizar no mapa'), enquadra o traçado inteiro — mostrar só a loja cortaria o caminho."
  - 💡 Explicação Leiga: A linha ajusta o mapa para mostrar o caminho inteiro.

  > "Move só o centro, preservando o zoom atual escolhido pelo usuário."
  - 💡 Explicação Leiga: A linha move o mapa sem mudar o zoom.

  > "Centraliza a câmera na posição atual do usuário (estilo Uber), mantendo o zoom atual — ou um zoom mínimo de 'rua' se o usuário estiver com o mapa muito distante."
  - 💡 Explicação Leiga: A função centraliza o mapa na posição do usuário.

  > "Alterna o travamento de rotação do mapa. Delega ao controller (que alinha de volta pro norte ao travar) e deixa o `_onRotacaoExternaMudou` devolver o novo valor — assim o botão interno e o da tela nunca ficam contando histórias diferentes sobre o mesmo mapa."
  - 💡 Explicação Leiga: A função trava ou destrava a rotação do mapa.

  > "Pin de loja: círculo com borda branca contendo a foto do comércio — cai pro ícone padrão (fundo vermelho) se não houver foto ou a imagem falhar ao carregar. A loja em foco fica maior e com borda mais grossa."
  - 💡 Explicação Leiga: A função desenha o marcador da loja com a foto dela dentro de um círculo.

  > "Decorativa (sem `semanticLabel`): o marcador em si — fora do escopo deste widget — já leva o nome da loja pra tela de detalhe ao ser tocado. `displayWidth` é indispensável aqui: o marcador é um círculo de 42-52dp, e sem ele cada pin decodificaria a foto inteira da loja, pesando no pan/zoom com vários marcadores na tela."
  - 💡 Explicação Leiga: A linha reduz a foto ao tamanho do marcador. Sem isso o mapa ficaria lento.

  > "Marker 'minha posição': bolinha azul com borda branca, padrão de mapas."
  - 💡 Explicação Leiga: A função desenha a bolinha azul da posição do usuário.

  > "Token da paleta, não um azul cravado: `MfColor.userDot` existe exatamente para este ponto e estava sendo ignorado aqui."
  - 💡 Explicação Leiga: A linha usa a cor azul definida no tema, e não um azul escrito à mão.

  > "Zoom no topo da pilha: é o controle usado com mais frequência, e aqui fica o mais longe da borda inferior, onde o polegar alcança com menos esforço em telas grandes."
  - 💡 Explicação Leiga: A linha coloca os botões de zoom no topo da pilha de controles.

  > "Botão 'Centralizar' só existe se há um ValueListenable de posição — reconstrói só este pedaço pequeno (não o mapa inteiro) quando a posição chega pela primeira vez ou muda."
  - 💡 Explicação Leiga: A linha desenha o botão de centralizar apenas quando há posição do usuário.

  > "Mesmos limites dos botões de ampliar/reduzir: pinça e botão param no mesmo lugar."
  - 💡 Explicação Leiga: A linha aplica ao gesto de pinça os mesmos limites dos botões.

  > "Realimenta o zoom do controller a cada movimento. Só atualiza um ValueNotifier — os botões de zoom reconstroem sozinhos, o mapa não é reconstruído junto."
  - 💡 Explicação Leiga: A linha informa o zoom atual ao controlador a cada movimento.

  > "Cartografia por tema (clara/escura) — ver MapTiles. Este é o único TileLayer do app, então a home, o mapa da loja e o da rota acompanham o tema pelo mesmo lugar."
  - 💡 Explicação Leiga: A linha desenha as imagens do mapa. Este é o único ponto do app que faz isso.

  > "Marcadores de loja num MarkerLayer próprio — só reconstrói quando `stores`/`focusedStore` mudam (ou seja, quando StoreMapView.build() roda de novo), não a cada tick de GPS."
  - 💡 Explicação Leiga: A linha desenha os marcadores das lojas em uma camada separada.

  > "SemanticTapArea, e não GestureDetector cru: sem o nó de semântica os pins são o único conteúdo do mapa e ficavam invisíveis ao leitor de tela — quem não enxerga não tinha como saber que havia comércios ali, nem como abri-los."
  - 💡 Explicação Leiga: A linha torna cada marcador acessível ao leitor de tela.

  > "O pin já cresce quando está em foco e é pequeno demais para comportar escala de pressão sem tremer."
  - 💡 Explicação Leiga: A linha desliga o efeito de encolher ao tocar no marcador.

  > "Marcador 'minha posição' isolado num MarkerLayer próprio, dentro de um ValueListenableBuilder: cada tick de GPS reconstrói só esta bolinha azul, sem tocar no MarkerLayer das lojas acima nem em StoreMapView.build() como um todo."
  - 💡 Explicação Leiga: A linha desenha a bolinha azul em uma camada isolada.

  > "Elemento flutuante sobre o mapa — cardSurface (Lote 4B)."
  - 💡 Explicação Leiga: A linha usa a cor de cartão no aviso que flutua sobre o mapa.

  > "Sem override de cor: legenda() já resolve pra secondaryText."
  - 💡 Explicação Leiga: A linha usa a cor padrão do estilo de legenda.

  > "O botão flutuante dos controles de câmera virou `MapControlButton`, em `map_controls.dart` — a home desenhava um clone dele, e as duas cópias já tinham divergido em tamanho de alvo (40 aqui, 48 lá) e em superfície."
  - 💡 Explicação Leiga: Anota que o botão do mapa foi movido para outro arquivo, eliminando uma cópia.

### 📂 ARQUIVO: lib/features/store/presentation/widgets/store_photos_editor.dart

- ⚙️ Função: Permite escolher, ver e remover a foto de capa e as fotos da galeria da loja.
- 💬 Comentários Removidos:

  > "Capa + galeria da loja, em um único bloco, usado tanto no cadastro quanto na edição. As duas telas mantinham cópias do mesmo editor com valores diferentes (capa de 160 contra 180 de altura, tile de 100 contra 110, raio `md` contra `lg`, um com sombra e outro não) — vistas em sequência, davam a impressão de duas telas de produtos diferentes. Distinção que a API preserva de propósito: foto salva no servidor (`String` de URL) e foto escolhida agora (`XFile`) apagam de formas diferentes — a primeira faz DELETE e precisa de confirmação, a segunda é só descartar da lista local. Uma lista só de 'fotos' esconderia isso e levaria a chamar DELETE em arquivo que nunca subiu."
  - 💡 Explicação Leiga: Esta classe desenha o editor de fotos da loja. Fotos já salvas e fotos novas são apagadas de formas diferentes.

  > "Fora de edição, os controles de escolher/remover não aparecem."
  - 💡 Explicação Leiga: A linha esconde os botões quando a tela é só para leitura.

  > "Caminho da capa já salva (relativo, resolvido por `resolveImagemUrl`)."
  - 💡 Explicação Leiga: A linha guarda o endereço da capa já salva no servidor.

  > "Capa escolhida nesta sessão e ainda não enviada. Tem precedência sobre [capaUrl] na exibição — é o que a pessoa acabou de escolher."
  - 💡 Explicação Leiga: A linha guarda a capa recém-escolhida, que aparece no lugar da antiga.

  > "Mostra o selo 'Obrigatório' ao lado do título (fluxo de cadastro)."
  - 💡 Explicação Leiga: A linha mostra um selo indicando que a foto é obrigatória.

  > "URL da foto de galeria com DELETE em andamento — mostra spinner no lugar do X daquele tile."
  - 💡 Explicação Leiga: A linha marca qual foto está sendo apagada, para mostrar o carregamento nela.

  > "Tabular: o contador não empurra o layout ao passar de 9 para 10 fotos."
  - 💡 Explicação Leiga: A linha usa números de largura fixa no contador de fotos.

  > "Decorativa (sem `semanticLabel`): o título 'Foto de destaque' já dá o contexto."
  - 💡 Explicação Leiga: A linha deixa a prévia da capa sem descrição falada.

  > "Ainda não subiu: descartar é local e instantâneo, não há estado de 'removendo'."
  - 💡 Explicação Leiga: A linha apaga a foto na hora, porque ela ainda não foi enviada ao servidor.

---

## 🧪 PARTE 20 — OS TESTES AUTOMÁTICOS

Os arquivos abaixo não fazem parte do aplicativo que o usuário instala.
Eles conferem sozinhos se o código continua funcionando depois de cada mudança.

### 📂 ARQUIVO: test/core/network/error_interceptor_test.dart

- ⚙️ Função: Confere se os erros do servidor viram mensagens corretas em português.
- 💬 Comentários Removidos:

  > "Roda o interceptor isoladamente e devolve a AppException resultante."
  - 💡 Explicação Leiga: A função executa só o tradutor de erros e devolve o resultado.

  > "Era exatamente isto que o usuário via na tela: '2026-08-24T14:32:11.482+00:00'"
  - 💡 Explicação Leiga: O teste confere que a data e hora não aparecem mais como mensagem de erro.

### 📂 ARQUIVO: test/core/network/json_reader_test.dart

- ⚙️ Função: Confere se os dados fora do formato viram um erro claro em vez de derrubar a tela.
- 💬 Comentários Removidos:

  > "Toda desserialização do app passa por aqui. O que estes casos garantem é que uma quebra de contrato da API vira `ParseException` legível — e não o `TypeError` cru que atravessava todo o tratamento de erro das telas."
  - 💡 Explicação Leiga: Os testes garantem que dados errados do servidor produzem um erro que o app sabe mostrar.

### 📂 ARQUIVO: test/core/session/session_store_test.dart

- ⚙️ Função: Confere se a sessão do usuário é salva, lida e apagada corretamente.
- 💬 Comentários Removidos:

  > "Cada caso começa do zero — o store é um singleton de processo."
  - 💡 Explicação Leiga: A linha apaga a sessão antes de cada teste, para um não afetar o outro.

  > "Simula um boot novo: memória vazia, disco populado."
  - 💡 Explicação Leiga: A linha simula o aplicativo sendo aberto de novo, com dados no disco.

  > "E o disco acompanhou — era exatamente isso que faltava quando o card de Perfil seguia mostrando o nome antigo depois de editar."
  - 💡 Explicação Leiga: O teste confere que o nome novo foi gravado também no disco.

### 📂 ARQUIVO: test/dynamic_type_test.dart

- ⚙️ Função: Confere se as telas continuam legíveis quando o usuário aumenta a letra do celular.
- 💬 Comentários Removidos:

  > "Rede de segurança do Dynamic Type. Um `RenderFlex overflowed` não derruba o app: em produção ele vira uma faixa listrada (ou nada, em release) e o texto simplesmente some. Ou seja, é o tipo de defeito que passa despercebido em revisão e só aparece no aparelho de alguém que aumentou a fonte — normalmente a pessoa que mais precisava do app funcionando. Duas ferramentas, porque uma não basta. Foi medido, e o resultado decidiu o desenho deste arquivo: um `Row` estourando na horizontal é detectado por `takeException()`; uma `Column` estourando na vertical também; mas texto cortado por `SizedBox(height:` fixo não é detectado. A terceira linha é justamente a amarra que este lote está removendo: ela não lança nada, o texto só é clipado em silêncio. Confiar apenas na exceção daria um teste verde enquanto o rótulo do botão continuasse cortado pela metade. Por isso cada componente tem os dois tipos de asserção: 1. `takeException()` — pega o overflow de `Row`/`Column`; 2. altura em 1× menor que altura em 2× — pega a amarra silenciosa. Se alguém reintroduzir `height:` fixo, esta é a asserção que quebra. Como estender: ao migrar uma tela, acrescente um caso aqui — e inclua a comparação de altura, não só a checagem de exceção."
  - 💡 Explicação Leiga: Este arquivo confere duas coisas em cada componente: se ele não estoura a tela e se ele cresce junto com a letra.

  > "Monta [child] com o tema real do app e a escala de texto pedida. Largura estreita de propósito (360dp, um celular pequeno): o overflow horizontal aparece primeiro em tela estreita, e é justamente a combinação 'tela pequena + fonte grande' que quebra na vida real. [rolavel] reproduz o ambiente real destes componentes: todos vivem dentro de uma lista ou de um `SingleChildScrollView`. Isso importa por dois motivos — dá ao filho altura irrestrita, que é o que permite medir o tamanho natural dele (numa tela fixa ele é esticado e toda medida vira a altura da tela), e evita acusar de 'overflow' um bloco que na tela real simplesmente rolaria."
  - 💡 Explicação Leiga: A função monta o componente em uma tela pequena, para simular o pior caso.

  > "2.0 é o teto do Android; o iOS vai além com as 'Larger Accessibility Sizes', por isso o 3.0 entra na checagem de crescimento."
  - 💡 Explicação Leiga: A linha testa a letra em tamanho normal, uma vez e meia e duas vezes maior.

  > "Mede a altura de [finder] com [child] montado na escala [escala]."
  - 💡 Explicação Leiga: A função mede a altura do componente em cada tamanho de letra.

  > "O portão contra a amarra silenciosa: um componente que contém texto precisa ficar mais alto quando a fonte do sistema cresce. Se não ficar, alguma altura fixa voltou a travar a caixa e o texto está sendo cortado sem lançar exceção nenhuma."
  - 💡 Explicação Leiga: A função confere se o componente ficou mais alto com a letra maior.

  > "O ponto do lote inteiro: com `height` fixo, as alturas seriam idênticas em toda escala e o rótulo estaria sendo cortado em silêncio."
  - 💡 Explicação Leiga: O teste confere que o botão cresce junto com a letra.

  > "Se o chip apertasse o conteúdo, o ícone seria a primeira coisa a sair — e com ele o único sinal não-cromático de seleção."
  - 💡 Explicação Leiga: O teste confere que o sinal de certo continua visível na etiqueta selecionada.

  > "tela de detalhe da loja — Estes três nasceram de um defeito real: os cabeçalhos e o card de avaliação da tela de detalhe estouravam a linha em escala 1x, num celular comum. A causa era sempre a mesma — um `Row` com o texto sem `Expanded`, ocupando a largura que quisesse e empurrando o resto para fora. A largura reduzida usada abaixo não é hipotética: é a que sobra dentro do card de avaliações, depois de dois paddings de cada lado."
  - 💡 Explicação Leiga: Este grupo de testes cobre um defeito real da tela de detalhe da loja.

  > "Largura útil dentro do card 'Suas avaliações', numa tela de 360dp: 360 − 2×20 (margem da tela) − 2×16 (padding do card)."
  - 💡 Explicação Leiga: A linha calcula a largura real disponível dentro do cartão, que é 288 pontos.

  > "O caret é o que sumia primeiro: sem ele, um bloco recolhível deixa de anunciar que dá para expandi-lo."
  - 💡 Explicação Leiga: O teste confere que a seta de expandir continua visível.

  > "Nome longo + data é exatamente o par que estourava na versão anterior."
  - 💡 Explicação Leiga: O teste usa um nome bem longo, que era o caso que quebrava antes.

  > "No histórico do próprio usuário o nome é sempre o dele, e repeti-lo consumia justamente a largura que faltava."
  - 💡 Explicação Leiga: O teste confere que o nome não aparece no histórico próprio.

  > "superfícies com teto — As faixas horizontais não crescem sem limite de propósito (ver `MaxTextScale`). O que precisa ser garantido aqui é o oposto dos grupos acima: que elas cresçam um pouco e depois PAREM. Sem esta asserção, alguém 'consertando' o teto deixaria a faixa comer a tela."
  - 💡 Explicação Leiga: Este grupo confere que as faixas horizontais param de crescer no limite definido.

  > "Sem 'Todos' na lista: o filtro que limpa o recorte deixou de ser um item da tira — ver `CategoryFiltersWidget`, onde 'ver tudo' é o estado sem nenhuma categoria marcada."
  - 💡 Explicação Leiga: A linha monta a faixa de categorias sem a opção "Todos".

### 📂 ARQUIVO: test/features/auth/auth_service_test.dart

- ⚙️ Função: Confere se o login funciona e se errar a senha não desconecta a conta atual.
- 💬 Comentários Removidos:

  > "Cenário: já logado como consumidor, tenta entrar noutra conta e erra a senha. Se o 401 fosse tratado como 'sessão expirada', o SessionManager limparia o AuthStorage e mandaria a pessoa para a tela de login."
  - 💡 Explicação Leiga: O teste simula alguém logado errando a senha de outra conta.

  > "Espera um tick para o caso de alguma limpeza assíncrona ter sido disparada por engano."
  - 💡 Explicação Leiga: A linha espera um instante para conferir que nada foi apagado por engano.

  > "Antes, `json['token'].toString()` gravava a string 'null' como token e o problema só aparecia na primeira requisição autenticada."
  - 💡 Explicação Leiga: O teste confere que um crachá ausente é detectado na hora do login.

### 📂 ARQUIVO: test/features/consumer/activity_summary_test.dart

- ⚙️ Função: Confere se o gráfico de atividade do cliente agrupa as datas corretamente.
- 💬 Comentários Removidos:

  > "`resumirAtividade` monta a série do gráfico do perfil do consumidor a partir das datas das avaliações. É a única lógica não-visual criada no redesign e a mais fácil de errar em silêncio: um off-by-one na janela desloca a curva inteira, e 'parece certo' numa conferência a olho. A função lê `DateTime.now()` internamente, então todos os casos montam as datas em relação a hoje. As datas usam meio-dia de propósito: somar ou subtrair dias a partir de 12:00 cai sempre no dia de calendário pretendido, mesmo que o fuso mude em uma hora no meio do intervalo."
  - 💡 Explicação Leiga: Estes testes conferem o agrupamento das datas do gráfico. Eles usam meio-dia para evitar erro de fuso horário.

  > "Dia 15 pra não esbarrar em mês curto (31 de março menos um mês não existe em fevereiro e o DateTime 'transborda' pra março de novo)."
  - 💡 Explicação Leiga: A linha usa o dia 15 para evitar problemas com meses de tamanhos diferentes.

  > "A janela vai de hoje-6 até hoje, então três dias atrás é o índice 3."
  - 💡 Explicação Leiga: O teste confere em qual posição do gráfico uma data de três dias atrás cai.

  > "Cai no período de comparação, então vira base do delta em vez de simplesmente sumir."
  - 💡 Explicação Leiga: O teste confere que uma data antiga vira base de comparação.

  > "A janela vai de hoje-29 até hoje; os dias 29..25 atrás formam o primeiro balde."
  - 💡 Explicação Leiga: O teste confere o agrupamento por semana no período de 30 dias.

  > "Sem base de comparação não existe percentual — mostrar '+100%' sobre zero seria inventar leitura."
  - 💡 Explicação Leiga: O teste confere que não aparece porcentagem quando não há período anterior.

  > "1 contra 3 → -66,67% → -67%."
  - 💡 Explicação Leiga: O teste confere o cálculo e o arredondamento da porcentagem.

  > "20 dias atrás está fora tanto da semana atual (0-6) quanto da anterior (7-13), então não vira base de comparação."
  - 💡 Explicação Leiga: O teste confere que datas muito antigas ficam fora da comparação.

### 📂 ARQUIVO: test/features/favorites/favorites_manager_test.dart

- ⚙️ Função: Confere se favoritar e desfavoritar funciona, inclusive quando o servidor falha.
- 💬 Comentários Removidos:

  > "O manager é singleton e resolveu o ApiClient na sua própria construção — sem trocar o service aqui, ele seguiria falando com o cliente real."
  - 💡 Explicação Leiga: A linha troca o mecanismo de rede por um falso.

  > "O manager se registra como `WidgetsBindingObserver` na construção (para reler os favoritos quando o app volta do segundo plano), e o singleton é construído na primeira referência a `.instance` — que acontece aqui dentro. Sem o binding, essa construção estoura. Mesmo motivo do `active_stores_manager_test`."
  - 💡 Explicação Leiga: A linha prepara o ambiente de teste do Flutter antes de criar o gerenciador.

  > "Já marcado antes de a chamada resolver."
  - 💡 Explicação Leiga: O teste confere que o coração muda na hora, antes da resposta do servidor.

  > "Não lança: quem chama normalmente não dá await (login, abertura de aba)."
  - 💡 Explicação Leiga: O teste confere que uma falha não derruba o aplicativo.

### 📂 ARQUIVO: test/features/merchant/store_status_card_test.dart

- ⚙️ Função: Confere se o cartão de status da loja mostra o estado correto.
- 💬 Comentários Removidos:

  > "O card é o controle mais crítico do app para o comerciante: se ele mostrar o estado errado, a pessoa acha que está aberta quando não está — e fica esperando cliente que não vai aparecer. Nota sobre `pump` x `pumpAndSettle`: o selo 'AO VIVO' pulsa em laço infinito, então `pumpAndSettle` nunca retornaria. Todos os testes daqui usam `pump()` de propósito."
  - 💡 Explicação Leiga: Estes testes conferem o cartão de status. Eles não esperam a animação terminar, porque ela nunca para.

  > "'±0 m' leria como GPS perfeito, que é o oposto de 'não sei ainda'."
  - 💡 Explicação Leiga: O teste confere que a precisão desconhecida não aparece como zero metros.

  > "O rótulo some enquanto carrega (o AppButton troca por spinner), então o toque vai no próprio botão."
  - 💡 Explicação Leiga: A linha toca no botão pelo tipo dele, porque o texto some durante o carregamento.

### 📂 ARQUIVO: test/features/search/store_search_test.dart

- ⚙️ Função: Confere se a busca encontra lojas mesmo com acento faltando ou erro de digitação.
- 💬 Comentários Removidos:

  > "O caso que motivou tudo: teclado de celular, ninguém digita 'Açaí'."
  - 💡 Explicação Leiga: O teste confere que "acai" encontra "Açaí da Praça".

  > "Com distância 1 sobre 3 letras, 'bar' acharia 'mar', 'lar' e 'par': devolver qualquer coisa é pior do que não devolver nada."
  - 💡 Explicação Leiga: O teste confere que palavras curtas não geram resultados errados.

  > "2 começa com o termo; 3 tem uma palavra que começa com ele; 1 só menciona na descrição."
  - 💡 Explicação Leiga: O teste confere a ordem dos resultados por relevância.

  > "`List.sort` do Dart não é estável: sem o desempate por posição, a lista trocaria de ordem a cada tecla digitada."
  - 💡 Explicação Leiga: O teste confere que lojas de mesma relevância mantêm a ordem.

### 📂 ARQUIVO: test/features/settings/settings_dialogs_test.dart

- ⚙️ Função: Confere se os diálogos de sair e excluir conta realmente abrem ao serem tocados.
- 💬 Comentários Removidos:

  > "Reprodução do relato 'toco em Excluir conta / Sair da conta e nada aparece'. Monta as telas de verdade e toca nos itens — sem API, porque o que está sendo testado é a abertura do diálogo, não a chamada de rede."
  - 💡 Explicação Leiga: Estes testes reproduzem uma reclamação real: os diálogos não apareciam.

  > "O seletor de tema da tela de Configurações lê o ThemeController, que o `main()` do app inicializa antes do runApp."
  - 💡 Explicação Leiga: A linha prepara o controlador de tema, que a tela precisa para funcionar.

  > "O diálogo pede a palavra-chave digitada — se ele abriu, este texto existe."
  - 💡 Explicação Leiga: O teste confere que o diálogo abriu procurando o texto dentro dele.

### 📂 ARQUIVO: test/features/store/active_stores_manager_test.dart

- ⚙️ Função: Confere se a consulta periódica de lojas para quando o aplicativo sai da tela.
- 💬 Comentários Removidos:

  > "Conta quantas vezes a API foi consultada — é o que distingue 'polling rodando' de 'polling parado' sem precisar esperar os 20s do intervalo real."
  - 💡 Explicação Leiga: Esta classe conta quantas vezes o servidor foi consultado.

  > "Espera até [condicao] valer, com teto de segurança. O polling é disparado sem await (`unawaited(load())`) e o pipeline do Dio atravessa vários microtasks antes de chegar ao adapter, então `Duration.zero` não observa o efeito. Um `delayed` fixo também não serve: 50 ms bastam com a máquina parada e falham quando a suíte inteira roda em paralelo e este isolate não é escalonado a tempo — era exatamente esse o flake."
  - 💡 Explicação Leiga: A função espera até uma condição acontecer, com tempo máximo. Uma espera fixa deixava o teste instável.

  > "Dá tempo para uma requisição indevida acontecer, quando o que se afirma é que ela não acontece. Aqui a espera fixa é a semântica certa: não há condição para aguardar, e sim um intervalo em que nada pode ocorrer."
  - 💡 Explicação Leiga: A função espera um tempo para confirmar que nenhuma consulta foi feita.

  > "Espera a carga TERMINAR, não só sair: `chamadas` incrementa na entrada do adapter, e nesse instante a resposta ainda não percorreu o pipeline do Dio nem chegou ao manager — `stores` ainda estaria vazia."
  - 💡 Explicação Leiga: A linha espera a lista chegar, e não apenas o pedido sair.

  > "Duas esperas, e não uma: `chamadas` incrementa na ENTRADA do adapter, e nesse instante a resposta ainda não percorreu o pipeline do Dio. Sem o sossego depois, a carga de abertura seguia em voo e aterrissava depois do `antes` — subindo o contador sem que o app tivesse consultado nada em segundo plano. (Esperar por `stores.isNotEmpty` também não serve aqui: o manager é singleton e a lista já vem preenchida do teste anterior.)"
  - 💡 Explicação Leiga: A linha espera duas vezes, para o contador não subir por causa de um pedido antigo.

  > "Minimizou: o timer precisa morrer, senão o app segue consultando de 20 em 20 segundos com a tela desligada."
  - 💡 Explicação Leiga: O teste simula o aplicativo sendo minimizado.

  > "Mesmo par de esperas do teste acima, pelo mesmo motivo: `antes` só vale depois que a carga de abertura assentou."
  - 💡 Explicação Leiga: A linha repete a mesma espera dupla do teste anterior.

  > "Deixa a requisição disparada acima terminar antes de sair. Sem isso ela aterrissa no meio do teste seguinte — que afirma justamente que NENHUMA requisição acontece — e o contador sobe por conta deste teste, não do comportamento sob análise."
  - 💡 Explicação Leiga: A linha espera o pedido terminar, para ele não atrapalhar o próximo teste.

  > "API cai no meio da sessão."
  - 💡 Explicação Leiga: O teste simula o servidor ficando indisponível.

### 📂 ARQUIVO: test/features/store/categoria_service_test.dart

- ⚙️ Função: Confere se a lista de categorias é buscada uma vez só e reaproveitada.
- 💬 Comentários Removidos:

  > "Adapter que conta quantas requisições realmente saíram — é o que estes testes medem, já que o comportamento em questão não é o payload devolvido e sim quantas vezes a rede foi tocada."
  - 💡 Explicação Leiga: Esta classe conta quantos pedidos foram enviados ao servidor.

  > "Um tick de atraso: sem ele a resposta chega antes de a segunda chamada concorrente acontecer, e o teste de deduplicação passaria sem exercitar nada."
  - 💡 Explicação Leiga: A linha atrasa a resposta, para o teste conseguir simular dois pedidos ao mesmo tempo.

  > "Sem AuthInterceptor: ele leria SharedPreferences, que não existe fora de um binding de teste."
  - 💡 Explicação Leiga: A linha monta a conexão sem o mecanismo que anexa o crachá.

  > "O caso real: busca, cadastro de loja, painel do comerciante e mapa da home montam juntos no IndexedStack e chamam getAll() antes de qualquer resposta chegar. Só o cache não resolveria — quem resolve é a deduplicação da requisição em voo."
  - 💡 Explicação Leiga: O teste simula quatro telas pedindo as categorias ao mesmo tempo.

  > "Cada tela constrói o seu próprio CategoriaService — um cache de instância não serviria para nada."
  - 💡 Explicação Leiga: O teste confere que a lista guardada é compartilhada entre telas diferentes.

  > "Sem limpar a requisição em voo no caminho de erro, toda chamada posterior receberia a mesma Future já rejeitada e o app nunca se recuperaria de uma falha momentânea de rede."
  - 💡 Explicação Leiga: O teste confere que o aplicativo se recupera depois de uma falha de rede.

  > "A mesma lista é entregue a todas as telas: uma ordenação feita no lugar por uma delas mudaria o que as outras veem."
  - 💡 Explicação Leiga: O teste confere que uma tela não consegue alterar a lista vista pelas outras.

### 📂 ARQUIVO: test/features/store/category_picker_test.dart

- ⚙️ Função: Confere se o seletor de categorias mostra erro, vazio e limite corretamente.
- 💬 Comentários Removidos:

  > "Escolher categoria é obrigatório para concluir o cadastro da loja, então cada estado de falha aqui tem uma consequência concreta: se a seção some silenciosamente, o comerciante fica preso num botão que nunca funciona. Foi um bug real — estes testes existem para ele não voltar."
  - 💡 Explicação Leiga: Estes testes cobrem um defeito real que travava o cadastro da loja.

  > "200 com lista vazia não é falha: repetir a chamada devolveria o mesmo."
  - 💡 Explicação Leiga: O teste confere que uma lista vazia não oferece o botão de tentar de novo.

  > "Sem isto a pessoa fica travada: não pode marcar nem desmarcar."
  - 💡 Explicação Leiga: O teste confere que ainda é possível desmarcar uma categoria no limite.

### 📂 ARQUIVO: test/features/store/nearby_filter_test.dart

- ⚙️ Função: Confere se o filtro de distância inclui e exclui as lojas certas.
- 💬 Comentários Removidos:

  > "Coordenadas reais de Limeira-SP (a cidade do app) pra distâncias que dá pra conferir num mapa, em vez de números inventados."
  - 💡 Explicação Leiga: A linha usa coordenadas reais da cidade, para as distâncias serem verificáveis.

  > "~300 m ao norte do usuário (1 grau de latitude ≈ 111 km)."
  - 💡 Explicação Leiga: A linha cria uma loja a 300 metros de distância.

  > "~3,3 km ao norte."
  - 💡 Explicação Leiga: A linha cria uma loja a 3,3 quilômetros de distância.

  > "~11 km ao norte."
  - 💡 Explicação Leiga: A linha cria uma loja a 11 quilômetros de distância.

  > "Loja cadastrada sem CEP/endereço geocodificado."
  - 💡 Explicação Leiga: A linha cria uma loja sem posição no mapa.

  > "Não dá pra afirmar que ela está dentro de 5 km sem saber onde fica — e ela também não teria pin no mapa."
  - 💡 Explicação Leiga: O teste confere que lojas sem posição são excluídas quando há filtro de distância.

  > "O corte não ordena por distância — quem ordena por proximidade é a seção 'Perto de você' da busca, não o mapa."
  - 💡 Explicação Leiga: O teste confere que o filtro não muda a ordem da lista.

  > "Este é o comportamento que mais confunde: GPS negado ou ainda sem fix, o chip '1 km' fica marcado no modal e a loja a 11 km continua no mapa."
  - 💡 Explicação Leiga: O teste confere que sem GPS o filtro de distância não é aplicado.

### 📂 ARQUIVO: test/features/store/store_create_request_test.dart

- ⚙️ Função: Confere se salvar a loja não apaga campos que não foram editados.
- 💬 Comentários Removidos:

  > "Regressão do bug real: o payload montado à mão na tela omitia endereco/cidade/estado/cep, e cada tick de GPS os reenviava vazios."
  - 💡 Explicação Leiga: O teste confere que o endereço não é apagado ao enviar a posição.

  > "E o status não muda de carona."
  - 💡 Explicação Leiga: O teste confere que o status da loja continua o mesmo.

### 📂 ARQUIVO: test/features/store/store_service_test.dart

- ⚙️ Função: Confere se a leitura dos dados de loja funciona, inclusive com campos faltando.
- 💬 Comentários Removidos:

  > "Adapter que devolve uma resposta fixa sem tocar na rede — é o que a costura de DI do `ApiClient` passou a permitir. Antes deste PR, exercitar service + model exigia uma API real rodando em localhost:8080."
  - 💡 Explicação Leiga: Esta classe devolve uma resposta falsa, sem usar a internet.

  > "Sem AuthInterceptor: ele leria SharedPreferences, que não existe fora de um binding de teste. O ErrorInterceptor é o que interessa aqui."
  - 💡 Explicação Leiga: A linha monta a conexão sem o mecanismo que anexa o crachá.

  > "Campos ausentes caem nos padrões, sem estourar."
  - 💡 Explicação Leiga: O teste confere que campos faltando viram valores padrão.

  > "Um 200 com corpo vazio antes produzia `null as List<dynamic>` — TypeError que escapava de todo `on AppException` do app."
  - 💡 Explicação Leiga: O teste confere que uma resposta vazia vira um erro que o aplicativo sabe tratar.

---

## ✅ FIM DO MANUAL

Este documento cobre os 184 arquivos de código Dart do projeto.
Ele guarda os 1262 blocos de comentário que foram removidos do código-fonte.

