// lib/data/repositories/auth_repository_impl.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kodastock/data/models/auth/auth_response_model.dart';
import 'package:kodastock/data/models/auth/login_request_model.dart';
import 'package:kodastock/data/models/auth/signup_request_model.dart';
import 'package:kodastock/data/models/auth/user_model.dart';
import '../../core/config/dio_client.dart';
import '../../core/config/constants/app_constants.dart';
import '../../core/services/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';



final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(
    dioClient: dioClient,
    secureStorage: secureStorage,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required DioClient dioClient,
    required SecureStorageService secureStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      debugPrint('Raw login response: ${response.data}');
      
      final authResponse = AuthResponseModel.fromJson(response.data);
      debugPrint('Parsed auth response: token=${authResponse.accessToken != null}');

      // Check if we have a token (indicates success)
      if (authResponse.accessToken != null && authResponse.accessToken!.isNotEmpty) {
        await _secureStorage.saveAccessToken(authResponse.accessToken!);
        debugPrint('Token saved successfully');
        
        if (authResponse.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResponse.refreshToken!);
        }
        
        if (authResponse.user != null) {
          await _secureStorage.saveUserData(authResponse.user!.toJson());
          debugPrint('User data saved: ${authResponse.user!.email}');
        }
        
        await _secureStorage.setLoggedIn(true);
      }

      return authResponse;
    } catch (e, stackTrace) {
      debugPrint('Login error in repository: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> register(SignupRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      debugPrint('Raw register response: ${response.data}');
      
      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.accessToken != null && authResponse.accessToken!.isNotEmpty) {
        await _secureStorage.saveAccessToken(authResponse.accessToken!);
        
        if (authResponse.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResponse.refreshToken!);
        }
        
        if (authResponse.user != null) {
          await _secureStorage.saveUserData(authResponse.user!.toJson());
        }
        
        await _secureStorage.setLoggedIn(true);
      }

      return authResponse;
    } catch (e, stackTrace) {
      debugPrint('Register error in repository: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        await _dioClient.post(ApiEndpoints.logout);
      }
    } catch (e) {
      debugPrint('Logout API error (continuing with local logout): $e');
    } finally {
      await _secureStorage.clearAllAuthData();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final localUserData = await _secureStorage.getUserData();
      if (localUserData != null) {
        debugPrint('Got user from local storage');
        return UserModel.fromJson(localUserData).toEntity();
      }

      debugPrint('Fetching user from API...');
      final response = await _dioClient.get(ApiEndpoints.profile);
      final userData = response.data['user'] ?? response.data;
      final userModel = UserModel.fromJson(userData);
      await _secureStorage.saveUserData(userModel.toJson());
      return userModel.toEntity();
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedInFlag = await _secureStorage.isLoggedIn();
      final token = await _secureStorage.getAccessToken();
      
      debugPrint('isLoggedIn check: flag=$isLoggedInFlag, hasToken=${token != null}');
      
      return isLoggedInFlag && token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking isLoggedIn: $e');
      return false;
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] ?? response.data['token'];
      final newRefreshToken = response.data['refresh_token'];

      if (newAccessToken != null) {
        await _secureStorage.saveAccessToken(newAccessToken);
      }
      if (newRefreshToken != null) {
        await _secureStorage.saveRefreshToken(newRefreshToken);
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await _secureStorage.clearAllAuthData();
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dioClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}