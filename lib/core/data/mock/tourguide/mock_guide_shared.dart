import '../../../helper/price_format.dart';
import '../../../helper/schedule_format.dart';

/// Shared helpers for the tour-guide mock dataset.
///
/// Every mock file derives its labels through these helpers, so the
/// dataset stays internally consistent: one date always produces one
/// label, and one price always produces one amount. The same maps can
/// later be seeded into Firestore as-is.
///
/// The whole dataset is anchored to a single [mockNow] captured the
/// first time this library is loaded, so every derived value inside one
/// session agrees with every other one.

/// The single "now" every mock record is positioned around.
final DateTime mockNow = DateTime.now();

/// A moment [days] from today at [hour]:[minute] (local time).
/// A negative [days] is in the past.
DateTime mockAt(int days, int hour, int minute) {
  final base = DateTime(
    mockNow.year,
    mockNow.month,
    mockNow.day,
  ).add(Duration(days: days));
  return DateTime(base.year, base.month, base.day, hour, minute);
}

/// ISO-8601 timestamp — JSON-safe and directly convertible to a
/// Firestore `Timestamp` by the repository layer.
String mockIso(DateTime value) => value.toIso8601String();

/// Whole days between today's midnight and [value]'s midnight.
/// Negative in the past, 0 today, 1 tomorrow.
int mockDaysFromToday(DateTime value) => daysFromToday(value, now: mockNow);

/// '5:00 PM'
String mockClock(DateTime value) => formatClock(value);

/// 'October'
String mockMonthName(DateTime value) => formatMonthName(value);

/// 'Today' / 'Tomorrow' / 'Oct 28'
String mockShortDate(DateTime value) => formatShortDate(value, now: mockNow);

/// 'Today, 5:00 PM' / 'Tomorrow, 10:00 AM' / 'Nov 12, 2026 · 7:00 AM'
String mockScheduleLabel(DateTime value) =>
    formatScheduleLabel(value, now: mockNow);

/// 'Today · 5:00 PM' / 'Oct 28 · 10:00 AM'
String mockDateTimeLabel(DateTime value) =>
    formatDateTimeLabel(value, now: mockNow);

/// 'EGP 3,750'
String mockEgpLabel(double amount) => 'EGP ${formatEgp(amount)}';

/// '7,900' — amount without a currency prefix, for stat cards whose
/// width cannot fit 'EGP 7,900'.
String mockAmountLabel(double amount) => formatEgp(amount);

/// '1 traveler' / '3 travelers'
String mockTravelerLabel(int count) =>
    '$count ${count == 1 ? 'traveler' : 'travelers'}';
