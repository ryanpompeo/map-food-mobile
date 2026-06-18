
<h1 align="center">MapFood — Mobile</h1>

<p align="center">
  Conectando consumidores a vendedores ambulantes de alimentos através de um mapa interativo.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Version-1.0.0-success?style=for-the-badge" alt="Version" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge" alt="Platform" />
</p>

---

## 📖 Sobre o Projeto

**MapFood** é um aplicativo mobile desenvolvido em Flutter que conecta **consumidores** a **vendedores ambulantes de alimentos** (comerciantes). Por meio de um mapa interativo, o consumidor pode descobrir vendedores próximos filtrados por categoria — de lanches e hot dogs a gelados e açaí — enquanto os comerciantes gerenciam sua loja, horário de funcionamento e visibilidade no mapa.

### Tipos de Usuário

| Papel | Descrição |
|---|---|
| 🧑‍🍳 **Comerciante** | Cadastra e gerencia sua loja, define categorias, horários e acompanha avaliações |
| 🧑‍💻 **Consumidor** | Descobre vendedores no mapa, favorita estabelecimentos e deixa avaliações |
| 👤 **Visitante** | Navega pelo app sem conta, com acesso limitado |

---

## ✨ Funcionalidades

### Para Consumidores
- 🗺️ **Mapa interativo** com vendedores próximos em tempo real
- 🔍 **Busca e filtro** por categoria (Lanches, Espetinhos, Pastel, Doces, Bebidas, Gelados, Pipoca, etc.)
- ❤️ **Favoritos** — salve seus vendedores preferidos
- ⭐ **Avaliações** — leia e deixe reviews nos estabelecimentos
- 📋 **Mais informações** sobre cada loja (cardápio, horários, contato)
- 👤 **Perfil** com gerenciamento de conta

### Para Comerciantes
- 🏪 **Cadastro de loja** com nome, categoria, localização e dados de contato
- 📊 **Dashboard** com visão geral do estabelecimento
- 🟢 **Status de funcionamento** — controle quando sua loja aparece no mapa
- 🔍 **Busca de lojas** na plataforma
- 👤 **Perfil** com gerenciamento de conta

### Geral
- 🔐 **Autenticação** (login e cadastro) com dois tipos de conta
- 💾 **Sessão persistente** via SharedPreferences
- 🚀 **Transições fluidas** no estilo Cupertino (iOS/Android)
- 📱 **Design responsivo** adaptado a diferentes tamanhos de tela

---

## 🛠️ Tecnologias e Dependências

### Core
| Pacote | Versão | Descrição |
|---|---|---|
| [Flutter](https://flutter.dev) | 3.x | Framework principal |
| [Dart](https://dart.dev) | ^3.10.1 | Linguagem de programação |

### UI & Design
| Pacote | Versão | Descrição |
|---|---|---|
| `google_fonts` | ^8.0.2 | Tipografia — fonte Poppins |
| `flutter_screenutil` | ^5.7.0 | Responsividade por tamanho de tela |
| `responsive_framework` | ^1.5.1 | Layouts responsivos |
| `lucide_flutter` | ^1.17.0 | Ícones modernos |
| `animated_text_kit` | ^4.3.0 | Animações de texto |
| `flutter_markdown` | 0.7.7+1 | Renderização de Markdown |

### Rede & Dados
| Pacote | Versão | Descrição |
|---|---|---|
| `dio` | ^5.8.0+1 | Cliente HTTP com interceptors |
| `shared_preferences` | ^2.5.3 | Armazenamento local (sessão) |

### Utilitários
| Pacote | Versão | Descrição |
|---|---|---|
| `cpf_cnpj_validator` | 2.0.0 | Validação de CPF/CNPJ |
| `mask_text_input_formatter` | ^2.9.0 | Máscaras de entrada (telefone, CPF, etc.) |

---

## 🏗️ Arquitetura

O projeto segue uma arquitetura baseada em **Feature-First** com separação em camadas:

```
lib/
├── main.dart                  # Ponto de entrada + roteamento
├── app/
│   └── router/                # Definição de rotas (AppRoutes)
├── core/                      # Código compartilhado
│   ├── errors/                # Exceções customizadas (AppException)
│   ├── network/               # ApiClient (Dio), interceptors de auth e erro
│   ├── storage/               # AuthStorage (SharedPreferences)
│   └── ui/
│       ├── theme/             # Cores, tipografia, dimensões (design tokens)
│       ├── widgets/           # Widgets reutilizáveis (AppButton, etc.)
│       ├── providers/         # Providers de estado
│       └── validators/        # Validadores de formulários
└── features/
    ├── auth/                  # Login, cadastro de consumidor/comerciante
    ├── consumer/              # Home do consumidor, perfil
    ├── merchant/              # Home do comerciante, perfil
    ├── store/                 # Cadastro de loja, dashboard, página de funcionamento
    ├── search/                # Busca (versão consumidor e comerciante)
    ├── favorites/             # Favoritos do consumidor
    ├── reviews/               # Avaliações de lojas
    └── guest/                 # Fluxo de visitante (home, como funciona)
```

Cada feature segue a estrutura:
```
feature/
├── data/
│   ├── models/        # DTOs / modelos de dados
│   └── services/      # Chamadas à API
└── presentation/
    ├── pages/         # Páginas (Widgets StatefulWidget/StatelessWidget)
    └── widgets/       # Widgets específicos da feature
```

### Camada de Rede

O `ApiClient` é um **singleton** que encapsula o `Dio` com:
- `AuthInterceptor` — injeta o token de autenticação nas requisições
- `ErrorInterceptor` — trata erros HTTP e os converte em `AppException`

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.x ou superior)
- [Dart SDK](https://dart.dev/get-dart) ^3.10.1
- Android Studio / Xcode (para emuladores) ou um dispositivo físico
- Git

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/map-food-mobile.git
   cd map-food-mobile
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure a URL da API**

   Verifique e ajuste a URL base da API em:
   ```
   lib/core/network/api_constants.dart
   ```

4. **Execute o app**
   ```bash
   flutter run
   ```

### Build de Produção

```bash
# Android (APK)
flutter build apk --release

# Android (App Bundle)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🗺️ Fluxo de Navegação

```
GuestHomePage (/)
├── LoginPage (/login)
│   ├── ConsumerHomePage (/consumerHome)
│   └── MerchantHomePage (/merchantDashboard)
│       └── StoreRegisterPage (/storeRegister)  ← se sem loja cadastrada
├── HowItWorksPage (/howItWorks)
└── AccountTypePage (/accountType)
    ├── ConsumerRegisterPage (/consumerRegister)
    └── MerchantRegisterPage (/merchantRegister)
        └── StoreRegisterPage (/storeRegister)
```

A sessão é verificada no `main()`: se já autenticado, o usuário é redirecionado diretamente para sua tela home (consumidor ou comerciante).

---

## 🎨 Design System

O app utiliza um design system centralizado em `lib/core/ui/theme/`:

| Arquivo | Conteúdo |
|---|---|
| `app_colors.dart` | Paleta de cores (`ColorsPalette`) |
| `app_typography.dart` | Estilos de texto (`AppText`) com Poppins |
| `app_dimensions.dart` | Espaçamentos (`AppSpacing`) e raios (`AppRadius`) |

Fonte principal: **Poppins** (via Google Fonts)

Cor de destaque: **Vermelho** (`ColorsPalette.redComponents`)

---

## 📂 Categorias de Vendedores

| Categoria |
|---|
| Todos |
| Lanches e Hot Dogs |
| Espetinhos |
| Pastel e Salgados |
| Doces e Sobremesas |
| Bebidas |
| Gelados e Açaí |
| Milho e Pamonha |
| Pipoca |

---

## 🤝 Contribuindo

1. Faça um **fork** do projeto
2. Crie uma branch para sua feature: `git checkout -b feature/minha-feature`
3. Faça o commit das suas alterações: `git commit -m 'feat: adiciona minha feature'`
4. Faça o push para a branch: `git push origin feature/minha-feature`
5. Abra um **Pull Request**

---

## 📄 Licença

Este projeto é privado e não está disponível para publicação no pub.dev.

---

<p align="center">
  Feito com ❤️ e <a href="https://flutter.dev">Flutter</a>
</p>
