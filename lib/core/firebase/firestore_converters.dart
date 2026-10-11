import 'package:cloud_firestore/cloud_firestore.dart';

/// Safe Firestore value conversions.
///
/// Existing `Model.fromJson` implementations assume plain JSON (`String`,
/// `num`, `List`). Firestore returns [Timestamp] for dates and may return
/// `int` where the model expects `double`. These helpers make every
/// `fromFirestore` conversion null-safe and Timestamp-aware without
/// rewriting UI code.
class FirestoreConverters {
  FirestoreConverters._();

  /// Reads a Firestore date field (`Timestamp`, `DateTime`, ISO `String`,
  /// or millis `num`) into a nullable [DateTime].
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }
    return null;
  }

  /// Non-null variant; falls back to Unix epoch so callers never crash.
  static DateTime toDateTimeOrEpoch(dynamic value) {
    return toDateTime(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double toDouble(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static int toInt(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    if (value is bool) return value ? 1 : 0;
    return fallback;
  }

  static String toStr(dynamic value, [String fallback = '']) {
    if (value is String) return value;
    if (value == null) return fallback;
    return value.toString();
  }

  static bool toBool(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes') return true;
      if (v == 'false' || v == '0' || v == 'no') return false;
    }
    return fallback;
  }

  static List<String> toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static List<Map<String, dynamic>> toMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  /// GeoPoint -> (lat, lng) pair; falls back to separate `latitude` /
  /// `longitude` numeric fields; defaults to (0, 0) so map code never crashes.
  static ({double lat, double lng}) toLatLng(Map<String, dynamic> map) {
    final geo = map['geo'];
    if (geo is GeoPoint) return (lat: geo.latitude, lng: geo.longitude);
    final lat = toDouble(map['latitude'] ?? map['lat'], 0);
    final lng = toDouble(map['longitude'] ?? map['lng'], 0);
    return (lat: lat, lng: lng);
  }

  /// Server timestamp marker for writes.
  static FieldValue serverNow() => FieldValue.serverTimestamp();
}
