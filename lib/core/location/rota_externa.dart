import 'package:url_launcher/url_launcher.dart';

typedef TentarAbrir = Future<bool> Function(Uri destino);

Uri destinoNoAppDeMapas(double latitude, double longitude, String nome) {
  final coordenadas = '$latitude,$longitude';
  final rotulo = nome.trim();
  return Uri(
    scheme: 'geo',
    path: coordenadas,
    queryParameters: {'q': rotulo.isEmpty ? coordenadas : '$coordenadas($rotulo)'},
  );
}

Uri destinoNaWeb(double latitude, double longitude) => Uri.https(
      'www.google.com',
      '/maps/dir/',
      {'api': '1', 'destination': '$latitude,$longitude'},
    );

class RotaExterna {
  static TentarAbrir abridor =
      (destino) => launchUrl(destino, mode: LaunchMode.externalApplication);

  static void restaurarAbridor() {
    abridor = (destino) => launchUrl(destino, mode: LaunchMode.externalApplication);
  }

  static Future<bool> tracar({
    required double latitude,
    required double longitude,
    required String nome,
  }) async {
    final destinos = [
      destinoNoAppDeMapas(latitude, longitude, nome),
      destinoNaWeb(latitude, longitude),
    ];

    for (final destino in destinos) {
      try {
        if (await abridor(destino)) return true;
      } catch (_) {}
    }
    return false;
  }
}
