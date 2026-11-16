import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/page_load_error.dart';
import '../models/trip.dart';
import 'trips_state.dart';

/// Owns the public trip list and its session-retained tab selection.
class TripsCubit extends Cubit<TripsState> {
  TripsCubit({PublicTripsRepository? repository})
    : _repository = repository ?? PublicTripsRepository(),
      super(
        const TripsState(
          selectedTab: TripStatus.upcoming,
          trips: [],
          isLoading: true,
        ),
      ) {
    load();
  }

  final PublicTripsRepository _repository;

  List<Trip> _allTrips = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;

  Future<void> load() async {
    if (_isLoading || _hasLoaded) return;
    _isLoading = true;
    try {
      final publicTrips = await _repository.fetchApprovedTrips(
        rethrowOnError: true,
      );
      if (isClosed) return;
      _allTrips = (publicTrips ?? const []).map(Trip.fromPublicTrip).toList();
      _hasLoaded = true;
      emit(
        state.copyWith(
          trips: _filter(state.selectedTab),
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(isLoading: false, error: pageLoadErrorMessage(error)),
      );
    } finally {
      _isLoading = false;
    }
  }

  void selectTab(TripStatus status) {
    if (status == state.selectedTab) return;
    emit(
      state.copyWith(
        selectedTab: status,
        trips: _hasLoaded ? _filter(status) : state.trips,
      ),
    );
  }

  List<Trip> _filter(TripStatus status) =>
      _allTrips.where((trip) => trip.status == status).toList();
}
