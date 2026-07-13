import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Rota calculada entre dois pontos: o traçado pelas ruas e a distância total.
class RouteResult {
  final List<LatLng> pontos;
  final double distanciaMetros;

  const RouteResult({required this.pontos, required this.distanciaMetros});
}

/// Calcula rotas pela API pública do OSRM (OpenStreetMap) — grátis e sem
/// chave. Usa um Dio avulso porque a URL é externa (não passa pelo ApiClient,
/// que tem baseUrl/autenticação da API interna do MapFood).
class RouteService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Rota a pé entre [origem] e [destino]. Devolve null em qualquer falha —
  /// o chamador decide o fallback (ex: linha reta).
  Future<RouteResult?> getRoute(LatLng origem, LatLng destino) async {
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

      // GeoJSON usa [longitude, latitude].
      final pontos = coordinates
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      if (pontos.length < 2) return null;

      return RouteResult(
        pontos: pontos,
        distanciaMetros: (route['distance'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}
