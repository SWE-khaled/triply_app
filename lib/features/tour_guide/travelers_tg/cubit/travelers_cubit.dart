import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';

import '../../../../core/data/repositories/guide_dashboard_repository.dart';
import '../model/traveler.dart';

part 'travelers_state.dart';

/// The travelers booked on one guide trip.
///
/// Reads the bookings of the trip from Firestore, with the mock dataset
/// as fallback.
class TravelersCubit extends Cubit<TravelersState>
    with SafeEmitMixin<TravelersState> {
  TravelersCubit({GuideDashboardRepository? repository})
    : _repository = repository ?? GuideDashboardRepository(),
      super(const TravelersInitial());

  final GuideDashboardRepository _repository;

  /// Loads the travelers of [tripId].
  Future<void> loadTrip(String tripId) async {
    safeEmit(const TravelersLoading());
    try {
      final travelers = await _repository.fetchTravelers(tripId);
      safeEmit(TravelersSuccess(travelers: travelers));
    } catch (e) {
      safeEmit(TravelersError(error: e.toString()));
    }
  }
}
