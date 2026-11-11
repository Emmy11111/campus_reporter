import 'package:intl/intl.dart';

class Formatters {
  static String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    return DateFormat('MMM d, y').format(date);
  }

  static String fullDate(DateTime date) =>
      DateFormat("MMM d, y 'at' h:mm a").format(date);

  static String shortDate(DateTime date) =>
      DateFormat('MMM d, h:mm a').format(date);
}