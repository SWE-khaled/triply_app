import 'package:cloud_firestore/cloud_firestore.dart';

/// Small, tolerant readers shared by the chat models.
///
/// Firestore documents written by older clients (or by hand in the
/// Console) can miss fields entirely, or carry a value of the wrong
/// type. The models never crash on those documents: every reader falls
/// back to an empty value.
String chatString(Object? value) => value is String ? value : '';

int chatInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

Map<String, dynamic> chatMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return const <String, dynamic>{};
}

DateTime? chatDateTime(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return null;
}

Timestamp? chatTimestamp(DateTime? value) =>
    value == null ? null : Timestamp.fromDate(value);
