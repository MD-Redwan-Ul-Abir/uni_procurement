import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Shared formatters for dates, currency, and file sizes.
class Formatters {
  Formatters._();

  /// Format date: "07 Sep 2026"
  static String date(DateTime dateTime) {
    return DateFormat(AppConstants.dateFormat).format(dateTime);
  }

  /// Format datetime: "07 Sep 2026, 01:30 PM"
  static String dateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Format currency: "৳ 1,25,000.00"
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '${AppConstants.currencySymbol} ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format compact currency: "৳ 1.25L"
  static String currencyCompact(double amount) {
    if (amount >= 100000) {
      return '${AppConstants.currencySymbol} ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${AppConstants.currencySymbol} ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount);
  }

  /// Format file size: "2.5 MB"
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Format countdown: "2d 5h 30m"
  static String countdown(Duration duration) {
    if (duration.isNegative) return 'Expired';
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inSeconds}s';
  }

  /// Relative time: "2 hours ago", "3 days ago"
  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
