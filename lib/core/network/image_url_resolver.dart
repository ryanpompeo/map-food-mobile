import 'package:map_food/core/network/api_constants.dart';

String? resolveImagemUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '${ApiConstants.baseUrl}$path';
}
