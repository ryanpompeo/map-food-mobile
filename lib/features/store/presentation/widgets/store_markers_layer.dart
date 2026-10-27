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
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';
import 'package:map_food/features/store/presentation/widgets/visto_ha.dart';

String distanciaFalada(double metros) {
  if (metros < 1000) return 'a ${metros.round()} m de você';
  return 'a ${(metros / 1000).toStringAsFixed(1)} km de você';
}

class StoreMarkersLayer extends StatefulWidget {
  const StoreMarkersLayer({
    super.key,
    required this.stores,
    required this.onStoreTap,
    required this.onClusterTap,
    this.focusedStore,
    this.posicaoDoUsuario,
  });

  final List<StoreDto> stores;
  final StoreDto? focusedStore;
  final LatLng? posicaoDoUsuario;
  final ValueChanged<StoreDto> onStoreTap;
  final void Function(MapCluster cluster) onClusterTap;

  @override
  State<StoreMarkersLayer> createState() => _StoreMarkersLayerState();
}

class _StoreMarkersLayerState extends State<StoreMarkersLayer> {
  static const double _tamanhoPadrao = 42.0;
  static const double _tamanhoFocado = 52.0;
  static const double _passoDeZoom = 0.25;

  List<StoreDto>? _lojasEmCache;
  (double, int?)? _chaveEmCache;
  List<MapCluster> _clustersEmCache = const [];

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final area = _areaDe(camera).comMargem(0.25);
    final visiveis = _clustersDoZoom(camera.zoom)
        .where((c) => area.contem(c.centro.latitude, c.centro.longitude))
        .toList(growable: false);

    return MarkerLayer(
      markers: [
        ..._pontosDeOrigem(visiveis),
        ...visiveis.map(_marcador),
      ],
    );
  }

  List<MapCluster> _clustersDoZoom(double zoom) {
    final chave = ((zoom / _passoDeZoom).floorToDouble() * _passoDeZoom, widget.focusedStore?.id);
    if (identical(_lojasEmCache, widget.stores) && _chaveEmCache == chave) return _clustersEmCache;
    _lojasEmCache = widget.stores;
    _chaveEmCache = chave;
    return _clustersEmCache = agruparLojas(widget.stores, zoom: chave.$1, idSempreVisivel: chave.$2);
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

  Iterable<Marker> _pontosDeOrigem(List<MapCluster> clusters) =>
      {for (final c in clusters) ?c.origem}.map(
        (origem) => Marker(
          point: origem,
          width: 12.0,
          height: 12.0,
          child: const ExcludeSemantics(child: _PontoDeOrigem()),
        ),
      );

  Marker _marcador(MapCluster cluster) {
    if (cluster.isUnico) return _marcadorDeLoja(cluster.lojaUnica, cluster.centro);
    return _marcadorDeGrupo(cluster);
  }

  String _rotuloDaLoja(StoreDto store, LatLng ponto) {
    final partes = <String>[store.nome];

    final usuario = widget.posicaoDoUsuario;
    if (usuario != null) {
      partes.add(distanciaFalada(const Distance().distance(usuario, ponto)));
    }

    final visto = rotuloVistoHa(ActiveStoresManager.instance.semSinalHa(store.id));
    if (visto != null) partes.add(visto.toLowerCase());

    return partes.join(', ');
  }

  Marker _marcadorDeLoja(StoreDto store, LatLng ponto) {
    final isFocused = widget.focusedStore?.id == store.id;
    final tamanho = isFocused ? _tamanhoFocado : _tamanhoPadrao;
    return Marker(
      key: ValueKey<int>(store.id),
      point: ponto,
      width: tamanho + 8.0,
      height: tamanho + 8.0,
      child: SemanticTapArea(
        label: _rotuloDaLoja(store, ponto),
        hint: 'Abre os detalhes do comércio',
        selected: isFocused ? true : null,
        pressFeedback: false,
        onTap: () => widget.onStoreTap(store),
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
        onTap: () => widget.onClusterTap(cluster),
        child: _ClusterDot(total: cluster.total),
      ),
    );
  }
}

class _PontoDeOrigem extends StatelessWidget {
  const _PontoDeOrigem();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorsPalette.redComponents.withValues(alpha: 0.35),
        border: Border.all(color: Colors.white, width: 1.5),
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
