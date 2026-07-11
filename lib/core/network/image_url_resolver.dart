import 'package:map_food/core/network/api_constants.dart';

/// Resolve um path de imagem devolvido pelo backend (ex: "/uploads/lojas/x.jpg")
/// para uma URL completa. Devolve `null` se [path] for nulo/vazio, e devolve
/// [path] sem alteração se já for uma URL absoluta.
String? resolveImagemUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '${ApiConstants.baseUrl}$path';
}
