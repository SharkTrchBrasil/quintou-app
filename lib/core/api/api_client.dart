import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quintou_app/core/services/secure_storage_service.dart';
import 'package:quintou_app/core/models/user_model.dart';

class ApiClient {
  static const String baseUrl = 'https://ifo1usk4zzs6kf3w1axrg1y9.207.180.251.156.sslip.io';
  
  final Dio dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  ApiClient() : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle different types of errors
        
        // 1. Network errors (no internet, timeout, connection refused)
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return handler.next(DioException(
            requestOptions: e.requestOptions,
            error: 'Tempo de resposta esgotado. Verifique sua conexão.',
            type: e.type,
          ));
        }
        
        if (e.type == DioExceptionType.connectionError) {
          return handler.next(DioException(
            requestOptions: e.requestOptions,
            error: 'Sem conexão com a internet. Verifique sua rede.',
            type: e.type,
          ));
        }
        
        // 2. HTTP errors
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          
          // 401 Unauthorized - try refresh token
          if (statusCode == 401 && !_isRefreshing) {
            final refreshResult = await _handleTokenRefresh();
            
            if (refreshResult) {
              // Retry original request with new token
              final newToken = await SecureStorageService.getAccessToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              
              try {
                final response = await dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } catch (retryError) {
                return handler.next(DioException(
                  requestOptions: e.requestOptions,
                  error: retryError,
                ));
              }
            } else {
              // Refresh failed - force logout
              await _forceLogout();
              return handler.next(DioException(
                requestOptions: e.requestOptions,
                error: 'Sessão expirada. Faça login novamente. URL: ${e.requestOptions.path}',
                response: e.response,
              ));
            }
          }
          
          // 403 Forbidden
          if (statusCode == 403) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              error: 'Você não tem permissão para acessar este recurso.',
              response: e.response,
            ));
          }
          
          // 404 Not Found
          if (statusCode == 404) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              error: 'Recurso não encontrado. URL: ${e.requestOptions.path}',
              response: e.response,
            ));
          }
          
          // 409 Conflict (ex: booking conflict)
          if (statusCode == 409) {
            // Let the specific error message from server pass through
            return handler.next(e);
          }
          
          // 429 Too Many Requests
          if (statusCode == 429) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              error: 'Muitas requisições. Aguarde um momento e tente novamente.',
              response: e.response,
            ));
          }
          
          // 500+ Server errors
          if (statusCode != null && statusCode >= 500) {
            return handler.next(DioException(
              requestOptions: e.requestOptions,
              error: 'Erro no servidor. Tente novamente mais tarde.',
              response: e.response,
            ));
          }
        }
        
        // 3. Unknown errors
        return handler.next(DioException(
          requestOptions: e.requestOptions,
          error: 'Erro inesperado. Tente novamente.',
          type: e.type,
        ));
      },
    ));
  }

  Future<bool> _handleTokenRefresh() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh to complete
      await Future.delayed(const Duration(milliseconds: 100));
      return await SecureStorageService.hasTokens();
    }

    _isRefreshing = true;
    
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      // Call refresh endpoint
      final response = await Dio(BaseOptions(baseUrl: baseUrl)).post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final tokenData = Token.fromJson(response.data);
        
        // Save new tokens securely
        await SecureStorageService.saveTokens(
          accessToken: tokenData.accessToken,
          refreshToken: tokenData.refreshToken,
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _forceLogout() async {
    // Clear all tokens
    await SecureStorageService.clearAll();
    
    // Clear SharedPreferences (for non-sensitive data)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_host_mode');
    
    // Note: In a real app, you'd also need to navigate to login
    // and invalidate all providers. This will be handled in auth_provider.dart
    print('Force logout due to token refresh failure');
  }
}
