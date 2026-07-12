import 'package:quintou_app/core/api/api_client.dart';

class HostRepository {
  final ApiClient _apiClient;

  HostRepository(this._apiClient);

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _apiClient.dio.get('/host/dashboard');
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> incrementSpaceViews(String spaceId) async {
    await _apiClient.dio.post('/spaces/$spaceId/view');
  }
}
