import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_trips_repository.dart';
import '../model/trip_row_data.dart';

part 'trips_state.dart';

/// Owns the Trips tab: the live trip list, the search query and the
/// reject action.
class TripsCubit extends Cubit<TripsState> {
  TripsCubit({AdminTripsRepository? repository})
    : _repository = repository ?? AdminTripsRepository(),
      super(const TripsInitial());

  final AdminTripsRepository _repository;

  StreamSubscription<List<AdminTrip>>? _subscription;
  List<TripRowData> _trips = const [];
  String _query = '';

  /// Subscribes to the trip stream. Calling it twice is a no-op.
  void start() {
    emit(const TripsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchTrips().listen(
      (trips) {
        _trips = trips.map(TripRowData.fromAdminTrip).toList();
        _emitSuccess();
      },
      onError: (_) {
        if (!isClosed) emit(const TripsError('Could not load trips.'));
      },
    );
  }

  /// Applies the search box content to the loaded list.
  void search(String query) {
    _query = query;
    final current = state;
    if (current is TripsSuccess) {
      emit(current.copyWith(query: query));
    }
  }

  /// Rejects a trip and sends the reason back to the guide.
  Future<bool> reject(TripRowData trip, String reason) async {
    final current = state;
    if (current is! TripsSuccess || trip.tripId.isEmpty) return false;

    final optimistic = current.copyWith(
      trips: [
        for (final item in current.trips)
          if (item.tripId == trip.tripId)
            item.copyWith(status: 'rejected', rejectionReason: reason)
          else
            item,
      ],
      busy: true,
    );
    emit(optimistic);

    final ok = await _repository.decide(
      tripId: trip.tripId,
      approve: false,
      rejectionReason: reason,
    );
    if (isClosed) return ok;

    if (ok) {
      emit(optimistic.copyWith(busy: false));
    } else {
      emit(current.copyWith(busy: false));
    }
    return ok;
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(TripsSuccess(trips: List.unmodifiable(_trips), query: _query));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
