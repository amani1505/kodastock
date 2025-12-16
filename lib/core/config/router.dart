
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/bottom_nav/main_shell.dart';
import '../../presentation/screens/home/dashboard_screen.dart';
import '../../presentation/screens/home/stocks_screen.dart';
import '../../presentation/screens/home/compare_screen.dart';
import '../../presentation/screens/home/analysis_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import 'dio_client.dart';

// Global navigator key for interceptor navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Simple auth state provider for routing decisions
final isAuthenticatedProvider = Provider<bool>((ref) {
  // Watch the logout signal to trigger re-evaluation
  ref.watch(authLogoutSignalProvider);

  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  // Watch logout signal and update auth state when it changes
  ref.listen<int>(authLogoutSignalProvider, (previous, next) {
    if (previous != null && previous != next) {
      // Signal changed, meaning interceptor cleared auth data
      ref.read(authProvider.notifier).setUnauthenticated();
    }
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,

    // Redirect logic - simplified
    redirect: (context, state) {
      // Watch logout signal to trigger redirect re-evaluation
      ref.read(authLogoutSignalProvider);

      final authState = ref.read(authProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final currentPath = state.matchedLocation;
      
      // Define public routes (no auth required)
      final publicRoutes = ['/', '/onboarding', '/login', '/signup'];
      final isPublicRoute = publicRoutes.contains(currentPath);
      
      // Define auth routes
      final authRoutes = ['/login', '/signup'];
      final isAuthRoute = authRoutes.contains(currentPath);
      
      // Allow splash and onboarding always
      if (currentPath == '/' || currentPath == '/onboarding') {
        return null;
      }
      
      // If authenticated and trying to access auth routes, go to dashboard
      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }
      
      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }
      
      return null;
    },
    
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Profile Route (Protected, but outside shell)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Notifications Route (Protected, but outside shell)
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Protected Routes (Dashboard Shell)
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/stocks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StocksScreen(),
            ),
          ),
          GoRoute(
            path: '/compare',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CompareScreen(),
            ),
          ),
          GoRoute(
            path: '/analysis',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalysisScreen(),
            ),
          ),
        ],
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Path: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});