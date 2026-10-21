import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';

import '../../../../core/data/repositories/guide_trips_repository.dart';
import '../model/guide_trip.dart';

part 'guide_trips_state.dart';

/// Guide-side trip management. Owns the status filter.
///
/// The trips come live from [GuideTripsRepository]: Firestore when the
/// guide is signed in, the mock dataset as fallback. The list updates by
/// itself, so a trip created or edited anywhere shows up without a
/// manual reload.
class GuideTripsCubit extends Cubit<GuideTripsState>
    with SafeEmitMixin<GuideTripsState> {
  GuideTripsCubit({
    GuideTripStatus initialStatus = GuideTripStatus.active,
    GuideTripsRepository? repository,
  }) : _repository = repository ?? GuideTripsRepository(),
       super(const GuideTripsInitial()) {
    _selectedStatus = initialStatus;
    _subscription = _repository.watchTrips().listen(
      _onTrips,
      onError: (Object error) =>
          safeEmit(GuideTripsError(error: error.toString())),
    );
    safeEmit(const GuideTripsLoading());
  }

  final GuideTripsRepository _repository;
  StreamSubscription<List<GuideTrip>>? _subscription;

  /// Every trip the guide owns, whatever its status.
  List<GuideTrip> _all = const [];

  /// The tab the list is filtered by.
  GuideTripStatus _selectedStatus = GuideTripStatus.active;

  /// Whether the first batch of trips already arrived.
  bool _loaded = false;

  void _onTrips(List<GuideTrip> trips) {
    _all = trips;
    _loaded = true;
    safeEmit(
      GuideTripsSuccess(
        selectedStatus: _selectedStatus,
        trips: _filter(_selectedStatus),
      ),
    );
  }

  /// Re-reads the trips (call after returning from Create Trip).
  void refresh() {
    if (!_loaded) return;
    safeEmit(
      GuideTripsSuccess(
        selectedStatus: _selectedStatus,
        trips: _filter(_selectedStatus),
      ),
    );
  }

  List<GuideTrip> _filter(GuideTripStatus status) =>
      _all.where((t) => t.status == status).toList();

  static String label(GuideTripStatus status) {
    switch (status) {
      case GuideTripStatus.active:
        return 'Active';
      case GuideTripStatus.pending:
        return 'Pending';
      case GuideTripStatus.rejected:
        return 'Rejected';
      case GuideTripStatus.completed:
        return 'Completed';
      case GuideTripStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Switches the status tab. No reload — the trips are already loaded.
  void selectStatus(GuideTripStatus status) {
    _selectedStatus = status;
    if (!_loaded) return;
    safeEmit(GuideTripsSuccess(selectedStatus: status, trips: _filter(status)));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
