import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tourist/booking/cubit/booking_cubit.dart';

/// The private booking computes its real start and end moments from the
/// date picker, the time slot and the hours selector (added in S1).
void main() {
  late BookingCubit cubit;

  setUp(() => cubit = BookingCubit(guideId: 'g1'));
  tearDown(() => cubit.close());

  group('startAt', () {
    test('is null without a date', () {
      expect(cubit.startAt, isNull);
    });

    test('computes the start from the picked date and time slot', () {
      cubit.setDate(DateTime(2026, 10, 24));
      cubit.setTimeSlot('5:00 PM');
      expect(cubit.startAt, isNotNull);
      expect(cubit.startAt!.hour, 17);
      expect(cubit.startAt!.minute, 0);
    });

    test('keeps midnight as zero and noon as twelve', () {
      cubit.setDate(DateTime(2026, 10, 24));
      cubit.setTimeSlot('12:00 AM');
      expect(cubit.startAt!.hour, 0);
      cubit.setTimeSlot('12:00 PM');
      expect(cubit.startAt!.hour, 12);
    });

    test('reads the Arabic meridiem too', () {
      cubit.setDate(DateTime(2026, 10, 24));
      cubit.setTimeSlot('5:00 م');
      expect(cubit.startAt!.hour, 17);
      cubit.setTimeSlot('9:00 ص');
      expect(cubit.startAt!.hour, 9);
    });

    test('is null with an unreadable time slot', () {
      cubit.setDate(DateTime(2026, 10, 24));
      cubit.setTimeSlot('not a time');
      expect(cubit.startAt, isNull);
    });
  });

  group('endAt', () {
    test('is null without a start moment', () {
      expect(cubit.endAt, isNull);
    });

    test('is the start moment plus the selected duration hours', () {
      cubit.setDate(DateTime(2026, 10, 24));
      cubit.setTimeSlot('9:00 AM');
      cubit.setDuration('4 hours');
      expect(cubit.endAt, cubit.startAt!.add(const Duration(hours: 4)));
    });

    test('uses 8 hours for Full Day', () {
      cubit.setDate(DateTime(2026, 10, 24));
      cubit.setTimeSlot('8:00 AM');
      cubit.setDuration('Full Day');
      expect(cubit.endAt, cubit.startAt!.add(const Duration(hours: 8)));
    });
  });
}
