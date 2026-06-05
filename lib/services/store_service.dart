import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/models/store/store_create_request.dart';
import 'package:map_food/models/store/store_dto.dart';

class StoreService {
  final _client = ApiClient.instance;

  Future<StoreDto> create(StoreCreateRequest request) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiConstants.lojas,
      data: request.toJson(),
    );
    return StoreDto.fromJson(data);
  }

  Future<List<StoreDto>> getAll() async {
    final data = await _client.get<List<dynamic>>(ApiConstants.lojas);
    return data.map((e) => StoreDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StoreDto>> getActive() async {
    final data = await _client.get<List<dynamic>>(ApiConstants.lojasAtivas);
    return data.map((e) => StoreDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StoreDto>> searchByName(String nome) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/nome',
      queryParameters: {'nome': nome},
    );
    return data.map((e) => StoreDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StoreDto>> getByCategory(int categoryId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/categoria/$categoryId',
    );
    return data.map((e) => StoreDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StoreDto>> getByMerchant(int merchantId) async {
    final data = await _client.get<List<dynamic>>(
      '${ApiConstants.lojas}/comerciante/$merchantId',
    );
    return data.map((e) => StoreDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}