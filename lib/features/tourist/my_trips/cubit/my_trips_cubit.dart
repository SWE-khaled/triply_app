import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_public.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/models/tourist_booking.dart';
import 'package:triply/core/data/my_bookings_public.dart';
import 'package:triply/core/data/repositories/booking_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../trips/models/trip.dart';

part 'my_trips_state.dart';

/// The trips the tourist booked.
///
/// The bookings come from Firestore — the ones the tourist made — and the
/// trip details are joined from the trip documents. The session store is
/// the fallback for when the read fails (offline).
class MyTripsCubit extends Cubit<MyTripsState>
    with SafeEmitMixin<MyTripsState> {
  MyTripsCubit({
    BookingRepository? bookingRepository,
    PublicTripsRepository? tripsRepository,
  }) : _bookingRepository = bookingRepository ?? BookingRepository(),
       _tripsRepository = tripsRepository ?? PublicTripsRepository(),
       super(const MyTripsInitial()) {
    load();
  }

  final BookingRepository _bookingRepository;
  final PublicTripsRepository _tripsRepository;

  /// The tab the list is filtered by.
  TripStatus _selectedTab = TripStatus.upcoming;

  /// The bookings of the tourist, joined with their trips.
  List<Trip> _booked = const [];

  /// The status of every booking, by trip id — `pending`, `confirmed`…
  final Map<String, String> _statusByTrip = {};

  /// The status of the booking of [tripId], or an empty string when the
  /// trip was not booked here.
  String statusFor(String tripId) => _statusByTrip[tripId] ?? '';

  /// Reads the bookings and applies the current tab.
  Future<void> load() async {
    safeEmit(const MyTripsLoading());
    try {
      final bookings = await _bookingRepository.fetchMyBookings();
      if (bookings == null) {
        _booked = _sessionTrips();
      } else {
        // Lazy expiry (no scheduler): cancel any of the tourist's own
        // pending bookings whose `expiresAt` has passed and release their
        // seats, then build the list from the (possibly cancelled) set.
        final expiredIds = await _expirePending(bookings);
        _booked = await _tripsOf(bookings, expiredIds);
      }
      _applyTab(_selectedTab);
    } catch (e) {
      safeEmit(MyTripsError(error: e.toString()));
    }
  }

  /// Switches the tab. No reload — the bookings are already loaded.
  void selectTab(TripStatus status) => _applyTab(status);

  /// Re-reads the bookings (call after returning from the booking flow).
  void refresh() => load();

  /// Cancels the tourist's own pending bookings whose `expiresAt` has
  /// passed and releases their seats. Returns the ids that were cancelled.
  Future<Set<String>> _expirePending(List<TouristBooking> bookings) async {
    final now = DateTime.now();
    final cancelled = <String>{};
    for (final booking in bookings) {
      if (booking.status != 'pending') continue;
      final expiresAt = booking.expiresAt;
      if (expiresAt == null || !expiresAt.isBefore(now)) continue;
      cancelled.add(booking.id);
      try {
        await _bookingRepository.cancelBooking(
          bookingId: booking.id,
          wasPaid: booking.paymentStatus == 'paid',
        );
      } catch (_) {
        // Best effort — the booking is retried on the next load.
      }
    }
    return cancelled;
  }

  void _applyTab(TripStatus status) {
    _selectedTab = status;
    safeEmit(
      MyTripsSuccess(
        selectedTab: status,
        trips: _booked.where((t) => t.status == status).toList(),
      ),
    );
  }

  /// Joins the bookings with the trip documents.
  /// [expiredIds] are bookings cancelled by the lazy expiry this load.
  Future<List<Trip>> _tripsOf(
    List<TouristBooking> bookings,
    Set<String> expiredIds,
  ) async {
    final trips = await _tripsRepository.fetchTripsByIds(
      bookings.map((b) => b.tripId).toList(),
    );
    final byId = {for (final trip in trips) trip.id: trip};

    final joined = <Trip>[];
    for (final booking in bookings) {
      final trip = byId[booking.tripId];
      if (trip == null) continue;
      final effective =
          expiredIds.contains(booking.id) ? 'cancelled' : booking.status;
      _statusByTrip[booking.tripId] = effective;
      joined.add(_cardOf(trip, booking, _tripStatus(effective, booking)));
    }
    return joined;
  }

  /// The display status of a booking: `cancelled` when cancelled or expired,
  /// `completed` when a confirmed booking's `endAt` has passed (display
  /// only, no write), otherwise `upcoming`.
  TripStatus _tripStatus(String status, TouristBooking booking) {
    if (status == 'cancelled') return TripStatus.cancelled;
    if (status == 'confirmed') {
      final endAt = booking.endAt;
      if (endAt != null && endAt.isBefore(DateTime.now())) {
        return TripStatus.completed;
      }
    }
    return TripStatus.upcoming;
  }

  /// The card of a booked trip: the seats taken and what was paid.
  Trip _cardOf(PublicTrip trip, TouristBooking booking, TripStatus status) {
    return Trip(
      id: trip.id,
      title: trip.title,
      dateLabel: trip.dateLabel,
      guideName: trip.guideName,
      peopleCount: booking.seats > 0 ? booking.seats : trip.bookedSeats,
      priceEgp: booking.totalPrice > 0 ? booking.totalPrice : trip.priceEgp,
      imageUrl: trip.imageUrl,
      status: status,
      category: trip.category,
      capacity: trip.capacity,
    );
  }

  /// The bookings of the session store, used when Firestore is out of
  /// reach.
  List<Trip> _sessionTrips() {
    final trips = mockTripsJson
        .map((e) => Trip.fromJson(e))
        .where((t) => MyBookingsPublic.isBooked(t.id))
        .map((t) {
          // Show the actually booked seat count, not the mock headcount.
          final seats = MyBookingsPublic.seatsFor(t.id);
          // Show the actually paid total, not the single-person price.
          final paidTotal = MyBookingsPublic.totalPaidFor(t.id);
          if (seats <= 0 && paidTotal <= 0) return t;
          return Trip(
            id: t.id,
            title: t.title,
            dateLabel: t.dateLabel,
            guideName: t.guideName,
            peopleCount: seats > 0 ? seats : t.peopleCount,
            priceEgp: paidTotal > 0 ? paidTotal : t.priceEgp,
            imageUrl: t.imageUrl,
            status: t.status,
            category: t.category,
            capacity: t.capacity,
          );
        })
        .toList();

    // Private guide bookings appear under Upcoming as synthetic trips
    // (built from the stored booking, never duplicated mock data).
    for (final record in MyBookingsPublic.privateRecords) {
      final entry = record.value;
      trips.add(
        Trip(
          id: record.key,
          title: entry.title ?? 'Private tour',
          dateLabel: entry.dateLabel ?? '',
          guideName: entry.guideName ?? '',
          peopleCount: entry.seats,
          priceEgp: entry.totalPaid,
          imageUrl: entry.imageUrl ?? '',
          status: TripStatus.upcoming,
          category: 'private',
          capacity: entry.seats,
        ),
      );
    }
    return trips;
  }
}
