import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../../core/config/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'components/auth_text_field.dart';
import 'components/auth_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.errorEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorPasswordRequired;
    }
    if (value.length < 6) {
      return AppStrings.errorPasswordTooShort;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top - 48,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo or App Name
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          ref.watch(isDarkModeProvider)
                              ? 'assets/images/white_logo.png'
                              : 'assets/images/black_logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Welcome Text
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue to your account',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Error Message
                  if (authState.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Email Field
                  AuthTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    enabled: !authState.isLoading,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  AuthTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    label: AppStrings.password,
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outlined,
                    isPassword: true,
                    validator: _validatePassword,
                    enabled: !authState.isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Remember Me & Forgot Password Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: authState.isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                          ),
                          Text(
                            'Remember me',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                // Navigate to forgot password
                                context.push('/forgot-password');
                              },
                        child: Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login Button
                  AuthButton(
                    text: AppStrings.login,
                    onPressed: _handleLogin,
                    isLoading: authState.isLoading,
                  ),
                  
                  const Spacer(),
                  
                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.go('/signup'),
                          child: Text(
                            AppStrings.signUp,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}