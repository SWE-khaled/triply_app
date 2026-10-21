import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tour_guide/create_trip_tg/cubit/create_trip_cubit.dart';

/// The date + time pickers feed the cubit as text; the trip then stores a
/// real moment. These tests pin the parsing down.
void main() {
  late CreateTripCubit cubit;

  setUp(() => cubit = CreateTripCubit());
  tearDown(() => cubit.close());

  void pick({String? date, String? time}) {
    if (date != null) cubit.dateCtrl.text = date;
    if (time != null) cubit.timeCtrl.text = time;
  }

  group('startAt', () {
    test('is null without a date', () {
      expect(cubit.startAt, isNull);
    });

    test('reads the day, month and year of the picked date', () {
      pick(date: '24/10/2026');
      final startAt = cubit.startAt;
      expect(startAt, isNotNull);
      expect(startAt!.year, 2026);
      expect(startAt.month, 10);
      expect(startAt.day, 24);
    });

    test('reads the picked time in 12-hour form', () {
      pick(date: '24/10/2026', time: '5:00 PM');
      final startAt = cubit.startAt!;
      expect(startAt.hour, 17);
      expect(startAt.minute, 0);
    });

    test('keeps midnight as zero and noon as twelve', () {
      pick(date: '24/10/2026', time: '12:00 AM');
      expect(cubit.startAt!.hour, 0);

      pick(date: '24/10/2026', time: '12:00 PM');
      expect(cubit.startAt!.hour, 12);
    });

    test('reads the Arabic meridiem too', () {
      pick(date: '24/10/2026', time: '5:00 م');
      expect(cubit.startAt!.hour, 17);

      pick(date: '24/10/2026', time: '9:00 ص');
      expect(cubit.startAt!.hour, 9);
    });

    test('falls back to midnight when the time is unreadable', () {
      pick(date: '24/10/2026', time: 'not a time');
      final startAt = cubit.startAt!;
      expect(startAt.hour, 0);
      expect(startAt.minute, 0);
    });

    test('is null when the date is unreadable', () {
      pick(date: '24 October 2026');
      expect(cubit.startAt, isNull);
    });
  });

  group('buildTrip', () {
    test('turns the picked moment into a readable schedule label', () {
      pick(date: '24/10/2026', time: '5:00 PM');
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      cubit.priceCtrl.text = '1650';

      final trip = cubit.buildTrip();
      expect(trip.startAt, isNotNull);
      expect(trip.scheduleLabel, contains('5:00 PM'));
      expect(trip.status.name, 'pending');
    });

    test('says "To be announced" without a date', () {
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      cubit.priceCtrl.text = '1650';

      final trip = cubit.buildTrip();
      expect(trip.startAt, isNull);
      expect(trip.scheduleLabel, 'To be announced');
    });

    test('carries the duration, capacity and phone of the form', () {
      pick(date: '24/10/2026', time: '5:00 PM');
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      cubit.priceCtrl.text = '1650';
      cubit.durationCtrl.text = '4 hours';
      cubit.maxTravelersCtrl.text = '12';
      cubit.phoneCtrl.text = '+20 100 123 4567';

      final trip = cubit.buildTrip();
      expect(trip.duration, '4 hours');
      expect(trip.capacity, 12);
      expect(trip.phone, '+20 100 123 4567');
      expect(trip.priceEgp, 1650);
    });
  });

  group('validate', () {
    test('asks for a name, a price and a capacity', () {
      expect(cubit.validate(), isNotNull);
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      expect(cubit.validate(), isNotNull);
      cubit.priceCtrl.text = '1650';
      // The capacity has to be a real number — Firestore refuses a trip
      // with a capacity of zero.
      expect(cubit.validate(), isNotNull);
      cubit.maxTravelersCtrl.text = '12';
      expect(cubit.validate(), isNull);
    });

    test('rejects a capacity that is not a number', () {
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      cubit.priceCtrl.text = '1650';
      cubit.maxTravelersCtrl.text = '0';
      expect(cubit.validate(), isNotNull);
      cubit.maxTravelersCtrl.text = 'a lot';
      expect(cubit.validate(), isNotNull);
    });
  });
}
