import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/my_bookings_public.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/guide_profiles_datasource.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import '../../trips/models/trip.dart';
import 'my_trips_state.dart';

/// Server-backed booked list (My Trips). Loads the authenticated tourist's
/// bookings (`listByTourist`: per-doc rules keep it strictly own-data) and
/// maps them onto the existing [Trip] card models — no mocks, no synthetic
/// trips. An empty server response stays honestly empty.
///
/// Cancellation always goes through the `cancelBooking` callable
/// ([BookingsRepository.cancelViaServer]); the list reloads from the server
/// afterwards. Paid cancellations record `refundStatus: owed` server-side
/// (manual handling); the UI never claims amounts or visa refunds.
class MyTripsCubit extends Cubit<MyTripsState> {
  /// Kill-switch: gates every remote call in the View. Phase 3 (my trips +
  /// cancellation) is activated; flipping back to `false` is instant
  /// rollback to the empty baseline.
  static const bool useRemote = true;

  final BookingsRepository _bookings;
  TripsDatasource? _tripsDS;
  GuideProfilesDatasource? _guidesDS;

  MyTripsCubit({
    BookingsRepository? bookings,
    TripsDatasource? trips,
    GuideProfilesDatasource? guides,
  }) : _bookings = bookings ?? BookingsRepository(),
       _tripsDS = trips,
       _guidesDS = guides,
       super(const MyTripsState(selectedTab: TripStatus.upcoming, trips: []));

  // Lazy: constructing the cubit must not touch Firebase (keeps widget/unit
  // tests and offline startup free of Firebase initialization).
  TripsDatasource get _trips => _tripsDS ??= TripsDatasource();
  GuideProfilesDatasource get _guides =>
      _guidesDS ??= GuideProfilesDatasource();

  /// Last successful fetch, all statuses. Tabs filter this; an empty fetch
  /// clears it (empty stays empty — never mock fallback).
  List<Trip> _serverTrips = [];

  /// Authoritative booking per card, keyed by BOOKING id (one trip booked
  /// twice yields two cards with distinct bookings). Cards always carry
  /// their booking id ([Trip.bookingId]); helpers resolve through it.
  final Map<String, BookingDoc> _byBookingId = {};

  static TripStatus _tabFor(String status) {
    switch (status) {
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        // pending + confirmed (+ any future active state) are upcoming:
        // visible, never silently hidden.
        return TripStatus.upcoming;
    }
  }

  static String _dateLabelFor(DateTime? date, String timeSlot) {
    if (date == null) return timeSlot;
    final d = date.toLocal();
    final label =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return timeSlot.isEmpty ? label : '$label · $timeSlot';
  }

  /// Public booking -> card. Title/image/date/guide come from the live trip
  /// doc; seats/total/status/currency are the booking's own server values.
  /// When the trip doc is gone or unreadable, the card still renders from
  /// real booking fields only (generic title) — a live booking is never
  /// hidden and never dressed as another trip. Returns null only when the
  /// booking itself carries no trip reference (malformed).
  Future<Trip?> _mapPublic(BookingDoc b) async {
    final tripId = b.tripId ?? '';
    if (tripId.isEmpty) return null;
    String title = 'Booked trip';
    String dateLabel = _dateLabelFor(b.tripDate, b.timeSlot);
    String guideName = '';
    String imageUrl = '';
    String category = 'historical';
    int capacity = b.seats;
    try {
      final doc = await _trips.getById(tripId);
      if (doc != null) {
        final t = FirestoreMappers.tripDocToTouristTrip(doc);
        title = t.title;
        dateLabel = t.dateLabel;
        guideName = t.guideName;
        imageUrl = t.imageUrl;
        category = t.category;
        capacity = t.capacity;
      }
    } catch (e) {
      debugPrint('Triply: MyTripsCubit trip resolve failed: $e');
    }
    return Trip(
      id: tripId,
      bookingId: b.id,
      title: title,
      dateLabel: dateLabel,
      guideName: guideName,
      peopleCount: b.seats,
      priceEgp: b.totalAmount,
      imageUrl: imageUrl,
      status: _tabFor(b.status),
      category: category,
      capacity: capacity,
    );
  }

  /// Private booking -> card. Guide display comes from the public
  /// `guideProfiles/` directory; every other field is the booking's own
  /// server data. Never a mock trip.
  Future<Trip> _mapPrivate(BookingDoc b) async {
    String guideName = '';
    String imageUrl = '';
    try {
      final p = await _guides.getByUserId(b.guideId);
      if (p != null) {
        guideName = p.displayName;
        imageUrl = p.coverUrl;
      }
    } catch (e) {
      debugPrint('Triply: MyTripsCubit guide resolve failed: $e');
    }
    return Trip(
      id: b.id,
      bookingId: b.id,
      title: guideName.isEmpty
          ? 'Private tour'
          : 'Private tour with $guideName',
      dateLabel: _dateLabelFor(b.appointmentAt, b.timeSlot),
      guideName: guideName,
      peopleCount: b.seats,
      priceEgp: b.totalAmount,
      imageUrl: imageUrl,
      status: _tabFor(b.status),
      category: 'private',
      capacity: b.seats,
    );
  }

  /// Loads the tourist's bookings and maps them onto the current tab.
  /// Returns true on success (even when the list is honestly empty);
  /// false keeps the previous list with an explicit error for the View.
  Future<bool> loadRemote(String? uid) async {
    if (uid == null || uid.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Please sign in to see your trips.',
        ),
      );
      return false;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final res = await _bookings.myBookings(uid);
      if (res is FirestoreFailure<List<BookingDoc>>) {
        emit(state.copyWith(isLoading: false, error: res.message));
        return false;
      }
      final docs = res is FirestoreOk<List<BookingDoc>>
          ? res.data
          : <BookingDoc>[];
      final trips = <Trip>[];
      final byId = <String, BookingDoc>{};
      for (final b in docs) {
        final t = b.isPublic ? await _mapPublic(b) : await _mapPrivate(b);
        if (t == null) continue;
        trips.add(t);
        byId[b.id] = b;
      }
      _serverTrips = trips;
      _byBookingId
        ..clear()
        ..addAll(byId);
      emit(
        state.copyWith(
          isLoading: false,
          clearError: true,
          trips: trips.where((t) => t.status == state.selectedTab).toList(),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Triply: MyTripsCubit.loadRemote failed: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Could not load your trips. Please try again.',
        ),
      );
      return false;
    }
  }

  void selectTab(TripStatus status) {
    emit(
      state.copyWith(
        selectedTab: status,
        trips: _serverTrips.where((t) => t.status == status).toList(),
      ),
    );
  }

  /// Cancels through the `cancelBooking` callable and reloads the
  /// authoritative list. [bookingId] is the exact server booking
  /// ([Trip.bookingId] on the card), so cancelling one of two bookings on
  /// the same trip leaves the other untouched. Returns the server
  /// `refundStatus` (`'owed'` when a captured payment needs manual
  /// handling, `'none'` otherwise) — the View must not claim amounts or
  /// visa refunds from anything else.
  /// Throws with a user-facing message on validation/backend failure;
  /// duplicate in-flight taps are rejected before any server call.
  Future<String> cancelBooking({
    required String? uid,
    required String? bookingId,
  }) async {
    final doc = bookingId == null ? null : _byBookingId[bookingId];
    if (doc == null) throw Exception('Booking not found.');
    if (uid == null || uid.isEmpty) {
      throw Exception('Please sign in to manage bookings.');
    }
    if (state.cancellingIds.contains(doc.id)) {
      throw Exception('Cancellation already in progress.');
    }
    if (doc.status == 'cancelled') {
      throw Exception('This booking is already cancelled.');
    }
    if (doc.status != 'pending' && doc.status != 'confirmed') {
      throw Exception('This booking can no longer be cancelled.');
    }
    emit(state.copyWith(cancellingIds: {...state.cancellingIds, doc.id}));
    try {
      final refundStatus = await _bookings.cancelViaServer(doc.id);
      // Compat: drop any session entry for the same trip (server is primary;
      // the local store has other consumers and stays intact otherwise).
      MyBookingsPublic.cancelBooking(doc.tripId ?? doc.id);
      await loadRemote(uid);
      return refundStatus;
    } finally {
      if (!isClosed) {
        emit(
          state.copyWith(
            cancellingIds: state.cancellingIds
                .where((id) => id != doc.id)
                .toSet(),
          ),
        );
      }
    }
  }

  /// Card helpers for the View (backed by the authoritative side-table).
  /// Unknown ids (non-booking cards) report safe defaults.
  bool isPrivateBooking(String? bookingId) =>
      _byBookingId[bookingId]?.isPrivate ?? false;

  bool isPendingApproval(String? bookingId) =>
      _byBookingId[bookingId]?.status == 'pending';

  bool isCancellable(String? bookingId) {
    final s = _byBookingId[bookingId]?.status;
    return s == 'pending' || s == 'confirmed';
  }

  String currencyFor(String? bookingId) =>
      _byBookingId[bookingId]?.currency ?? 'EGP';
}
