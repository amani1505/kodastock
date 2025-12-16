import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../../core/config/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'components/auth_text_field.dart';
import 'components/auth_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorNameRequired;
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return AppStrings.errorPasswordMismatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    ref.watch(isDarkModeProvider)
                        ? 'assets/images/white_logo.png'
                        : 'assets/images/black_logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),

                // Header
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in your details to get started',
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
                
                // Name Field
                AuthTextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  label: AppStrings.fullName,
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outlined,
                  keyboardType: TextInputType.name,
                  validator: _validateName,
                  enabled: !authState.isLoading,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                ),
                
                const SizedBox(height: 16),
                
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
                  hint: 'Create a password',
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  validator: _validatePassword,
                  enabled: !authState.isLoading,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                AuthTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  label: AppStrings.confirmPassword,
                  hint: 'Confirm your password',
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  validator: _validateConfirmPassword,
                  enabled: !authState.isLoading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignup(),
                ),
                
                const SizedBox(height: 16),
                
                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: authState.isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Signup Button
                AuthButton(
                  text: AppStrings.signUp,
                  onPressed: _handleSignup,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => context.go('/login'),
                        child: Text(
                          AppStrings.login,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}