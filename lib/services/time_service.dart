import 'package:ntp/ntp.dart';

class TimeService {
  // Singleton
  static final TimeService _instance = TimeService._internal();
  factory TimeService() => _instance;
  TimeService._internal();

  /// Returns the "True" time (NTP) if available, otherwise device time.
  Future<DateTime> now() async {
    try {
      // 2-second timeout to avoid UI lag if network is bad
      return await NTP.now(timeout: const Duration(seconds: 2));
    } catch (_) {
      // Fallback to device time
      return DateTime.now();
    }
  }

  /// Calculates the next monthly occurrence safely (handles #29, #30, #31).
  /// [current]: The reference date.
  /// [interval]: Number of months to add.
  DateTime nextMonthlyDate(DateTime current, int interval) {
    // Current year/month/day
    int year = current.year;
    int month = current.month;
    int day = current.day;

    // Add interval to month (standard logic first)
    // DateTime handles year overflow automatically if month > 12?
    // standard DateTime(year, month + interval, day) will overflow dates:
    // e.g. Jan 31 + 1 month -> Feb 31 -> Normalized to March 3 (or 2) in Dart.
    // We WANT it to snap to Feb 28/29.

    // 1. Calculate target year/month
    int targetMonth = month + interval;
    int targetYear = year;

    // Normalize month/year manually to know exactly what month we want
    while (targetMonth > 12) {
      targetMonth -= 12;
      targetYear++;
    }
    while (targetMonth < 1) {
      // Should not happen with positive interval but safety
      targetMonth += 12;
      targetYear--;
    }

    // 2. Determine max days in target month
    int maxDays = _daysInMonth(targetYear, targetMonth);

    // 3. Clamp day
    int targetDay = day;
    if (day > maxDays) {
      targetDay = maxDays;
    }

    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
      current.hour,
      current.minute,
    );
  }

  int _daysInMonth(int year, int month) {
    // Dart DateTime(year, month + 1, 0) gives the last day of 'month'.
    return DateTime(year, month + 1, 0).day;
  }
}
