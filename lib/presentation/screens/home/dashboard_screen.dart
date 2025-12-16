import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/config/theme/theme_provider.dart';
import '../../providers/app_providers.dart';
import 'components/quick_action_card.dart';
import 'components/market_overview_item.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/white_logo.png',
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text('KodaStock'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push('/notifications');
            },
          ),
          // Theme toggle button
          IconButton(
            icon: Icon(
              ref.watch(isDarkModeProvider)
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          // Profile icon - clickable
          InkWell(
            onTap: () {
              context.push('/profile');
            },
            borderRadius: BorderRadius.circular(20),
            child: userAsync.when(
              data: (user) {
                // Get initials from user name
                final nameParts = user.name.split(' ');
                final initials = nameParts.length > 1
                    ? '${nameParts[0][0]}${nameParts[1][0]}'
                    : nameParts[0].substring(0, 2);

                return CircleAvatar(
                  radius: 16,
                  backgroundColor: context.colorScheme.primary,
                  child: Text(
                    initials.toUpperCase(),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                );
              },
              loading: () => CircleAvatar(
                radius: 16,
                backgroundColor: context.colorScheme.primary,
              ),
              error: (_, __) => CircleAvatar(
                radius: 16,
                backgroundColor: context.colorScheme.primary,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.invalidate(userProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(context, ref, dashboard),
                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsCards(context, dashboard),
                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // Market Summary
                _buildMarketSummary(context, dashboard),
                const SizedBox(height: 24),

                // Market Overview
                _buildMarketOverview(context, dashboard),
                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivity(context, dashboard),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load dashboard',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, WidgetRef ref, dynamic dashboard) {
    final userAsync = ref.watch(userProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userAsync.when(
          data: (user) {
            // Get first name from full name
            final firstName = user.name.split(' ').first;
            return Text(
              'Welcome back, $firstName! 👋',
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
          loading: () => Text(
            'Welcome back! 👋',
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          error: (_, __) => Text(
            'Welcome back! 👋',
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Here's what's happening with your investments today.",
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              _formatDate(DateTime.now()),
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Market Closed',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, $monthName ${date.day}, ${date.year}';
  }

  Widget _buildStatsCards(BuildContext context, dynamic dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.business,
            title: 'Total Stocks',
            value: '${dashboard.totalStocks}',
            subtitle: 'DSE Listed Companies',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.bookmark_border,
            title: 'Watchlist',
            value: '${dashboard.watchlistCount}',
            subtitle: 'Stocks Tracking',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.show_chart,
                label: 'All Stocks',
                color: Colors.blue,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.compare_arrows,
                label: 'Compare',
                color: Colors.purple,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.bookmark_border,
                label: 'Watchlist',
                color: Colors.green,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.lightbulb_outline,
                label: 'Analysis',
                color: Colors.amber,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketSummary(BuildContext context, dynamic dashboard) {
    final marketSummary = dashboard.marketSummary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Summary',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'DSE Index',
              marketSummary != null
                  ? marketSummary.dseIndex.toStringAsFixed(2)
                  : '0.00',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              'Market Cap',
              marketSummary != null
                  ? '${marketSummary.marketCap.toStringAsFixed(2)} TZS'
                  : '0.00 TZS',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              'Total Volume',
              marketSummary != null
                  ? '${marketSummary.totalVolume.toStringAsFixed(1)}K'
                  : '0.0K',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryRow(
                    context,
                    'Gainers',
                    marketSummary != null ? '${marketSummary.gainers}' : '0',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryRow(
                    context,
                    'Losers',
                    marketSummary != null ? '${marketSummary.losers}' : '0',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketOverview(BuildContext context, dynamic dashboard) {
    final marketOverview = dashboard.marketOverview ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Market Overview',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('View All →'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildOverviewHeader(context),
              if (marketOverview.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No stocks available',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                )
              else
                ...marketOverview.asMap().entries.map((entry) {
                  final stock = entry.value;
                  return Column(
                    children: [
                      if (entry.key > 0) Divider(height: 1),
                      MarketOverviewItem(
                        symbol: stock.symbol,
                        name: stock.name,
                        price: stock.currentPrice,
                        change: stock.changePercent,
                        volume: stock.volume,
                      ),
                    ],
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'SYMBOL',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'PRICE',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              'CHANGE',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              'VOLUME',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, dynamic dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: context.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent activity',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
