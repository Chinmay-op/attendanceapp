import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return formatDateTime(dt);
    } catch (_) {
      return iso;
    }
  }

  static String todayDate() {
    return formatDate(DateTime.now());
  }

  static String currentTimestamp() {
    return DateTime.now().toIso8601String();
  }

  static double attendancePercentage(int present, int total) {
    if (total == 0) return 0.0;
    return (present / total) * 100;
  }

  static String percentageText(double pct) {
    return '${pct.toStringAsFixed(1)}%';
  }

  static String greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String durationText(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    }
    return '${d.inSeconds}s';
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static List<DateTime> getMonthDays(int year, int month) {
    final days = <DateTime>[];
    final totalDays = daysInMonth(year, month);
    for (int i = 1; i <= totalDays; i++) {
      days.add(DateTime(year, month, i));
    }
    return days;
  }
}
