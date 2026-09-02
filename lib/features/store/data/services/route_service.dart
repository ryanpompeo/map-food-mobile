import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> pontos;
  final double distanciaMetros;

  const RouteResult({required this.pontos, required this.distanciaMetros});
}

class RouteService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static final List<MapEntry<String, RouteResult>> _cache = [];
  static const int _cacheMaxSize = 3;

  String _chaveCache(LatLng origem, LatLng destino) =>
      '${origem.latitude.toStringAsFixed(5)},${origem.longitude.toStringAsFixed(5)}'
      '->'
      '${destino.latitude.toStringAsFixed(5)},${destino.longitude.toStringAsFixed(5)}';

  Future<RouteResult?> getRoute(LatLng origem, LatLng destino) async {
    final chave = _chaveCache(origem, destino);
    final indiceEmCache = _cache.indexWhere((entry) => entry.key == chave);
    if (indiceEmCache != -1) {
      final entry = _cache.removeAt(indiceEmCache);
      _cache.insert(0, entry);
      return entry.value;
    }

    try {
      final url =
          'https://router.project-osrm.org/route/v1/foot/'
          '${origem.longitude},${origem.latitude};${destino.longitude},${destino.latitude}'
          '?overview=full&geometries=geojson';

      final response = await _dio.get<Map<String, dynamic>>(url);
      final data = response.data;
      if (data == null || data['code'] != 'Ok') return null;

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;

      final pontos = coordinates
          .whereType<List<dynamic>>()
          .where((c) => c.length >= 2 && c[0] is num && c[1] is num)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      if (pontos.length < 2) return null;

      final resultado = RouteResult(
        pontos: pontos,
        distanciaMetros: (route['distance'] as num).toDouble(),
      );

      _cache.insert(0, MapEntry(chave, resultado));
      if (_cache.length > _cacheMaxSize) _cache.removeLast();

      return resultado;
    } catch (_) {
      return null;
    }
  }
}
