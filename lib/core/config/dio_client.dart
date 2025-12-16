// lib/core/config/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_constants.dart';
import '../services/secure_storage_service.dart';
import 'router.dart';

// Provider for signaling when to logout
final authLogoutSignalProvider = StateProvider<int>((ref) => 0);

// Provider for the raw Dio instance (with auth interceptor)
final dioProvider = Provider<Dio>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return dioClient.dio;
});

// Provider for DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return DioClient(
    secureStorage: secureStorage,
    navigatorKey: rootNavigatorKey,
    ref: ref,
  );
});

class DioClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;
  final GlobalKey<NavigatorState> _navigatorKey;
  final Ref _ref;

  DioClient({
    required SecureStorageService secureStorage,
    required GlobalKey<NavigatorState> navigatorKey,
    required Ref ref,
  })  : _secureStorage = secureStorage,
        _navigatorKey = navigatorKey,
        _ref = ref {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        secureStorage: _secureStorage,
        dio: _dio,
        navigatorKey: _navigatorKey,
        ref: _ref,
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    ]);
  }

  Dio get dio => _dio;

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final GlobalKey<NavigatorState> _navigatorKey;
  final Ref _ref;
  bool _isRefreshing = false;

  AuthInterceptor({
    required SecureStorageService secureStorage,
    required Dio dio,
    required GlobalKey<NavigatorState> navigatorKey,
    required Ref ref,
  })  : _secureStorage = secureStorage,
        _dio = dio,
        _navigatorKey = navigatorKey,
        _ref = ref;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login and register endpoints
    final skipAuthPaths = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.forgotPassword,
      '/auth/login',
      '/auth/register',
      '/login',
      '/register',
    ];

    final shouldSkip = skipAuthPaths.any((path) => 
      options.path.contains(path) || options.path.endsWith(path)
    );

    if (!shouldSkip) {
      final token = await _secureStorage.getAccessToken();
      debugPrint('AuthInterceptor: Token for ${options.path}: ${token != null ? 'EXISTS' : 'NULL'}');
      
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('AuthInterceptor: Added Authorization header');
      }
    } else {
      debugPrint('AuthInterceptor: Skipping auth for ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('AuthInterceptor: Error ${err.response?.statusCode} for ${err.requestOptions.path}');

    // Handle 401 Unauthorized or 403 Forbidden (unauthenticated/unauthorized)
    if ((err.response?.statusCode == 401 || err.response?.statusCode == 403) && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await _secureStorage.getRefreshToken();

        if (refreshToken != null) {
          debugPrint('AuthInterceptor: Attempting token refresh...');

          // Try to refresh the token
          final response = await _dio.post(
            ApiEndpoints.refreshToken,
            data: {'refresh_token': refreshToken},
            options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'},
            ),
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'] ?? response.data['token'];
            final newRefreshToken = response.data['refresh_token'];

            await _secureStorage.saveAccessToken(newAccessToken);
            if (newRefreshToken != null) {
              await _secureStorage.saveRefreshToken(newRefreshToken);
            }

            debugPrint('AuthInterceptor: Token refreshed successfully');

            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          }
        }

        // If refresh fails, clear auth data and navigate to login
        debugPrint('AuthInterceptor: Refresh failed, clearing auth data and navigating to login');
        await _secureStorage.clearAllAuthData();
        _isRefreshing = false;

        // Navigate to login screen
        _navigateToLogin();

        handler.next(err);
      } catch (e) {
        debugPrint('AuthInterceptor: Refresh error: $e');
        _isRefreshing = false;
        await _secureStorage.clearAllAuthData();

        // Navigate to login screen on refresh error
        _navigateToLogin();

        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  /// Navigate to login screen and clear navigation stack
  void _navigateToLogin() {
    // Increment logout signal to trigger auth state update
    _ref.read(authLogoutSignalProvider.notifier).state++;

    // Use WidgetsBinding to ensure navigation happens after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context != null && context.mounted) {
        // Clear the navigation stack and go to login
        context.go('/login');
        debugPrint('AuthInterceptor: Navigated to login screen');
      }
    });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}