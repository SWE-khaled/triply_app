import 'package:flutter_test/flutter_test.dart';
import 'package:triply/data/firestore/booking_pricing.dart';

void main() {
  group('public pricing (unit × seats + fee)', () {
    test('matches BookingPublicCubit 5% math', () {
      // 6000 × 2 = 12000, fee 600, total 12600.
      final p = BookingPricing.public(unitPrice: 6000, seats: 2);
      expect(p.subtotal, 12000);
      expect(p.fee, 600);
      expect(p.total, 12600);
    });

    test('clamps seats < 1 and negative prices', () {
      final p = BookingPricing.public(unitPrice: -50, seats: 0);
      expect(p.total, 0);
    });

    test('custom fee rate respected', () {
      final p = BookingPricing.public(
        unitPrice: 1000,
        seats: 1,
        feeRate: 0.10,
      );
      expect(p.total, 1100);
    });
  });

  group('private pricing (pricePerHour × hours × travelers + fee)', () {
    test('matches BookingCubit display math', () {
      // 50 × 4h × 2 = 400, fee 20, total 420.
      final p = BookingPricing.private(
        pricePerHour: 50,
        hours: 4,
        travelers: 2,
      );
      expect(p.subtotal, 400);
      expect(p.fee, 20);
      expect(p.total, 420);
    });
  });

  group('hoursForLabel', () {
    test('maps the cubit duration labels', () {
      expect(BookingPricing.hoursForLabel('2 hours'), 2);
      expect(BookingPricing.hoursForLabel('4 hours'), 4);
      expect(BookingPricing.hoursForLabel('6 hours'), 6);
      expect(BookingPricing.hoursForLabel('Full Day'), 8);
      expect(BookingPricing.hoursForLabel('unknown'), 2);
    });
  });

  group('validation (mirrors Function enforcement)', () {
    test('public seats vs availability', () {
      expect(
        BookingPricing.validatePublic(seats: 0, available: 5),
        isNotNull,
      );
      expect(
        BookingPricing.validatePublic(seats: 6, available: 5),
        contains('Only 5 seats left'),
      );
      expect(
        BookingPricing.validatePublic(seats: 2, available: 5),
        isNull,
      );
    });

    test('private traveler bounds 1..10', () {
      expect(BookingPricing.validatePrivate(travelers: 0), isNotNull);
      expect(BookingPricing.validatePrivate(travelers: 11), isNotNull);
      expect(BookingPricing.validatePrivate(travelers: 4), isNull);
    });
  });

  test('toMinorUnits matches Paymob amount_cents', () {
    expect(BookingPricing.toMinorUnits(12600), 1260000);
    expect(BookingPricing.toMinorUnits(420.5), 42050);
  });
}
