// lib/core/services/navigation_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to login screen and clear the navigation stack
  void navigateToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  /// Navigate to a specific route
  void navigateTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Go back
  void goBack() {
    navigatorKey.currentState?.pop();
  }
}
