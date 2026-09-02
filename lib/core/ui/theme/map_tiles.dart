import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MapTiles {
  const MapTiles._();

  static const _osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const _userAgentPackageName = 'com.example.map_food';

  static Widget layer(BuildContext context) {
    return TileLayer(
      urlTemplate: _osm,
      userAgentPackageName: _userAgentPackageName,
      tileProvider: CancellableNetworkTileProvider(),
    );
  }

  static List<SourceAttribution> attributions(BuildContext context) => [
        TextSourceAttribution('OpenStreetMap contributors'),
      ];
}
