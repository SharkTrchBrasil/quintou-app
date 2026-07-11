import 'package:dio/dio.dart';
import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/core/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Token> login(String email, String password) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return Token.fromJson(response.data);
  }

  Future<User> register(Map<String, dynamic> userData) async {
    final response = await _apiClient.dio.post('/auth/register', data: userData);
    return User.fromJson(response.data);
  }

  Future<Token> refreshToken(String refreshToken) async {
    final response = await _apiClient.dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return Token.fromJson(response.data);
  }
}
