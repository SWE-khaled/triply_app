import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../models/trip.dart';
import 'trips_state.dart';

/// Owns the public trip list and its session-retained tab selection.
class TripsCubit extends Cubit<TripsState> with SafeEmitMixin<TripsState> {
  TripsCubit({PublicTripsRepository? repository})
    : _repository = repository ?? PublicTripsRepository(),
      super(const TripsInitial(selectedTab: TripStatus.upcoming)) {
    load();
  }

  final PublicTripsRepository _repository;

  List<Trip> _allTrips = const [];
  TripStatus _selectedTab = TripStatus.upcoming;
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasLoaded = false;

  /// Same session guard as before: one read per app session; a retry after an
  /// error keeps the error view until the request resolves.
  Future<void> load() async {
    if (_isLoading || _hasLoaded) return;
    _isLoading = true;
    if (state is TripsInitial) {
      safeEmit(TripsLoading(selectedTab: _selectedTab));
    }
    try {
      final publicTrips = await _repository.fetchApprovedTrips(
        rethrowOnError: true,
      );
      if (isClosed) return;
      _allTrips = (publicTrips ?? const []).map(Trip.fromPublicTrip).toList();
      _hasLoaded = true;
      _errorMessage = null;
      safeEmit(
        TripsSuccess(
          selectedTab: _selectedTab,
          trips: _filter(_selectedTab),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      _errorMessage = pageLoadErrorMessage(error);
      safeEmit(
        TripsError(selectedTab: _selectedTab, message: _errorMessage!),
      );
    } finally {
      _isLoading = false;
    }
  }

  void selectTab(TripStatus status) {
    if (status == _selectedTab) return;
    _selectedTab = status;
    if (_hasLoaded) {
      safeEmit(
        TripsSuccess(selectedTab: status, trips: _filter(status)),
      );
      return;
    }
    final message = _errorMessage;
    if (message != null) {
      safeEmit(TripsError(selectedTab: status, message: message));
    } else {
      safeEmit(TripsInitial(selectedTab: status));
    }
  }

  List<Trip> _filter(TripStatus status) =>
      _allTrips.where((trip) => trip.status == status).toList();
}
