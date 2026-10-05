import '../model/guide_trip.dart';

class GuideTripsState {
  final GuideTripStatus selectedStatus;
  final List<GuideTrip> trips;

  const GuideTripsState({required this.selectedStatus, required this.trips});

  GuideTripsState copyWith({
    GuideTripStatus? selectedStatus,
    List<GuideTrip>? trips,
  }) {
    return GuideTripsState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
      trips: trips ?? this.trips,
    );
  }
}
