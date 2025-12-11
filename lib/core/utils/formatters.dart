import 'package:intl/intl.dart';

class Formatters {
  // Currency formatter for TZS
  static String formatCurrency(double amount, {String symbol = 'TZS'}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: amount >= 1000 ? 0 : 2,
    );
    return '${formatter.format(amount)} $symbol';
  }

  // Compact number formatter (e.g., 1.2K, 3.4M)
  static String formatCompactNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  // Percentage formatter
  static String formatPercentage(double percentage, {int decimals = 2}) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(decimals)}%';
  }

  // Volume formatter
  static String formatVolume(double volume) {
    return formatCompactNumber(volume);
  }

  // Date formatter
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Time ago formatter
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Market cap formatter
  static String formatMarketCap(double marketCap) {
    return formatCompactNumber(marketCap);
  }

  // Number with commas
  static String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
