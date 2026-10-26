import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tour_guide/create_trip_tg/cubit/create_trip_cubit.dart';

/// The date + time pickers feed the cubit as text; the trip then stores a
/// real moment. These tests pin the parsing down, including the S2b rule
/// that the End Time (not the duration dropdown) is the single source of
/// truth for `endAt`, with duration derived from start and end.
void main() {
  late CreateTripCubit cubit;

  setUp(() => cubit = CreateTripCubit());
  tearDown(() => cubit.close());

  void pick({String? date, String? time, String? endTime}) {
    if (date != null) cubit.dateCtrl.text = date;
    if (time != null) cubit.timeCtrl.text = time;
    if (endTime != null) cubit.endTimeCtrl.text = endTime;
  }

  void setCompleteForm() {
    cubit.nameCtrl.text = 'Pyramids Sunset Tour';
    cubit.priceCtrl.text = '1650';
    cubit.maxTravelersCtrl.text = '12';
    cubit.dateCtrl.text = '24/10/2026';
    cubit.timeCtrl.text = '5:00 PM';
    cubit.endTimeCtrl.text = '9:00 PM';
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

  group('endAt', () {
    test('is null without a date', () {
      pick(time: '5:00 PM', endTime: '9:00 PM');
      expect(cubit.endAt, isNull);
    });

    test('is null without an end time', () {
      pick(date: '24/10/2026', time: '5:00 PM');
      expect(cubit.endAt, isNull);
    });

    test('endAt is the end time, not start plus duration', () {
      // Disagreeing inputs: start 10:00, End Time 15:00, duration "2 hours".
      // The End Time is the single source of truth; the duration dropdown is
      // ignored for endAt.
      pick(date: '24/10/2026', time: '10:00 AM', endTime: '03:00 PM');
      cubit.durationCtrl.text = '2 hours'; // contradictory, ignored
      expect(cubit.endAt, isNotNull);
      expect(cubit.endAt!.hour, 15);
      expect(cubit.endAt!.minute, 0);
      // Duration is derived from start and end: 10:00 to 15:00 = 5 hours.
      expect(cubit.durationLabel, '5 hours');
    });

    test('uses 8 hours for Full Day', () {
      pick(date: '24/10/2026', time: '8:00 AM', endTime: '4:00 PM');
      expect(cubit.endAt, isNotNull);
      expect(cubit.endAt!.hour, 16);
      expect(cubit.durationLabel, 'Full Day');
    });
  });

  group('end time pre-fill (edit mode)', () {
    test('pre-filled end time produces consistent endAt and duration', () {
      // Simulates the screen pre-filling endTimeCtrl from an existing trip.
      cubit.dateCtrl.text = '24/10/2026';
      cubit.timeCtrl.text = '10:00 AM';
      cubit.endTimeCtrl.text = '03:00 PM';
      expect(cubit.startAt!.hour, 10);
      expect(cubit.endAt!.hour, 15);
      expect(cubit.durationLabel, '5 hours');
    });
  });

  group('buildTrip', () {
    test('turns the picked moment into a readable schedule label', () {
      pick(date: '24/10/2026', time: '5:00 PM', endTime: '9:00 PM');
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      cubit.priceCtrl.text = '1650';

      final trip = cubit.buildTrip();
      expect(trip.startAt, isNotNull);
      expect(trip.endAt, isNotNull);
      expect(trip.endAt!.hour, 21); // end time 9:00 PM
      expect(trip.duration, '4 hours'); // derived: 17:00 to 21:00
      expect(trip.scheduleLabel, contains('5:00 PM'));
      expect(trip.status.name, 'pending');
    });

    test('says "To be announced" without a date', () {
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      cubit.priceCtrl.text = '1650';

      final trip = cubit.buildTrip();
      expect(trip.startAt, isNull);
      expect(trip.endAt, isNull);
      expect(trip.scheduleLabel, 'To be announced');
    });

    test('carries the duration, capacity and phone of the form', () {
      pick(date: '24/10/2026', time: '5:00 PM', endTime: '9:00 PM');
      cubit.nameCtrl.text = 'Pyramids Sunset Tour';
      cubit.priceCtrl.text = '1650';
      cubit.maxTravelersCtrl.text = '12';
      cubit.phoneCtrl.text = '+20 100 123 4567';

      final trip = cubit.buildTrip();
      expect(trip.duration, '4 hours'); // derived from start + end
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
      // A trip also needs a start and an end moment to be bookable.
      expect(cubit.validate(), isNotNull);
      cubit.dateCtrl.text = '24/10/2026';
      cubit.timeCtrl.text = '5:00 PM';
      expect(cubit.validate(), isNotNull);
      cubit.endTimeCtrl.text = '9:00 PM';
      // End after start — all required fields set.
      expect(cubit.validate(), isNull);
    });

    test('rejects a capacity that is not a number', () {
      setCompleteForm();
      cubit.maxTravelersCtrl.text = '0';
      expect(cubit.validate(), isNotNull);
      cubit.maxTravelersCtrl.text = 'a lot';
      expect(cubit.validate(), isNotNull);
    });

    test('rejects a missing start date and time', () {
      setCompleteForm();
      cubit.dateCtrl.clear();
      cubit.timeCtrl.clear();
      expect(cubit.validate(), isNotNull);
    });

    test('rejects a missing end time', () {
      setCompleteForm();
      cubit.endTimeCtrl.clear();
      expect(cubit.validate(), isNotNull);
    });

    test('validation fails when end time is not after start time', () {
      cubit.nameCtrl.text = 'x';
      cubit.priceCtrl.text = '1';
      cubit.maxTravelersCtrl.text = '1';
      pick(date: '24/10/2026', time: '10:00 AM', endTime: '09:00 AM');
      expect(cubit.validate(), isNotNull); // end before start
      cubit.endTimeCtrl.text = '10:00 AM'; // equal, not after
      expect(cubit.validate(), isNotNull);
      cubit.endTimeCtrl.text = '11:00 AM'; // after start
      expect(cubit.validate(), isNull);
    });
  });
}
