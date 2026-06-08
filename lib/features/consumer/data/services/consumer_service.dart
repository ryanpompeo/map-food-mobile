import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/features/consumer/data/models/consumer_register_request.dart';

class ConsumerService {
  final _client = ApiClient.instance;

  Future<void> register(ConsumerRegisterRequest request) async {
    await _client.post<dynamic>(ApiConstants.consumidores, data: request.toJson());
  }
}