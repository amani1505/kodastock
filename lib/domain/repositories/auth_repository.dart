// lib/domain/repositories/auth_repository.dart

import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/login_request_model.dart';
import '../../data/models/auth/signup_request_model.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(SignupRequestModel request);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> refreshToken();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });
}