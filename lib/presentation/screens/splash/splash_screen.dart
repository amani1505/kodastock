// lib/presentation/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Use addPostFrameCallback to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialRoute();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkInitialRoute() async {
    try {
      // Wait for animation to complete
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check onboarding status
      final prefs = await SharedPreferences.getInstance();
      final isOnboardingCompleted = 
          prefs.getBool(AppConstants.isOnboardingCompleted) ?? false;

      if (!mounted) return;

      if (!isOnboardingCompleted) {
        debugPrint('Navigating to onboarding...');
        context.go('/onboarding');
        return;
      }

      // Check authentication status
      debugPrint('Checking auth status...');
      await ref.read(authProvider.notifier).checkAuthStatus();

      if (!mounted) return;

      final authState = ref.read(authProvider);
      debugPrint('Auth status: ${authState.status}');

      if (authState.status == AuthStatus.authenticated) {
        debugPrint('Navigating to dashboard...');
        context.go('/dashboard');
      } else {
        debugPrint('Navigating to login...');
        context.go('/login');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in splash screen: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      // On error, navigate to login
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.show_chart,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Smart Stock Analysis',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}