import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/models/merchant/merchant_register_request.dart';

class MerchantService {
  final _client = ApiClient.instance;

  Future<void> register(MerchantRegisterRequest request) async {
    await _client.post<dynamic>(ApiConstants.comerciantes, data: request.toJson());
  }
}