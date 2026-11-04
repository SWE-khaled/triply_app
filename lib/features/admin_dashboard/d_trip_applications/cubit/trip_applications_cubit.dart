import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_trips_repository.dart';
import '../model/admin_trip_application.dart';

part 'trip_applications_state.dart';

/// Owns the Trip Applications tab: the live applications, the search query
/// and the approve / reject decisions.
class TripApplicationsCubit extends Cubit<TripApplicationsState> {
  TripApplicationsCubit({AdminTripsRepository? repository})
    : _repository = repository ?? AdminTripsRepository(),
      super(const TripApplicationsInitial());

  final AdminTripsRepository _repository;

  StreamSubscription<List<AdminTrip>>? _subscription;
  List<AdminTripApplication> _applications = const [];
  String _query = '';

  /// Subscribes to the trips stream. Calling it twice is a no-op.
  void start() {
    emit(const TripApplicationsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchTrips().listen(
      (trips) {
        _applications = trips.map(AdminTripApplication.fromAdminTrip).toList();
        _emitSuccess();
      },
      onError: (_) {
        if (!isClosed) {
          emit(
            const TripApplicationsError('Could not load trip applications.'),
          );
        }
      },
    );
  }

  /// Applies the search box content to the loaded list.
  void search(String query) {
    _query = query;
    final current = state;
    if (current is TripApplicationsSuccess) {
      emit(current.copyWith(query: query));
    }
  }

  /// Approves an application and tells the guide.
  Future<bool> approve(AdminTripApplication application) {
    return _decide(application, approve: true);
  }

  /// Rejects an application with a reason and tells the guide.
  Future<bool> reject(AdminTripApplication application, String reason) {
    return _decide(application, approve: false, rejectionReason: reason);
  }

  Future<bool> _decide(
    AdminTripApplication application, {
    required bool approve,
    String rejectionReason = '',
  }) async {
    final current = state;
    if (current is! TripApplicationsSuccess) return false;

    final nextStatus = approve ? 'approved' : 'rejected';
    final optimistic = current.copyWith(
      applications: [
        for (final item in current.applications)
          if (item.tripId == application.tripId)
            item.copyWith(
              status: nextStatus,
              rejectionReason: approve ? '' : rejectionReason,
            )
          else
            item,
      ],
      busy: true,
    );
    emit(optimistic);

    if (application.tripId.isEmpty) {
      emit(optimistic.copyWith(busy: false));
      return true;
    }

    final ok = await _repository.decide(
      tripId: application.tripId,
      approve: approve,
      rejectionReason: rejectionReason,
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
    emit(
      TripApplicationsSuccess(
        applications: List.unmodifiable(_applications),
        query: _query,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
