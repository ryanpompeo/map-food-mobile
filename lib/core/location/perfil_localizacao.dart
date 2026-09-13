import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum PerfilLocalizacao { consumidor, ronda }

const int distanciaMinimaConsumidorMetros = 50;
const int distanciaMinimaRondaMetros = 20;
const Duration intervaloRondaAndroid = Duration(seconds: 5);

LocationSettings configuracaoPara(PerfilLocalizacao perfil, TargetPlatform plataforma) {
  if (perfil == PerfilLocalizacao.consumidor) {
    return const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: distanciaMinimaConsumidorMetros,
    );
  }
  return _configuracaoDaRonda(plataforma);
}

LocationSettings _configuracaoDaRonda(TargetPlatform plataforma) {
  return switch (plataforma) {
    TargetPlatform.android => AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanciaMinimaRondaMetros,
        intervalDuration: intervaloRondaAndroid,
      ),
    TargetPlatform.iOS || TargetPlatform.macOS => AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanciaMinimaRondaMetros,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
      ),
    _ => const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanciaMinimaRondaMetros,
      ),
  };
}
