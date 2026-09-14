import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PermissaoNotificacoes {
  const PermissaoNotificacoes._();

  static const MethodChannel _canal = MethodChannel('map_food/notificacoes');

  static Future<bool> pedir() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      return await _canal.invokeMethod<bool>('pedirPermissao') ?? false;
    } catch (_) {
      return false;
    }
  }
}
