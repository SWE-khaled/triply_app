const List<String> _weekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

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

/// A short time for the chat list: the clock today, "Yesterday", the
/// weekday inside the last week, then the date.
String chatTimeLabel(DateTime? at, {DateTime? now}) {
  if (at == null) return '';
  final local = at.toLocal();
  final reference = (now ?? DateTime.now()).toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(reference.year, reference.month, reference.day);
  final difference = today.difference(day).inDays;
  if (difference == 0) return chatClockLabel(local);
  if (difference == 1) return 'Yesterday';
  if (difference > 1 && difference < 7) {
    return _weekdays[local.weekday - 1];
  }
  return '${_months[local.month - 1]} ${local.day}';
}

/// The separator between messages of different days.
String chatDayLabel(DateTime at, {DateTime? now}) {
  final local = at.toLocal();
  final reference = (now ?? DateTime.now()).toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(reference.year, reference.month, reference.day);
  final difference = today.difference(day).inDays;
  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  if (local.year == reference.year) {
    return '${_months[local.month - 1]} ${local.day}';
  }
  return '${_months[local.month - 1]} ${local.day}, ${local.year}';
}

/// The time inside a message bubble, e.g. `9:41 PM`.
String chatClockLabel(DateTime at) {
  final local = at.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}
