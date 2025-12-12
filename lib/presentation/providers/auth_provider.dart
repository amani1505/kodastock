
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/auth/login_request_model.dart';
import '../../data/models/auth/signup_request_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

// Auth State
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  
  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, isLoading: $isLoading, error: $errorMessage)';
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        super(const AuthState());

  Future<void> checkAuthStatus() async {
    debugPrint('AuthNotifier: Checking auth status...');
    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    try {
      final isLoggedIn = await _checkAuthStatusUseCase();
      debugPrint('AuthNotifier: isLoggedIn = $isLoggedIn');
      
      if (isLoggedIn) {
        try {
          final user = await _getCurrentUserUseCase();
          debugPrint('AuthNotifier: User loaded = ${user?.email}');
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          );
        } catch (e) {
          debugPrint('AuthNotifier: Error getting user, but token exists');
          // Token exists but couldn't get user - still authenticated
          state = state.copyWith(
            status: AuthStatus.authenticated,
            isLoading: false,
          );
        }
      } else {
        debugPrint('AuthNotifier: Not logged in');
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('AuthNotifier: Error checking auth status: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
    
    debugPrint('AuthNotifier: Final state = ${state.status}');
  }



Future<bool> login({
  required String email,
  required String password,
  bool rememberMe = false,
}) async {
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    final request = LoginRequestModel(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    final response = await _loginUseCase(request);

    // Use isSuccess helper instead of checking success field
    if (response.isSuccess && response.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user!.toEntity(),
        isLoading: false,
      );
      return true;
    } else if (response.isSuccess) {
      // Token exists but no user object - still successful
      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: response.message ?? 'Login failed',
        isLoading: false,
      );
      return false;
    }
  } on DioException catch (e) {
    String errorMessage = 'An error occurred';
    
    if (e.response?.statusCode == 401) {
      errorMessage = 'Invalid email or password';
    } else if (e.response?.statusCode == 422) {
      final data = e.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          errorMessage = firstError is List ? firstError[0] : firstError.toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
      }
    } else if (e.type == DioExceptionType.connectionError ||
               e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Network error. Please check your connection.';
    }

    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: errorMessage,
      isLoading: false,
    );
    return false;
  } catch (e) {
    debugPrint('Login error: $e');
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'An unexpected error occurred',
      isLoading: false,
    );
    return false;
  }
}

Future<bool> register({
  required String name,
  required String email,
  required String password,
  required String passwordConfirmation,
}) async {
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    final request = SignupRequestModel(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    final response = await _registerUseCase(request);

    // Use isSuccess helper
    if (response.isSuccess && response.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user!.toEntity(),
        isLoading: false,
      );
      return true;
    } else if (response.isSuccess) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: response.message ?? 'Registration failed',
        isLoading: false,
      );
      return false;
    }
  } on DioException catch (e) {
    String errorMessage = 'An error occurred';
    
    if (e.response?.statusCode == 422) {
      final data = e.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          errorMessage = firstError is List ? firstError[0] : firstError.toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
      }
    } else if (e.type == DioExceptionType.connectionError ||
               e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Network error. Please check your connection.';
    }

    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: errorMessage,
      isLoading: false,
    );
    return false;
  } catch (e) {
    debugPrint('Register error: $e');
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'An unexpected error occurred',
      isLoading: false,
    );
    return false;
  }
}
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _logoutUseCase();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  // Set authenticated directly (useful for testing or manual state management)
  void setAuthenticated(UserEntity user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
    );
  }
  
  void setUnauthenticated() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    checkAuthStatusUseCase: ref.watch(checkAuthStatusUseCaseProvider),
  );
});

// Convenience Providers
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});