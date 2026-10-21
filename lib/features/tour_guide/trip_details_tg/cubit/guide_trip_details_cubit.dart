import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';

import '../../../../core/data/repositories/guide_trips_repository.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../model/guide_trip_details.dart';

part 'guide_trip_details_state.dart';

/// Owns guide trip details loading + tab selection.
///
/// The details come from Firestore through [GuideTripsRepository], with
/// the mock dataset as fallback.
class GuideTripDetailsCubit extends Cubit<GuideTripDetailsState>
    with SafeEmitMixin<GuideTripDetailsState> {
  GuideTripDetailsCubit({GuideTripsRepository? repository})
    : _repository = repository ?? GuideTripsRepository(),
      super(const GuideTripDetailsInitial());

  final GuideTripsRepository _repository;

  /// The tab the details are showing.
  int _selectedTab = 0;

  /// Loads the details of [trip].
  Future<void> loadTrip(GuideTrip trip) async {
    safeEmit(const GuideTripDetailsLoading());
    try {
      final details = await _repository.fetchDetails(trip.id);
      if (details == null) {
        safeEmit(const GuideTripDetailsError(error: 'Trip not found.'));
        return;
      }
      safeEmit(
        GuideTripDetailsSuccess(details: details, selectedTab: _selectedTab),
      );
    } catch (e) {
      safeEmit(GuideTripDetailsError(error: e.toString()));
    }
  }

  /// Switches the details tab. No reload — the details are already in.
  void selectTab(int index) {
    _selectedTab = index;
    final current = state;
    if (current is GuideTripDetailsSuccess) {
      safeEmit(
        GuideTripDetailsSuccess(details: current.details, selectedTab: index),
      );
    }
  }
}
