import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Notificacoes {
  const Notificacoes._();

  @visibleForTesting
  static const MethodChannel canal = MethodChannel('map_food/notificacoes');

  static const int avisoDaLoja = 7301;

  static Future<bool> mostrar({
    required String titulo,
    required String texto,
    int id = avisoDaLoja,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final mostrou = await canal.invokeMethod<bool>('mostrar', <String, Object>{
        'id': id,
        'titulo': titulo,
        'texto': texto,
      });
      return mostrou ?? false;
    } catch (_) {
      return false;
    }
  }
}
