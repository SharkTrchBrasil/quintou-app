import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/core/models/space_model.dart';

class SpaceRepository {
  final ApiClient _apiClient;

  SpaceRepository(this._apiClient);

  Future<List<Space>> getSpaces({
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radius,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _apiClient.dio.get('/spaces/', queryParameters: {
      if (category != null) 'category': category,
      if (city != null) 'city': city,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radius != null) 'radius_km': radius,
      'limit': limit,
      'offset': offset,
    });
    return (response.data as List).map((json) => Space.fromJson(json)).toList();
  }

  Future<Space> getSpace(String id) async {
    final response = await _apiClient.dio.get('/spaces/$id');
    return Space.fromJson(response.data);
  }
}
