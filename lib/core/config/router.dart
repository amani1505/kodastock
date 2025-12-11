import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/bottom_nav/main_shell.dart';
import '../../presentation/screens/home/dashboard_screen.dart';
import '../../presentation/screens/home/stocks_screen.dart';
import '../../presentation/screens/home/compare_screen.dart';
import '../../presentation/screens/home/analysis_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/stocks',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const StocksScreen(),
            ),
          ),
          GoRoute(
            path: '/compare',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CompareScreen(),
            ),
          ),
          GoRoute(
            path: '/analysis',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AnalysisScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
