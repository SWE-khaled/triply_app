import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/data/firestore/datasources/bookings_datasource.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/users_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import '../../../../core/data/mock/tourguide/mock_travelers.dart';
import '../model/traveler.dart';
import 'travelers_state.dart';

/// Traveler list for one guide trip: Firestore `bookings` for the trip
/// first (names enriched from `users`), mock fallback filtered by tripId.
class TravelersCubit extends Cubit<TravelersState> {
  TravelersCubit({
    BookingsDatasource? bookings,
    UsersDatasource? users,
  })  : _bookings = bookings ?? BookingsDatasource(),
        _users = users ?? UsersDatasource(),
        super(const TravelersState(travelers: []));

  final BookingsDatasource _bookings;
  final UsersDatasource _users;

  /// Legacy sync baseline (mock rows for [tripId]).
  void loadTrip(String tripId) {
    emit(
      TravelersState(
        travelers: mockTravelersJson
            .map((e) => Traveler.fromJson(e))
            .where((t) => t.tripId == tripId)
            .toList(),
      ),
    );
  }

  /// Best-effort remote load. Returns true when Firestore bookings
  /// replaced the list; false keeps the mock baseline — callers must
  /// surface this, never present mocks as live data.
  Future<bool> loadRemote(String tripId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final docs = await _bookings.listByTrip(tripId);
      final active =
          docs.where((d) => d.status != 'cancelled').toList();
      if (active.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return false;
      }
      final travelers = <Traveler>[];
      for (final d in active) {
        var name = '';
        var avatarUrl = '';
        try {
          final user = await _users.getById(d.touristId);
          name = user?.fullName ?? '';
          avatarUrl = user?.avatarUrl ?? '';
        } catch (_) {}
        travelers.add(FirestoreMappers.bookingDocToTraveler(
          d,
          name: name,
          avatarUrl: avatarUrl,
        ));
      }
      emit(state.copyWith(travelers: travelers, isLoading: false));
      return true;
    } catch (e) {
      debugPrint('Triply: TravelersCubit.loadRemote failed: $e');
      emit(state.copyWith(
        isLoading: false,
        error: FirestoreQueryHelper.friendlyError(e),
      ));
      return false;
    }
  }
}
