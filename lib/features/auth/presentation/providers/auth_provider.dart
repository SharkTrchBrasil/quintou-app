import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quintou_app/core/models/user_model.dart';
import 'package:quintou_app/core/providers/providers.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      
      // Tem token salvo — buscar dados do usuário
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getMe();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      // Token expirado ou inválido — limpar e seguir como deslogado
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final repo = ref.read(authRepositoryProvider);
      
      final tokenInfo = await repo.login(email, password);
      
      // Salvar o token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', tokenInfo.accessToken);
      if (tokenInfo.refreshToken.isNotEmpty) {
         await prefs.setString('refresh_token', tokenInfo.refreshToken);
      }
      
      state = state.copyWith(isLoading: false, user: tokenInfo.user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Credenciais inválidas ou erro no servidor.');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    state = AuthState();
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
