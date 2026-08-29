import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

/// A cartografia do app, resolvida pelo tema.
///
/// O mapa era o único pedaço do app imune ao tema escuro: com todo o resto em
/// `#0E0F12`, uma placa branca de tela inteira no meio da noite. Não é só
/// desconforto — os pins e a rota (vermelho da marca sobre branco) foram
/// desenhados para se destacar de uma cartografia clara.
///
/// **Uma fonte de tiles nos dois temas** (OpenStreetMap), com o escuro obtido
/// por filtro de cor sobre os mesmos tiles. A versão anterior baixava o CARTO
/// *Dark Matter* no escuro: era mais bonito, mas o CARTO passou a carimbar
/// "API KEY REQUIRED" em diagonal nos tiles anônimos — e as alternativas
/// prontas de cartografia escura (Stadia, Mapbox, Thunderforest) todas exigem
/// cadastro e chave. O filtro não depende de ninguém e não tem cota.
///
/// O filtro **não** é a inversão pura do `darkModeTilesContainerBuilder` do
/// flutter_map: inverter e parar ali joga o matiz para o lado oposto do círculo
/// cromático — parque virava magenta, rio virava laranja. Aqui a inversão vem
/// composta com uma rotação de matiz de 180°, que devolve cada cor à sua
/// própria família: o verde continua verde, a água continua azul, só que agora
/// escuros. É o mesmo `invert(1) hue-rotate(180deg)` que a web usa há anos para
/// escurecer mapas raster.
class MapTiles {
  const MapTiles._();

  static const _osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const _userAgentPackageName = 'com.example.map_food';

  /// `invert(1) · hue-rotate(180°)` numa matriz só.
  ///
  /// As linhas são a matriz de rotação de matiz negada, e o `+255` da quinta
  /// coluna é a inversão — a soma de cada linha dá exatamente `-1`, então o
  /// branco do papel vai a zero (preto) e o preto do traço vai a 255.
  static const _filtroEscuro = ColorFilter.matrix(<double>[
    0.574, -1.430, -0.144, 0, 255,
    -0.426, -0.430, -0.144, 0, 255,
    -0.426, -1.430, 0.856, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  /// Matriz identidade: no tema claro os tiles passam intocados.
  ///
  /// O `ColorFiltered` fica na árvore **sempre**, com filtro neutro no claro,
  /// em vez de aparecer só no escuro. Envolver o `TileLayer` condicionalmente
  /// trocaria o tipo do widget naquela posição, e o Flutter descartaria o
  /// layer inteiro a cada troca de tema — recarregando todos os tiles da rede.
  static const _filtroNeutro = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Widget layer(BuildContext context) {
    return ColorFiltered(
      colorFilter: _isDark(context) ? _filtroEscuro : _filtroNeutro,
      child: TileLayer(
        urlTemplate: _osm,
        // Sem `{s}`: o OSM pede explicitamente que não se distribua por
        // subdomínio (ver o aviso do próprio flutter_map).
        userAgentPackageName: _userAgentPackageName,
        tileProvider: CancellableNetworkTileProvider(),
      ),
    );
  }

  /// Crédito obrigatório da cartografia em uso. Agora é um só nos dois temas —
  /// o escuro é o mesmo mapa do OSM, filtrado.
  static List<SourceAttribution> attributions(BuildContext context) => [
        TextSourceAttribution('OpenStreetMap contributors'),
      ];
}
