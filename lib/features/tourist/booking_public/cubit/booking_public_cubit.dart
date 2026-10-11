import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/data/firestore/booking_pricing.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import '../../trips/models/trip.dart';
import 'booking_public_state.dart';

class BookingPublicCubit extends Cubit<BookingPublicState> {
  static const double serviceRate = 0.05;
  static const int minSeats = 1;

  BookingPublicCubit()
    : super(
        const BookingPublicState(seats: 1, specialRequests: '', maxSpots: 6),
      );

  /// Links the card's group size to availability:
  /// spots left = trip capacity - people already on the trip.
  void setMaxSpots(int maxSpots) {
    final clamped = maxSpots < minSeats ? minSeats : maxSpots;
    emit(
      state.copyWith(
        maxSpots: clamped,
        seats: state.seats > clamped ? clamped : state.seats,
      ),
    );
  }

  int _clamp(int seats) {
    if (seats < minSeats) return minSeats;
    if (seats > state.maxSpots) return state.maxSpots;
    return seats;
  }

  void changeSeats(int seats) => emit(state.copyWith(seats: _clamp(seats)));

  void changeRequests(String value) =>
      emit(state.copyWith(specialRequests: value));

  double subtotal(double unitPrice) => unitPrice * state.seats;

  double fee(double unitPrice) => subtotal(unitPrice) * serviceRate;

  double total(double unitPrice) => subtotal(unitPrice) + fee(unitPrice);

  /// Client-side availability pre-check (UX only). [available] is the
  /// best-known seats-left value; the Function revalidates atomically and
  /// is authoritative.
  String? validateSeats(int available) =>
      BookingPricing.validatePublic(seats: state.seats, available: available);

  /// Best-effort trip-date extraction. Trip `dateLabel`s are display
  /// strings; only ISO-parseable values are sent (as UTC). Returns null
  /// otherwise — the backend treats an omitted tripDate as absent metadata,
  /// never as an error. Never invents a date.
  static DateTime? parseTripDate(String dateLabel) =>
      DateTime.tryParse(dateLabel.trim());

  /// Deterministic idempotency key for one logical booking request.
  /// Identical inputs (including a retry after a network failure) produce
  /// the identical key, so the server dedupes to the original booking.
  /// Any material change (seats, date, requests) produces a different key.
  static String buildIdempotencyKey({
    required String uid,
    required String tripId,
    required DateTime? tripDate,
    required int seats,
    required String specialRequests,
  }) {
    final d = tripDate == null
        ? 'nodate'
        : '${tripDate.toUtc().year.toString().padLeft(4, '0')}'
              '${tripDate.toUtc().month.toString().padLeft(2, '0')}'
              '${tripDate.toUtc().day.toString().padLeft(2, '0')}';
    final req = BookingPricing.shortHash(specialRequests.trim());
    return 'pub-$uid-$tripId-$d-$seats-$req';
  }

  /// Creates the booking through `createBooking` and returns the
  /// authoritative server [BookingDoc] (server totals, server capacity
  /// enforcement). Returns null when a submission is already in flight
  /// (duplicate-tap guard) — the in-flight request owns the idempotency
  /// key, so no second booking is created. Throws with a user-facing
  /// message on validation/backend failure; never records a local booking.
  Future<BookingDoc?> submitBooking({
    required BookingsRepository repository,
    required String? uid,
    required Trip trip,
  }) async {
    if (state.isSubmitting) return null;
    if (uid == null || uid.isEmpty) {
      throw Exception('Please sign in to book.');
    }
    final err = validateSeats(trip.capacity - trip.peopleCount);
    if (err != null) throw Exception(err);
    final tripDate = parseTripDate(trip.dateLabel);
    final key = buildIdempotencyKey(
      uid: uid,
      tripId: trip.id,
      tripDate: tripDate,
      seats: state.seats,
      specialRequests: state.specialRequests,
    );
    emit(state.copyWith(isSubmitting: true));
    try {
      return await repository.createPublic(
        tripId: trip.id,
        tripDate: tripDate,
        seats: state.seats,
        idempotencyKey: key,
        specialRequests: state.specialRequests,
      );
    } finally {
      if (!isClosed) emit(state.copyWith(isSubmitting: false));
    }
  }
}
