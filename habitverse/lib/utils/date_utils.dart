import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTimeFormat = DateFormat('h:mm a');

  // Format date to string
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Format time to string
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  // Format datetime to string
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Format date for display
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  // Format time for display
  static String formatDisplayTime(DateTime time) {
    return _displayTimeFormat.format(time);
  }

  // Parse date from string
  static DateTime parseDate(String dateString) {
    return _dateFormat.parse(dateString);
  }

  // Parse datetime from string
  static DateTime parseDateTime(String dateTimeString) {
    return _dateTimeFormat.parse(dateTimeString);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return to.difference(from).inDays;
  }

  // Get week start (Monday)
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  // Get week end (Sunday)
  static DateTime getWeekEnd(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekday)));
  }

  // Get month start
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get month end
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Get relative time string
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      }
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 
          ? '1 hour ago' 
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 
          ? '1 minute ago' 
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Get days in month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // Get week days
  static List<DateTime> getWeekDays(DateTime date) {
    final weekStart = getWeekStart(date);
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  // Get month days
  static List<DateTime> getMonthDays(DateTime date) {
    final monthStart = getMonthStart(date);
    final daysInMonth = getDaysInMonth(date.year, date.month);
    return List.generate(
      daysInMonth, 
      (index) => monthStart.add(Duration(days: index))
    );
  }
}
