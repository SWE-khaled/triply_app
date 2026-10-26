import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/tourist_booking.dart';

/// The booking model must read every field a My Trips screen needs —
/// including the payment and scheduling fields added in S1 — and must
/// never break when an older document is missing them.
void main() {
  test('fromDocument reads every field', () {
    final endAt = DateTime(2026, 10, 24, 14, 0);
    final expiresAt = DateTime(2026, 10, 24, 10, 30);
    final data = <String, dynamic>{
      'tripId': 't1',
      'tour_title': 'Sunset Tour',
      'seats': 2,
      'traveler_count': 2,
      'totalPrice': 210.0,
      'status': 'confirmed',
      'paymentStatus': 'paid',
      'expiresAt': Timestamp.fromDate(expiresAt),
      'endAt': Timestamp.fromDate(endAt),
    };
    final b = TouristBooking.fromDocument(data, 'b1');
    expect(b.id, 'b1');
    expect(b.tripId, 't1');
    expect(b.tourTitle, 'Sunset Tour');
    expect(b.seats, 2);
    expect(b.totalPrice, 210.0);
    expect(b.status, 'confirmed');
    expect(b.paymentStatus, 'paid');
    expect(b.expiresAt, expiresAt);
    expect(b.endAt, endAt);
  });

  test('fromDocument tolerates missing fields (legacy documents)', () {
    final b = TouristBooking.fromDocument(<String, dynamic>{}, 'b2');
    expect(b.id, 'b2');
    expect(b.tripId, '');
    expect(b.tourTitle, '');
    expect(b.seats, 0);
    expect(b.totalPrice, 0);
    expect(b.status, '');
    expect(b.paymentStatus, '');
    expect(b.expiresAt, isNull);
    expect(b.endAt, isNull);
  });

  test('seat count falls back to traveler_count', () {
    final b = TouristBooking.fromDocument(
      <String, dynamic>{
        'tripId': 't1',
        'traveler_count': 3,
        'status': 'pending',
      },
      'b3',
    );
    expect(b.seats, 3);
  });
}
