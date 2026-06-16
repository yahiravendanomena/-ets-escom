import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthState.initial()) {
    // Al iniciar, verifica si hay sesión guardada.
    checkAuthStatus();
  }

  /// Verifica si hay un usuario autenticado al iniciar la app.
  Future<void> checkAuthStatus() async {
    final result = await _getCurrentUserUseCase(const NoParams());
    result.fold(
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  /// Realiza el login con username y password.
  Future<void> login({required String username, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);

    final result = await _loginUseCase(
      LoginParams(username: username, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      },
    );
  }

  /// Cierra la sesión actual.
  Future<void> logout() async {
    await _logoutUseCase(const NoParams());
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: sl(),
    logoutUseCase: sl(),
    getCurrentUserUseCase: sl(),
  );
});