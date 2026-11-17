import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/models/tourist_booking.dart';
import 'package:triply/core/data/repositories/booking_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../trips/models/trip.dart';

part 'my_trips_state.dart';

/// The trips the tourist booked.
///
/// The bookings come from Firestore and their trip details are joined from
/// the corresponding trip documents.
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
  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _reloadRequested = false;

  /// The status of every booking, by trip id — `pending`, `confirmed`…
  final Map<String, String> _statusByTrip = {};

  /// The status of the booking of [tripId], or an empty string when the
  /// trip was not booked here.
  String statusFor(String tripId) => _statusByTrip[tripId] ?? '';

  /// Reads the bookings and applies the current tab.
  Future<void> load() async {
    if (_isLoading) {
      _reloadRequested = true;
      return;
    }
    _isLoading = true;
    // Only the very first read shows the shimmer; a retry after an error
    // keeps the error view instead of restarting the skeleton.
    if (!_hasLoaded && state is! MyTripsError) {
      safeEmit(const MyTripsLoading());
    }
    try {
      final bookings = await _bookingRepository.fetchMyBookings();
      // Lazy expiry (no scheduler): cancel any of the tourist's own pending
      // bookings whose `expiresAt` has passed and release their seats.
      final expiredIds = await _expirePending(bookings);
      _booked = await _tripsOf(bookings, expiredIds);
      _hasLoaded = true;
      _applyTab(_selectedTab);
    } catch (error, stackTrace) {
      debugPrint('MyTripsCubit.load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      safeEmit(MyTripsError(error: pageLoadErrorDetail(error)));
    } finally {
      _isLoading = false;
      if (_reloadRequested && !isClosed) {
        _reloadRequested = false;
        await load();
      }
    }
  }

  /// Switches the tab. No reload — the bookings are already loaded.
  void selectTab(TripStatus status) => _applyTab(status);

  /// Re-reads the bookings (call after returning from the booking flow).
  Future<void> refresh() => load();

  /// Re-reads the bookings for the Upcoming tab.
  ///
  /// Used after a successful payment: the cubit is app-session-scoped, so a
  /// previously selected tab would otherwise keep a newly confirmed booking
  /// out of the emitted list. The existing [load] guard keeps concurrent
  /// refreshes to a single replay.
  Future<void> refreshUpcoming() async {
    _selectedTab = TripStatus.upcoming;
    await load();
  }

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
        await _bookingRepository.cancelBooking(bookingId: booking.id);
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
    final publicBookings = bookings.where((booking) => !booking.isPrivate);
    final trips = await _tripsRepository.fetchTripsByIds(
      publicBookings.map((booking) => booking.tripId).toList(),
      rethrowOnError: true,
    );
    final byId = {for (final trip in trips) trip.id: trip};

    final joined = <Trip>[];
    for (final booking in bookings) {
      if (booking.isPrivate) {
        final effective = expiredIds.contains(booking.id)
            ? 'cancelled'
            : booking.status;
        _statusByTrip[booking.id] = effective;
        joined.add(
          Trip(
            id: booking.id,
            bookingId: booking.id,
            title: booking.tourTitle.isNotEmpty
                ? booking.tourTitle
                : 'Private tour with ${booking.guideName}',
            dateLabel: booking.dateLabel,
            guideName: booking.guideName,
            peopleCount: booking.seats,
            priceEgp: booking.totalPrice,
            imageUrl: booking.imageUrl,
            status: _tripStatus(effective, booking),
            category: 'private',
            capacity: booking.seats,
          ),
        );
        continue;
      }
      final trip = byId[booking.tripId];
      if (trip == null) continue;
      final effective = expiredIds.contains(booking.id)
          ? 'cancelled'
          : booking.status;
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
      bookingId: booking.id,
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
}
