<h1 align="center">MapFood — Mobile</h1>

<p align="center">
  Conectando consumidores a vendedores ambulantes de alimentos através de um mapa interativo.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
</p>

---

## Sobre

**MapFood** conecta **consumidores** a **vendedores ambulantes de alimentos** (comerciantes) através de um mapa interativo com geolocalização em tempo real. O consumidor descobre vendedores próximos por categoria; o comerciante gerencia loja, status de funcionamento e visibilidade no mapa.

<!-- TODO: adicionar screenshot/GIF do mapa em ação -->

## Como Rodar

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x, Dart ^3.10.1.

```bash
flutter pub get
flutter run
```

A URL base da API está em `lib/core/network/api_constants.dart` — ajuste lá para apontar para outro backend.

Build de produção: `flutter build apk --release` (ou `appbundle`/`ios --release`).

## Licença

Projeto pessoal e privado — sem publicação no pub.dev.
