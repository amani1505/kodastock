// lib/core/services/secure_storage_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants/app_constants.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token Management
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: AppConstants.accessTokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving access token: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: AppConstants.refreshTokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      debugPrint('Error getting refresh token: $e');
      return null;
    }
  }

  Future<void> deleteTokens() async {
    try {
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      debugPrint('Error deleting tokens: $e');
    }
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _storage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(userData),
      );
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = await _storage.read(key: AppConstants.userDataKey);
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }

  // Login State
  Future<void> setLoggedIn(bool value) async {
    try {
      await _storage.write(
        key: AppConstants.isLoggedInKey,
        value: value.toString(),
      );
    } catch (e) {
      debugPrint('Error setting logged in: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final value = await _storage.read(key: AppConstants.isLoggedInKey);
      return value == 'true';
    } catch (e) {
      debugPrint('Error checking logged in: $e');
      return false;
    }
  }

  // Clear All Auth Data
  Future<void> clearAllAuthData() async {
    try {
      await deleteTokens();
      await deleteUserData();
      await setLoggedIn(false);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  // Generic Methods
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error writing $key: $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('Error reading $key: $e');
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting $key: $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error deleting all: $e');
    }
  }
}