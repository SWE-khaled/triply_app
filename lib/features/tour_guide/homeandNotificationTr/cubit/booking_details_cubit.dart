import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/data/firestore/datasources/bookings_datasource.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/datasources/users_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import '../../../../../core/data/mock/tourguide/mock_booking_details.dart';
import '../model/booking_details.dart';
import 'booking_details_state.dart';

/// Booking details: Firestore `bookings/{id}` first, mock fallback.
/// Enriches the doc with the tourist's profile name/avatar and the trip's
/// title/location (best-effort; missing docs keep raw ids).
class BookingDetailsCubit extends Cubit<BookingDetailsState> {
  BookingDetailsCubit({
    required String bookingId,
    BookingsDatasource? bookings,
    TripsDatasource? trips,
    UsersDatasource? users,
  })  : _bookingId = bookingId,
        _bookings = bookings ?? BookingsDatasource(),
        _trips = trips ?? TripsDatasource(),
        _users = users ?? UsersDatasource(),
        super(
          BookingDetailsState(
            details: _lookupMock(bookingId),
          ),
        );

  final String _bookingId;
  final BookingsDatasource _bookings;
  final TripsDatasource _trips;
  final UsersDatasource _users;

  static BookingDetails? _lookupMock(String bookingId) {
    final matches = mockBookingDetailsRaw.where((e) => e['id'] == bookingId);
    return matches.isEmpty ? null : BookingDetails.fromJson(matches.first);
  }

  /// Best-effort remote load. Returns true when the Firestore doc replaced
  /// the details; false keeps the mock baseline — callers must surface
  /// this, never present mocks as live data.
  Future<bool> loadRemote() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final doc = await _bookings.getById(_bookingId);
      if (doc == null) {
        emit(state.copyWith(isLoading: false));
        return false;
      }
      var guestName = '';
      var avatarUrl = '';
      var country = '';
      try {
        final user = await _users.getById(doc.touristId);
        guestName = user?.fullName ?? '';
        avatarUrl = user?.avatarUrl ?? '';
      } catch (_) {}
      var tourTitle = '';
      var location = '';
      if (doc.tripId != null && doc.tripId!.isNotEmpty) {
        try {
          final trip = await _trips.getById(doc.tripId!);
          tourTitle = trip?.title ?? '';
          location = trip?.location ?? '';
        } catch (_) {}
      }
      emit(state.copyWith(
        details: FirestoreMappers.bookingDocToBookingDetails(
          doc,
          guestName: guestName,
          avatarUrl: avatarUrl,
          country: country,
          tourTitle: tourTitle,
          location: location,
        ),
        isLoading: false,
      ));
      return true;
    } catch (e) {
      debugPrint('Triply: BookingDetailsCubit.loadRemote failed: $e');
      emit(state.copyWith(
        isLoading: false,
        error: FirestoreQueryHelper.friendlyError(e),
      ));
      return false;
    }
  }
}
