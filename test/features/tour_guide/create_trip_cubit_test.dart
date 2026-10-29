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

  TripFormData form({
    String name = '',
    String price = '',
    String maxTravelers = '',
    String date = '',
    String time = '',
    String endTime = '',
    String phone = '',
    String duration = '',
  }) {
    return TripFormData(
      name: name,
      about: '',
      location: '',
      label: '',
      date: date,
      time: time,
      endTime: endTime,
      duration: duration,
      price: price,
      maxTravelers: maxTravelers,
      meeting: '',
      included: '',
      notes: '',
      languages: '',
      phone: phone,
    );
  }

  group('startAt', () {
    test('is null without a date', () {
      expect(form().startAt, isNull);
    });

    test('reads the day, month and year of the picked date', () {
      final startAt = form(date: '24/10/2026').startAt;
      expect(startAt, isNotNull);
      expect(startAt!.year, 2026);
      expect(startAt.month, 10);
      expect(startAt.day, 24);
    });

    test('reads the picked time in 12-hour form', () {
      final startAt = form(date: '24/10/2026', time: '5:00 PM').startAt!;
      expect(startAt.hour, 17);
      expect(startAt.minute, 0);
    });

    test('keeps midnight as zero and noon as twelve', () {
      expect(form(date: '24/10/2026', time: '12:00 AM').startAt!.hour, 0);
      expect(form(date: '24/10/2026', time: '12:00 PM').startAt!.hour, 12);
    });

    test('reads the Arabic meridiem too', () {
      expect(form(date: '24/10/2026', time: '5:00 م').startAt!.hour, 17);
      expect(form(date: '24/10/2026', time: '9:00 ص').startAt!.hour, 9);
    });

    test('falls back to midnight when the time is unreadable', () {
      final startAt = form(date: '24/10/2026', time: 'not a time').startAt!;
      expect(startAt.hour, 0);
      expect(startAt.minute, 0);
    });

    test('is null when the date is unreadable', () {
      expect(form(date: '24 October 2026').startAt, isNull);
    });
  });

  group('endAt', () {
    test('is null without a date', () {
      expect(form(time: '5:00 PM', endTime: '9:00 PM').endAt, isNull);
    });

    test('is null without an end time', () {
      expect(form(date: '24/10/2026', time: '5:00 PM').endAt, isNull);
    });

    test('endAt is the end time, not start plus duration', () {
      // Disagreeing inputs: start 10:00, End Time 15:00, duration "2 hours".
      // The End Time is the single source of truth; the duration dropdown is
      // ignored for endAt.
      final tripForm = form(
        date: '24/10/2026',
        time: '10:00 AM',
        endTime: '03:00 PM',
        duration: '2 hours',
      );
      expect(tripForm.endAt, isNotNull);
      expect(tripForm.endAt!.hour, 15);
      expect(tripForm.endAt!.minute, 0);
      // Duration is derived from start and end: 10:00 to 15:00 = 5 hours.
      expect(tripForm.durationLabel, '5 hours');
    });

    test('uses 8 hours for Full Day', () {
      final tripForm = form(
        date: '24/10/2026',
        time: '8:00 AM',
        endTime: '4:00 PM',
      );
      expect(tripForm.endAt, isNotNull);
      expect(tripForm.endAt!.hour, 16);
      expect(tripForm.durationLabel, 'Full Day');
    });
  });

  group('end time pre-fill (edit mode)', () {
    test('pre-filled end time produces consistent endAt and duration', () {
      final tripForm = form(
        date: '24/10/2026',
        time: '10:00 AM',
        endTime: '03:00 PM',
      );
      expect(tripForm.startAt!.hour, 10);
      expect(tripForm.endAt!.hour, 15);
      expect(tripForm.durationLabel, '5 hours');
    });
  });

  group('buildTrip', () {
    test('turns the picked moment into a readable schedule label', () {
      final trip = cubit.buildTrip(
        form(
          name: 'Pyramids Sunset Tour',
          price: '1650',
          date: '24/10/2026',
          time: '5:00 PM',
          endTime: '9:00 PM',
        ),
      );
      expect(trip.startAt, isNotNull);
      expect(trip.endAt, isNotNull);
      expect(trip.endAt!.hour, 21); // end time 9:00 PM
      expect(trip.duration, '4 hours'); // derived: 17:00 to 21:00
      expect(trip.scheduleLabel, contains('5:00 PM'));
      expect(trip.status.name, 'pending');
    });

    test('says "To be announced" without a date', () {
      final trip = cubit.buildTrip(
        form(name: 'Pyramids Sunset Tour', price: '1650'),
      );
      expect(trip.startAt, isNull);
      expect(trip.endAt, isNull);
      expect(trip.scheduleLabel, 'To be announced');
    });

    test('carries the duration, capacity and phone of the form', () {
      final trip = cubit.buildTrip(
        form(
          name: 'Pyramids Sunset Tour',
          price: '1650',
          maxTravelers: '12',
          date: '24/10/2026',
          time: '5:00 PM',
          endTime: '9:00 PM',
          phone: '+20 100 123 4567',
        ),
      );
      expect(trip.duration, '4 hours'); // derived from start + end
      expect(trip.capacity, 12);
      expect(trip.phone, '+20 100 123 4567');
      expect(trip.priceEgp, 1650);
    });
  });

  group('validate', () {
    test('asks for a name, a price and a capacity', () {
      expect(cubit.validate(form()), isNotNull);
      expect(cubit.validate(form(name: 'Pyramids Sunset Tour')), isNotNull);
      // The capacity has to be a real number — Firestore refuses a trip
      // with a capacity of zero.
      expect(
        cubit.validate(form(name: 'Pyramids Sunset Tour', price: '1650')),
        isNotNull,
      );
      // A trip also needs a start and an end moment to be bookable.
      expect(
        cubit.validate(
          form(name: 'Pyramids Sunset Tour', price: '1650', maxTravelers: '12'),
        ),
        isNotNull,
      );
      expect(
        cubit.validate(
          form(
            name: 'Pyramids Sunset Tour',
            price: '1650',
            maxTravelers: '12',
            date: '24/10/2026',
            time: '5:00 PM',
          ),
        ),
        isNotNull,
      );
      // End after start — all required fields set.
      expect(
        cubit.validate(
          form(
            name: 'Pyramids Sunset Tour',
            price: '1650',
            maxTravelers: '12',
            date: '24/10/2026',
            time: '5:00 PM',
            endTime: '9:00 PM',
          ),
        ),
        isNull,
      );
    });

    test('rejects a capacity that is not a number', () {
      expect(
        cubit.validate(
          form(
            name: 'Pyramids Sunset Tour',
            price: '1650',
            maxTravelers: '0',
            date: '24/10/2026',
            time: '5:00 PM',
            endTime: '9:00 PM',
          ),
        ),
        isNotNull,
      );
      expect(
        cubit.validate(
          form(
            name: 'Pyramids Sunset Tour',
            price: '1650',
            maxTravelers: 'a lot',
            date: '24/10/2026',
            time: '5:00 PM',
            endTime: '9:00 PM',
          ),
        ),
        isNotNull,
      );
    });

    test('rejects a missing start date and time', () {
      expect(
        cubit.validate(
          form(
            name: 'Pyramids Sunset Tour',
            price: '1650',
            maxTravelers: '12',
            endTime: '9:00 PM',
          ),
        ),
        isNotNull,
      );
    });

    test('rejects a missing end time', () {
      expect(
        cubit.validate(
          form(
            name: 'Pyramids Sunset Tour',
            price: '1650',
            maxTravelers: '12',
            date: '24/10/2026',
            time: '5:00 PM',
          ),
        ),
        isNotNull,
      );
    });

    test('validation fails when end time is not after start time', () {
      TripFormData validationForm(String endTime) => form(
        name: 'x',
        price: '1',
        maxTravelers: '1',
        date: '24/10/2026',
        time: '10:00 AM',
        endTime: endTime,
      );

      expect(
        cubit.validate(validationForm('09:00 AM')),
        isNotNull,
      ); // end before start
      expect(
        cubit.validate(validationForm('10:00 AM')),
        isNotNull,
      ); // equal, not after
      expect(cubit.validate(validationForm('11:00 AM')), isNull); // after start
    });
  });
}
