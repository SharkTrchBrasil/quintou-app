import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quintou_app/core/models/user_model.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/shell/app_shell.dart';
import 'package:quintou_app/core/services/secure_storage_service.dart';
import 'package:quintou_app/features/chat/data/services/push_notification_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:quintou_app/features/chat/presentation/providers/chat_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearError = false}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadUser();
    return AuthState();
  }

  Future<void> _loadUser() async {
    try {
      final hasTokens = await SecureStorageService.hasTokens();
      if (!hasTokens) {
        state = state.copyWith(isLoading: false);
        return;
      }
      
      // Tem token salvo — buscar dados do usuário
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getMe();
      state = state.copyWith(isLoading: false, user: user);
      
      // Restore host mode preference
      final prefs = await SharedPreferences.getInstance();
      final savedHostMode = prefs.getBool('is_host_mode') ?? user.isHost;
      ref.read(isHostModeProvider.notifier).setMode(savedHostMode);
      
      // Upload FCM token when app starts and user is already logged in
      PushNotificationService.uploadFcmToken();
    } catch (e) {
      // Token expirado ou inválido — limpar e seguir como deslogado
      await _performCompleteLogout();
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final repo = ref.read(authRepositoryProvider);
      
      final tokenInfo = await repo.login(email, password);
      
      // Salvar tokens de forma segura
      await SecureStorageService.saveTokens(
        accessToken: tokenInfo.accessToken,
        refreshToken: tokenInfo.refreshToken,
      );
      
      // Save host mode preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_host_mode', tokenInfo.user.isHost);
      ref.read(isHostModeProvider.notifier).setMode(tokenInfo.user.isHost);
      
      state = state.copyWith(isLoading: false, user: tokenInfo.user);
      
      // Upload FCM token after manual login
      PushNotificationService.uploadFcmToken();
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Credenciais inválidas ou erro no servidor.');
      return false;
    }
  }

  Future<void> logout() async {
    await _performCompleteLogout();
    state = AuthState();
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> _performCompleteLogout() async {
    // 1. Clear secure tokens
    await SecureStorageService.clearAll();
    
    // 2. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // 3. Reset all app state
    ref.read(isHostModeProvider.notifier).setMode(false);
    ref.read(guestTabIndexProvider.notifier).setIndex(0);
    
    // 4. Invalidate all data providers to clear cached data
    ref.invalidate(conversationsProvider);
    ref.invalidate(unreadCountProvider);
    // Add other providers that cache user-specific data as they are identified
    
    // 5. Clear image cache
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      print('Failed to clear image cache: $e');
    }
    
    // 6. Close any active WebSocket connections
    // This will be handled by the chat providers when they detect logout
    
    print('Complete logout performed');
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String cpf,
    required String phone,
    required bool isHost,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final repo = ref.read(authRepositoryProvider);
      
      await repo.register({
        'email': email,
        'password': password,
        'full_name': fullName,
        'cpf': cpf,
        'phone': phone,
        'is_host': isHost,
      });
      
      // Auto-login após o registro
      return await login(email, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao cadastrar. Tente novamente.');
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
