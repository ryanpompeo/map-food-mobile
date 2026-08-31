import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

/// A cartografia do app. **Sempre clara**, nos dois temas.
///
/// Já houve aqui um filtro de cor (`invert(1) hue-rotate(180deg)`) que
/// escurecia os tiles do OpenStreetMap junto com o tema do sistema. Ele saiu
/// por decisão de produto: o mapa é a tela principal do app e sua legibilidade
/// não deve variar com a preferência de tema do aparelho.
///
/// A escolha tem custo e ele é conhecido: no tema escuro o mapa é uma
/// superfície clara ocupando a tela inteira. Em troca, tudo que é desenhado
/// **sobre** a cartografia — os pins vermelhos de marca, a rota, o ponto azul
/// do usuário — tem um único fundo previsível para contrastar, em vez de dois.
/// A bottom bar, os controles de câmera e o véu do topo continuam seguindo o
/// tema normalmente: só os tiles ficam de fora.
class MapTiles {
  const MapTiles._();

  static const _osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const _userAgentPackageName = 'com.example.map_food';

  static Widget layer(BuildContext context) {
    return TileLayer(
      urlTemplate: _osm,
      // Sem `{s}`: o OSM pede explicitamente que não se distribua por
      // subdomínio (ver o aviso do próprio flutter_map).
      userAgentPackageName: _userAgentPackageName,
      tileProvider: CancellableNetworkTileProvider(),
    );
  }

  /// Crédito obrigatório da cartografia em uso.
  static List<SourceAttribution> attributions(BuildContext context) => [
        TextSourceAttribution('OpenStreetMap contributors'),
      ];
}
