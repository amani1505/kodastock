import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/config/theme/theme_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Dummy notifications data - replace with real API call later
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Stock Alert',
      'message': 'TBL stock price increased by 5.2%',
      'time': '2 hours ago',
      'type': 'price_alert',
      'isRead': false,
    },
    {
      'id': 2,
      'title': 'Market Update',
      'message': 'DSE market closed with positive gains',
      'time': '5 hours ago',
      'type': 'market_update',
      'isRead': false,
    },
    {
      'id': 3,
      'title': 'Analysis Ready',
      'message': 'Your stock analysis for CRDB is ready',
      'time': '1 day ago',
      'type': 'analysis',
      'isRead': true,
    },
    {
      'id': 4,
      'title': 'Watchlist Alert',
      'message': 'NMB stock reached your target price',
      'time': '2 days ago',
      'type': 'watchlist',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          // Mark all as read
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(context, notification, index);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: context.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    Map<String, dynamic> notification,
    int index,
  ) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _notifications.insert(index, notification);
                });
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => _markAsRead(index),
        child: Container(
          color: isRead
              ? null
              : context.colorScheme.primary.withValues(alpha: 0.05),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(type).withValues(alpha: 0.1),
              child: Icon(
                _getNotificationIcon(type),
                color: _getNotificationColor(type),
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    notification['title'] as String,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification['message'] as String,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['time'] as String,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showNotificationOptions(context, index),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'price_alert':
        return Icons.trending_up;
      case 'market_update':
        return Icons.bar_chart;
      case 'analysis':
        return Icons.analytics;
      case 'watchlist':
        return Icons.bookmark;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'price_alert':
        return Colors.green;
      case 'market_update':
        return Colors.blue;
      case 'analysis':
        return Colors.purple;
      case 'watchlist':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _showNotificationOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Mark as read'),
              onTap: () {
                Navigator.pop(context);
                _markAsRead(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                final notification = _notifications[index];
                setState(() {
                  _notifications.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Notification deleted'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        setState(() {
                          _notifications.insert(index, notification);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
