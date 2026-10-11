import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import '../../../../core/data/mock/tourist/mock_trips_public.dart';
import '../models/trip.dart';
import 'trips_state.dart';

/// Owns the tab filter + trip list. Firestore-approved trips are primary;
/// the mock list is the explicit offline baseline (kept on failure/empty
/// with a visible notice in the View, never presented as live data).
///
/// Firestore `approvalStatus` has no tourist `completed` state: approved
/// trips map to `upcoming`, so the Completed tab honestly shows its empty
/// state until completion tracking exists. `cancelled` maps through.
///
/// Kill-switch: [useRemote] gates every remote call in the View. Phase 1
/// (trips feed) is activated; flipping back to `false` is instant rollback.
class TripsCubit extends Cubit<TripsState> {
  static const bool useRemote = true;

  final TripsRepository _repository;

  /// Last successful remote fetch (full list, all statuses). Null until the
  /// first success — tabs filter this instead of mocks once present.
  List<Trip>? _remoteTrips;
  TripsCubit([TripsRepository? repository])
    : _repository = repository ?? TripsRepository(),
      super(
        TripsState(
          selectedTab: TripStatus.upcoming,
          trips: _filter(TripStatus.upcoming),
        ),
      );

  static List<Trip> _all() =>
      mockTripsJson.map((e) => Trip.fromJson(e)).toList();

  static List<Trip> _filter(TripStatus status) =>
      _all().where((t) => t.status == status).toList();

  void selectTab(TripStatus status) {
    final base = _remoteTrips ?? _all();
    emit(
      state.copyWith(
        selectedTab: status,
        trips: base.where((t) => t.status == status).toList(),
      ),
    );
  }

  /// Remote refresh. On success the full approved list is cached and the
  /// current tab is re-filtered from it — returns true even when the current
  /// tab filters to empty (fetch succeeded; the empty state is honest, not
  /// a failure). On failure/empty the previous list is kept and false is
  /// returned — callers must surface this (e.g. offline notice), never
  /// present kept data as a successful Firestore read.
  Future<bool> loadRemote() async {
    try {
      final result = await _repository.approvedTrips();
      if (result is FirestoreOk<List<Trip>> && result.data.isNotEmpty) {
        _remoteTrips = result.data;
        emit(
          state.copyWith(
            trips: result.data
                .where((t) => t.status == state.selectedTab)
                .toList(),
          ),
        );
        return true;
      }
    } catch (e) {
      debugPrint('Triply: TripsCubit.loadRemote failed: $e');
      return false;
    }
    debugPrint('Triply: TripsCubit.loadRemote kept previous list.');
    return false;
  }
}
