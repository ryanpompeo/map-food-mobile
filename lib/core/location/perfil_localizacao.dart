import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

enum PerfilLocalizacao { consumidor, ronda }

const int distanciaMinimaConsumidorMetros = 50;
const int distanciaMinimaRondaMetros = 20;
const Duration intervaloRondaAndroid = Duration(seconds: 5);

const ForegroundNotificationConfig notificacaoDaRonda = ForegroundNotificationConfig(
  notificationTitle: 'MapFood — loja aberta',
  notificationText: 'Sua posição está sendo enviada aos clientes',
  notificationChannelName: 'Loja aberta',
  notificationIcon: AndroidResource(name: 'ic_stat_ronda'),
  color: MfColor.brand,
  enableWakeLock: true,
  setOngoing: true,
);

const List<PerfilLocalizacao> perfisPorExigencia = [
  PerfilLocalizacao.ronda,
  PerfilLocalizacao.consumidor,
];

int distanciaMinimaDe(PerfilLocalizacao perfil) => switch (perfil) {
      PerfilLocalizacao.consumidor => distanciaMinimaConsumidorMetros,
      PerfilLocalizacao.ronda => distanciaMinimaRondaMetros,
    };

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
        foregroundNotificationConfig: notificacaoDaRonda,
      ),
    TargetPlatform.iOS || TargetPlatform.macOS => AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanciaMinimaRondaMetros,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      ),
    _ => const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanciaMinimaRondaMetros,
      ),
  };
}
