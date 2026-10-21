// Formats a moment the way the guide screens display it.
//
// One formatter for the whole app: the mock dataset and the live trips
// produce the same labels for the same timestamps.

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// '5:00 PM'
String formatClock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
}

/// 'October'
String formatMonthName(DateTime value) => _months[value.month - 1];

/// Whole days between today's midnight and [value]'s midnight.
/// Negative in the past, 0 today, 1 tomorrow.
int daysFromToday(DateTime value, {DateTime? now}) {
  final anchor = now ?? DateTime.now();
  final today = DateTime(anchor.year, anchor.month, anchor.day);
  final day = DateTime(value.year, value.month, value.day);
  return day.difference(today).inDays;
}

/// 'Today' / 'Tomorrow' / 'Oct 28'
String formatShortDate(DateTime value, {DateTime? now}) {
  final diff = daysFromToday(value, now: now);
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  return '${formatMonthName(value)} ${value.day}';
}

/// 'Today, 5:00 PM' / 'Tomorrow, 10:00 AM' / 'Nov 12, 2026 · 7:00 AM'
String formatScheduleLabel(DateTime value, {DateTime? now}) {
  final diff = daysFromToday(value, now: now);
  final clock = formatClock(value);
  if (diff == 0) return 'Today, $clock';
  if (diff == 1) return 'Tomorrow, $clock';
  return '${formatMonthName(value)} ${value.day}, ${value.year} · $clock';
}

/// 'Today · 5:00 PM' / 'Oct 28 · 10:00 AM'
String formatDateTimeLabel(DateTime value, {DateTime? now}) =>
    '${formatShortDate(value, now: now)} · ${formatClock(value)}';
