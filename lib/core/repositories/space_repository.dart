import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/core/models/space_model.dart';

class SpaceRepository {
  final ApiClient _apiClient;

  SpaceRepository(this._apiClient);

  Future<List<Space>> getSpaces({
    String? category,
    String? city,
    String? searchQuery,
    double? minRating,
    double? minPrice,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radius,
    int? minGuests,
    bool? instantBook,
    bool? allowsSmoking,
    bool? allowsAlcohol,
    bool? allowsLoudMusic,
    bool? allowsParties,
    bool? allowsPets,
    bool? allowsChildren,
    bool? hasRestroom,
    bool? hasParking,
    bool? isOutdoor,
    bool? isAdaFriendly,
    bool? hasHeatedPool,
    bool? hasHotTub,
    bool? allowsCommercial,
    String? spaceType,
    List<String>? amenities,
    String? sortBy,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      if (category != null) 'category': category,
      if (city != null) 'city': city,
      if (searchQuery != null) 'search_query': searchQuery,
      if (minRating != null) 'min_rating': minRating,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radius != null) 'radius_km': radius,
      if (minGuests != null) 'min_guests': minGuests,
      if (instantBook != null) 'instant_book': instantBook,
      if (allowsSmoking != null) 'allows_smoking': allowsSmoking,
      if (allowsAlcohol != null) 'allows_alcohol': allowsAlcohol,
      if (allowsLoudMusic != null) 'allows_loud_music': allowsLoudMusic,
      if (allowsParties != null) 'allows_parties': allowsParties,
      if (allowsPets != null) 'allows_pets': allowsPets,
      if (allowsChildren != null) 'allows_children': allowsChildren,
      if (allowsCommercial != null) 'allows_commercial': allowsCommercial,
      if (hasRestroom != null) 'has_restroom': hasRestroom,
      if (hasParking != null) 'has_parking': hasParking,
      if (isOutdoor != null) 'is_outdoor': isOutdoor,
      if (isAdaFriendly != null) 'is_ada_friendly': isAdaFriendly,
      if (hasHeatedPool != null) 'has_heated_pool': hasHeatedPool,
      if (hasHotTub != null) 'has_hot_tub': hasHotTub,
      if (spaceType != null) 'space_type': spaceType,
      if (amenities != null && amenities.isNotEmpty) 'amenities': amenities.join(','),
      if (sortBy != null) 'sort_by': sortBy,
      'limit': limit,
      'offset': offset,
    };
    final response = await _apiClient.dio.get('/spaces/', queryParameters: queryParams);
    return (response.data as List).map((json) => Space.fromJson(json)).toList();
  }

  Future<Space> getSpace(String id) async {
    final response = await _apiClient.dio.get('/spaces/$id');
    return Space.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> autocompleteSpaces(String query) async {
    final response = await _apiClient.dio.get('/spaces/autocomplete', queryParameters: {'q': query});
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Space>> getMyListings() async {
    final response = await _apiClient.dio.get('/spaces/my');
    return (response.data as List).map((json) => Space.fromJson(json)).toList();
  }

  Future<Space> updateSpace(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.put('/spaces/$id', data: data);
    return Space.fromJson(response.data);
  }
}
