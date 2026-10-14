import '../model/guide_trip.dart';

class GuideTripsState {
  final GuideTripStatus selectedStatus;
  final List<GuideTrip> trips;
  final bool isLoading;

  const GuideTripsState({
    required this.selectedStatus,
    required this.trips,
    this.isLoading = false,
  });

  GuideTripsState copyWith({
    GuideTripStatus? selectedStatus,
    List<GuideTrip>? trips,
    bool? isLoading,
  }) {
    return GuideTripsState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
