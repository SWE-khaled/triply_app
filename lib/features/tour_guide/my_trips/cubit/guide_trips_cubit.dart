import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/guide_trips_store.dart';
import '../../../../data/mock/mock_guide_trips.dart';
import '../model/guide_trip.dart';
import 'guide_trips_state.dart';

/// Guide-side trip management (mock -> Model). Owns status filter.
class GuideTripsCubit extends Cubit<GuideTripsState> {
  GuideTripsCubit()
    : super(
        GuideTripsState(
          selectedStatus: GuideTripStatus.active,
          trips: _filter(GuideTripStatus.active),
        ),
      );

  static List<GuideTrip> _all() => GuideTripsStore.applyUpdates([
    ...GuideTripsStore.created,
    ...mockGuideTripsJson.map((e) => GuideTrip.fromJson(e)),
  ]);

  /// Re-reads the store (call after returning from Create Trip).
  void refresh() {
    emit(state.copyWith(trips: _filter(state.selectedStatus)));
  }

  static List<GuideTrip> _filter(GuideTripStatus status) =>
      _all().where((t) => t.status == status).toList();

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

  void selectStatus(GuideTripStatus status) {
    emit(state.copyWith(selectedStatus: status, trips: _filter(status)));
  }
}
