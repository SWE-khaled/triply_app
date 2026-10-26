import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tourist/booking_public/cubit/booking_public_cubit.dart';

/// The public-trip cubit pins the price formula and the payment-method
/// choice that is stored on the booking (added in S1).
void main() {
  late BookingPublicCubit cubit;

  setUp(() => cubit = BookingPublicCubit());
  tearDown(() => cubit.close());

  group('price', () {
    test('subtotal is unit price x seats', () {
      expect(cubit.subtotal(100), 100);
      cubit.changeSeats(3);
      expect(cubit.subtotal(100), 300);
    });

    test('service fee is 5 percent of the subtotal', () {
      cubit.changeSeats(4); // subtotal 400
      expect(cubit.fee(100), 20);
    });

    test('total is subtotal plus fee', () {
      cubit.changeSeats(2); // subtotal 200
      expect(cubit.total(100), 210); // 200 + 10
    });
  });

  group('payment method', () {
    test('defaults to card', () {
      expect(cubit.state.paymentMethod, 'card');
    });

    test('switches to wallet and back', () {
      cubit.changePaymentMethod('wallet');
      expect(cubit.state.paymentMethod, 'wallet');
      cubit.changePaymentMethod('card');
      expect(cubit.state.paymentMethod, 'card');
    });

    test('ignores anything that is not card or wallet', () {
      cubit.changePaymentMethod('cash');
      expect(cubit.state.paymentMethod, 'card');
    });
  });

  group('seats', () {
    test('clamps to the available spots', () {
      cubit.setMaxSpots(2);
      cubit.changeSeats(5);
      expect(cubit.state.seats, 2);
    });

    test('clamps to a minimum of one seat', () {
      cubit.changeSeats(0);
      expect(cubit.state.seats, 1);
    });
  });
}
