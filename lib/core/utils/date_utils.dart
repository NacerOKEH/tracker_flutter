import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'fr');
  static final DateFormat _shortMonth = DateFormat('MMM', 'fr');

  static String formatDate(DateTime date) => _displayFormat.format(date);

  static String formatMonth(DateTime date) => _monthFormat.format(date);

  static String formatShortMonth(DateTime date) => _shortMonth.format(date);

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  static List<DateTime> lastSixMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
  }
}
