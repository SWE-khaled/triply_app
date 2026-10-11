import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

void main() {
  group('toDateTime', () {
    test('reads Timestamp', () {
      final utc = DateTime.utc(2026, 10, 9, 12);
      final ts = Timestamp.fromDate(utc);
      // Timestamp.toDate() returns local time — compare instants.
      expect(
        FirestoreConverters.toDateTime(ts)?.millisecondsSinceEpoch,
        utc.millisecondsSinceEpoch,
      );
    });

    test('reads DateTime, ISO string, and millis as-is', () {
      final dt = DateTime.utc(2026, 1, 2, 3, 4, 5);
      expect(FirestoreConverters.toDateTime(dt), dt);
      expect(
        FirestoreConverters.toDateTime('2026-01-02T03:04:05.000Z'),
        DateTime.utc(2026, 1, 2, 3, 4, 5),
      );
      expect(
        FirestoreConverters.toDateTime(dt.millisecondsSinceEpoch),
        dt,
      );
    });

    test('returns null for null/empty/garbage, epoch for non-null variant', () {
      expect(FirestoreConverters.toDateTime(null), isNull);
      expect(FirestoreConverters.toDateTime(''), isNull);
      expect(FirestoreConverters.toDateTime('  '), isNull);
      expect(FirestoreConverters.toDateTime('not-a-date'), isNull);
      expect(FirestoreConverters.toDateTime(123.45 is int ? 1 : null), isNull);
      expect(
        FirestoreConverters.toDateTimeOrEpoch(null),
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    });
  });

  group('numbers and strings', () {
    test('toDouble handles int/double/numeric-string', () {
      expect(FirestoreConverters.toDouble(5), 5.0);
      expect(FirestoreConverters.toDouble(5.5), 5.5);
      expect(FirestoreConverters.toDouble('12.5'), 12.5);
      expect(FirestoreConverters.toDouble('bad', 1.5), 1.5);
      expect(FirestoreConverters.toDouble(null), 0);
    });

    test('toInt handles num/string/bool', () {
      expect(FirestoreConverters.toInt(5.9), 5);
      expect(FirestoreConverters.toInt('7'), 7);
      expect(FirestoreConverters.toInt(true), 1);
      expect(FirestoreConverters.toInt(false), 0);
      expect(FirestoreConverters.toInt(null, 3), 3);
    });

    test('toStr never returns null', () {
      expect(FirestoreConverters.toStr(null), '');
      expect(FirestoreConverters.toStr('x'), 'x');
      expect(FirestoreConverters.toStr(5), '5');
    });

    test('toBool parses common shapes', () {
      expect(FirestoreConverters.toBool(true), isTrue);
      expect(FirestoreConverters.toBool(1), isTrue);
      expect(FirestoreConverters.toBool('yes'), isTrue);
      expect(FirestoreConverters.toBool('0'), isFalse);
      expect(FirestoreConverters.toBool(null), isFalse);
    });

    test('toStringList/toMapList tolerate garbage', () {
      expect(FirestoreConverters.toStringList(['a', 1]), ['a', '1']);
      expect(FirestoreConverters.toStringList('nope'), isEmpty);
      expect(FirestoreConverters.toStringList(null), isEmpty);
      expect(
        FirestoreConverters.toMapList([
          {'a': 1},
          'skip',
        ]),
        [
          {'a': 1}
        ],
      );
    });
  });

  group('toLatLng', () {
    test('prefers GeoPoint, falls back to numerics, defaults 0,0', () {
      final geo = FirestoreConverters.toLatLng(
        {'geo': const GeoPoint(29.97, 31.13)},
      );
      expect(geo.lat, 29.97);
      expect(geo.lng, 31.13);

      final nums = FirestoreConverters.toLatLng(
        {'latitude': 25, 'longitude': 32},
      );
      expect((nums.lat, nums.lng), (25.0, 32.0));

      final empty = FirestoreConverters.toLatLng({});
      expect((empty.lat, empty.lng), (0.0, 0.0));
    });
  });
}
