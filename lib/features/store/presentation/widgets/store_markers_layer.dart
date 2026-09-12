import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/store/data/map_cluster.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class StoreMarkersLayer extends StatelessWidget {
  const StoreMarkersLayer({
    super.key,
    required this.stores,
    required this.onStoreTap,
    required this.onClusterTap,
    this.focusedStore,
  });

  final List<StoreDto> stores;
  final StoreDto? focusedStore;
  final ValueChanged<StoreDto> onStoreTap;
  final void Function(MapCluster cluster) onClusterTap;

  static const double _tamanhoPadrao = 42.0;
  static const double _tamanhoFocado = 52.0;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final clusters = agruparLojas(
      stores,
      zoom: camera.zoom,
      area: _areaDe(camera).comMargem(0.25),
      idSempreVisivel: focusedStore?.id,
    );

    return MarkerLayer(
      markers: clusters.map((c) => _marcador(context, c)).toList(growable: false),
    );
  }

  static AreaVisivel _areaDe(MapCamera camera) {
    final bounds = camera.visibleBounds;
    return AreaVisivel(
      sul: bounds.south,
      oeste: bounds.west,
      norte: bounds.north,
      leste: bounds.east,
    );
  }

  Marker _marcador(BuildContext context, MapCluster cluster) {
    if (cluster.isUnico) return _marcadorDeLoja(cluster.lojaUnica);
    return _marcadorDeGrupo(cluster);
  }

  Marker _marcadorDeLoja(StoreDto store) {
    final isFocused = focusedStore?.id == store.id;
    final tamanho = isFocused ? _tamanhoFocado : _tamanhoPadrao;
    return Marker(
      key: ValueKey<int>(store.id),
      point: LatLng(store.latitude!, store.longitude!),
      width: tamanho + 8.0,
      height: tamanho + 8.0,
      child: SemanticTapArea(
        label: store.nome,
        hint: 'Abre os detalhes do comércio',
        selected: isFocused ? true : null,
        pressFeedback: false,
        onTap: () => onStoreTap(store),
        child: _StoreMarkerDot(
          imagemUrl: resolveImagemUrl(store.capaUrl),
          tamanho: tamanho,
          isFocused: isFocused,
        ),
      ),
    );
  }

  Marker _marcadorDeGrupo(MapCluster cluster) {
    return Marker(
      point: cluster.centro,
      width: 52.0,
      height: 52.0,
      child: SemanticTapArea(
        label: '${cluster.total} comércios nesta área',
        hint: 'Aproxima o mapa para separá-los',
        pressFeedback: false,
        onTap: () => onClusterTap(cluster),
        child: _ClusterDot(total: cluster.total),
      ),
    );
  }
}

class _StoreMarkerDot extends StatelessWidget {
  const _StoreMarkerDot({
    required this.imagemUrl,
    required this.tamanho,
    required this.isFocused,
  });

  final String? imagemUrl;
  final double tamanho;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Container(
          width: tamanho,
          height: tamanho,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: isFocused ? 3.5 : 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isFocused ? 0.3 : 0.18),
                blurRadius: isFocused ? 10.0 : 6.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: AppNetworkImage(
              path: imagemUrl,
              displayWidth: tamanho,
              fallback: Container(
                color: isFocused
                    ? ColorsPalette.redComponents
                    : ColorsPalette.redComponents.withValues(alpha: 0.12),
                child: Icon(
                  AppIcons.storefront,
                  color: isFocused ? Colors.white : ColorsPalette.redComponents,
                  size: isFocused ? 24.0 : 18.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClusterDot extends StatelessWidget {
  const _ClusterDot({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Container(
          width: total > 9 ? 46.0 : 40.0,
          height: total > 9 ? 46.0 : 40.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsPalette.redComponents,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 8.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            total > 99 ? '99+' : '$total',
            style: AppText.legenda(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
