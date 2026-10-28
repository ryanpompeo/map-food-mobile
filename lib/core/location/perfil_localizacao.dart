import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

enum PerfilLocalizacao { consumidor, ronda, rondaParada }

const int distanciaMinimaConsumidorMetros = 50;
const int distanciaMinimaRondaMetros = 20;
const int distanciaMinimaRondaParadaMetros = 0;
const Duration intervaloRondaAndroid = Duration(seconds: 5);
const Duration intervaloRondaParadaAndroid = Duration(minutes: 2);

const ForegroundNotificationConfig notificacaoDaRonda = ForegroundNotificationConfig(
  notificationTitle: 'MapFood · loja aberta',
  notificationText: 'Sua posição está sendo enviada aos clientes',
  notificationChannelName: 'Loja aberta',
  notificationIcon: AndroidResource(name: 'ic_stat_ronda'),
  color: MfColor.brand,
  enableWakeLock: true,
  setOngoing: true,
);

const ForegroundNotificationConfig notificacaoDaLojaParada = ForegroundNotificationConfig(
  notificationTitle: 'MapFood · loja aberta',
  notificationText: 'Seus clientes veem sua loja neste ponto',
  notificationChannelName: 'Loja aberta',
  notificationIcon: AndroidResource(name: 'ic_stat_ronda'),
  color: MfColor.brand,
  enableWakeLock: false,
  setOngoing: true,
);

const List<PerfilLocalizacao> perfisPorExigencia = [
  PerfilLocalizacao.ronda,
  PerfilLocalizacao.rondaParada,
  PerfilLocalizacao.consumidor,
];

int distanciaMinimaDe(PerfilLocalizacao perfil) => switch (perfil) {
      PerfilLocalizacao.consumidor => distanciaMinimaConsumidorMetros,
      PerfilLocalizacao.ronda => distanciaMinimaRondaMetros,
      PerfilLocalizacao.rondaParada => distanciaMinimaRondaParadaMetros,
    };

LocationSettings configuracaoPara(PerfilLocalizacao perfil, TargetPlatform plataforma) {
  return switch (perfil) {
    PerfilLocalizacao.consumidor => const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: distanciaMinimaConsumidorMetros,
      ),
    PerfilLocalizacao.ronda => _configuracaoDaRonda(plataforma),
    PerfilLocalizacao.rondaParada => _configuracaoDaLojaParada(plataforma),
  };
}

LocationSettings _configuracaoDaLojaParada(TargetPlatform plataforma) {
  return switch (plataforma) {
    TargetPlatform.android => AndroidSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: distanciaMinimaRondaParadaMetros,
        intervalDuration: intervaloRondaParadaAndroid,
        foregroundNotificationConfig: notificacaoDaLojaParada,
      ),
    TargetPlatform.iOS || TargetPlatform.macOS => AppleSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: distanciaMinimaRondaParadaMetros,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      ),
    _ => const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: distanciaMinimaRondaParadaMetros,
      ),
  };
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
