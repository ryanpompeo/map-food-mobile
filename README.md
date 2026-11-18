<h1 align="center">MapFood — Mobile</h1>

<p align="center">
  Conectando consumidores a vendedores ambulantes de alimentos através de um mapa interativo.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-celular-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
</p>

---

## Sobre

O **MapFood** conecta **consumidores** a **vendedores ambulantes de alimentos** (comerciantes) através de um mapa com a posição de cada loja. O consumidor descobre quem está vendendo perto dele; o comerciante cadastra a loja, avisa quando está aberto e, se for uma loja móvel, aparece no mapa na posição em que está.

Este repositório é o **aplicativo para celular**. Ele faz parte de um projeto com três partes:

| Parte | Repositório | O que é |
|---|---|---|
| API | `lucash-martins/mapfood-api` | Servidor Spring Boot (Java 17) com banco MySQL |
| Web | `lucash-martins/mapfood-web` | Site em React + Vite |
| **Mobile** | `ryanpompeo/map-food-mobile` | **Este aplicativo, em Flutter** |

O app não guarda dados sozinho: tudo vem da API, que precisa estar rodando.

## O que o app faz

**Visitante (sem conta)**
- Mapa com as lojas próximas, agrupadas quando estão muito juntas
- Busca por nome e filtro por categoria e distância
- Página da loja com fotos, descrição, endereço, avaliações e um resumo das avaliações feito por IA
- Rota até a loja

**Consumidor**
- Cadastro com verificação de e-mail por código, login e recuperação de senha
- Favoritos, com aviso quando uma loja favorita está por perto
- Avaliação com estrelas e comentário (dá para editar e excluir), filtro de avaliações por estrela e votos de "útil"
- Denúncia de loja, inclusive com foto em caso de risco sanitário, e acompanhamento da resposta
- Perfil com foto e resumo da atividade

**Comerciante**
- Cadastro de uma ou mais lojas, com endereço pelo CEP e posição no mapa
- Fotos da loja, com escolha da foto de destaque
- Abrir e fechar a loja, com fechamento automático no horário escolhido
- Loja móvel: a posição no mapa acompanha o celular do comerciante enquanto a loja está aberta
- Métricas de visitas, avaliações e denúncias por período, com exportação em CSV
- Resposta às denúncias dentro do prazo

**Para todos**
- Modo claro, escuro ou automático
- Letra do sistema respeitada até 2 vezes o tamanho normal, sem cortar texto

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x (testado com 3.44) e Dart 3.10 ou mais novo
- Android Studio ou as ferramentas de linha de comando do Android, para instalar no celular
- Um celular Android com a **depuração USB** ligada, ou um emulador
- A **API do MapFood rodando** (veja o repositório `mapfood-api`)

O app foi feito para **celular**. Ele não roda no navegador.

## Como rodar

### 1. Instalar as dependências

```bash
flutter pub get
```

### 2. Descobrir o endereço da API

O app precisa saber onde a API está. **Isso é informado na hora de rodar, não fica no código.**

| Onde o app vai rodar | Endereço a usar |
|---|---|
| Celular de verdade | O IP do computador que roda a API, na mesma rede Wi-Fi. Ex.: `http://192.168.0.15:8080` |
| Emulador Android | `http://10.0.2.2:8080` (o emulador enxerga o computador por esse endereço) |

Para descobrir o IP do computador no Windows, rode `ipconfig` e procure o **Endereço IPv4**. No Linux ou no macOS, use `ip addr` ou `ifconfig`.

> ⚠️ Se nenhum endereço for informado, o app procura a API em `http://localhost:8080`. No celular, `localhost` é **o próprio celular**: o app abre, mas nenhuma loja aparece.

### 3. Rodar

```bash
flutter run --dart-define=API_URL=http://192.168.0.15:8080
```

Troque o IP pelo seu. Para medir o desempenho real, sem o modo de depuração, acrescente `--profile`.

**Se o app abrir, mas nenhuma loja aparecer:**
1. Confira se a API está rodando no computador.
2. Confira se o celular está no mesmo Wi-Fi que o computador.
3. Confira se o firewall do computador libera a porta **8080**.

## Como gerar o APK

```bash
flutter build apk --release --dart-define=API_URL=http://192.168.0.15:8080
```

O arquivo fica em `build/app/outputs/flutter-apk/app-release.apk`. Copie-o para o celular e instale.

O endereço da API fica **gravado dentro do APK**. Se o IP do computador mudar, é preciso gerar o APK de novo.

Este é um projeto acadêmico e não está publicado na Play Store. O APK é assinado com a chave de testes do Flutter, o que permite instalar direto no celular.

## Testes

```bash
flutter test      # roda todos os testes
flutter analyze   # confere o código
```

São 58 arquivos de teste, com cerca de 840 casos. Os principais:

- **Telas e regras de cada função**, em `test/features/`, com a API simulada: nenhum teste precisa de internet ou de servidor.
- **`test/dynamic_type_test.dart`**: confere que os componentes crescem junto com a letra do sistema.
- **`test/varredura_de_telas_test.dart`**: abre 27 telas em 3 tamanhos de celular e 3 tamanhos de letra, também no modo escuro, e falha se algum texto sair da tela.

As telas com mapa dependem de GPS e são conferidas no celular.

## Organização do código

```
lib/
├── app/          # rotas e início do app
├── core/         # o que é compartilhado entre as telas
│   ├── network/  # conexão com a API (dio) e tradução de erros
│   ├── session/  # sessão do usuário e saída automática quando o login vence
│   ├── storage/  # o que fica salvo no aparelho
│   ├── location/ # GPS e endereço
│   ├── notificacoes/
│   └── ui/       # cores, tipografia, ícones e componentes visuais
└── features/     # uma pasta por função do app
    ├── auth/  consumer/  merchant/  store/  search/  favorites/
    ├── avaliacoes/  denuncias/  analytics/  guest/  onboarding/
    └── settings/  contato/
```

Cada pasta de `features/` se divide em:
- `data/`: modelos e chamadas à API;
- `presentation/`: telas, componentes e controladores.

## Manual de bordo

O código não tem comentários. As explicações de cada arquivo, e o porquê de cada decisão, ficam em **[`manual_de_bordo.md`](manual_de_bordo.md)**: lá cada trecho vem com uma explicação técnica e uma explicação em linguagem simples.

## Licença

Projeto acadêmico e privado, sem publicação no pub.dev nem nas lojas de aplicativos.
