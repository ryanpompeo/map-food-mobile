import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';

class RatingService {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> getStoreRatings(int storeId) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.avaliacoes}/loja/$storeId',
    );
    return data;
  }
}
