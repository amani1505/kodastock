import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/config/theme/theme_provider.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, user),
              const SizedBox(height: 32),

              // Account Information Section
              _buildSection(
                context,
                title: 'Account Information',
                children: [
                  _buildInfoTile(
                    context,
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: user.name,
                  ),
                  _buildInfoTile(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  _buildInfoTile(
                    context,
                    icon: Icons.verified_user_outlined,
                    label: 'Account Status',
                    value: user.isVerified ? 'Verified' : 'Not Verified',
                    valueColor: user.isVerified
                      ? const Color(AppColors.successColor)
                      : const Color(AppColors.warningColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Settings Section
              _buildSection(
                context,
                title: 'Settings',
                children: [
                  _buildSettingTile(
                    context,
                    icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    title: 'Theme',
                    subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (_) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.security_outlined,
                    title: 'Security',
                    subtitle: 'Change password & security settings',
                    onTap: () {
                      // TODO: Navigate to security settings
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // App Information Section
              _buildSection(
                context,
                title: 'App Information',
                children: [
                  _buildInfoTile(
                    context,
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: AppConstants.appVersion,
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      // TODO: Navigate to terms
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      // TODO: Navigate to privacy policy
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Logout Button
              _buildLogoutButton(context, ref),
              const SizedBox(height: 32),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final nameParts = user.name.split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : nameParts[0].substring(0, 2);

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: context.colorScheme.primary,
          child: Text(
            initials.toUpperCase(),
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: context.colorScheme.primary,
      ),
      title: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      subtitle: Text(
        value,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: valueColor,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: context.colorScheme.primary,
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.errorColor),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              context.go('/login');
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.errorColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
