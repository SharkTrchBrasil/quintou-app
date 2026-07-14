import 'package:quintou_app/core/api/api_client.dart';

class FavoriteRepository {
  final ApiClient _apiClient;

  FavoriteRepository(this._apiClient);

  /// Add a space to favorites
  Future<Map<String, dynamic>> addFavorite(String spaceId) async {
    final response = await _apiClient.dio.post('/favorites/$spaceId');
    return response.data;
  }

  /// Remove a space from favorites
  Future<void> removeFavorite(String spaceId) async {
    await _apiClient.dio.delete('/favorites/$spaceId');
  }

  /// List all user favorites (returns favorites with space data)
  Future<List<Map<String, dynamic>>> listFavorites({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _apiClient.dio.get(
      '/favorites',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
