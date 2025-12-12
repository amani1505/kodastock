
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kodastock/domain/repositories/auth_repository_impl.dart';
import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/login_request_model.dart';
import '../../data/models/auth/signup_request_model.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// Login Use Case
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthResponseModel> call(LoginRequestModel request) {
    return _repository.login(request);
  }
}

// Register Use Case
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<AuthResponseModel> call(SignupRequestModel request) {
    return _repository.register(request);
  }
}

// Logout Use Case
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}

// Get Current User Use Case
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<UserEntity?> call() {
    return _repository.getCurrentUser();
  }
}

// Check Auth Status Use Case
final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
});

class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  Future<bool> call() {
    return _repository.isLoggedIn();
  }
}

// Forgot Password Use Case
final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ForgotPasswordUseCase(repository);
});

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.forgotPassword(email);
  }
}