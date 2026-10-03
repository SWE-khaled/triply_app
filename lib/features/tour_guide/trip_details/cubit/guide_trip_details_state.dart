import '../model/guide_trip_details.dart';

class GuideTripDetailsState {
  final GuideTripDetails? details;
  final int selectedTab;

  const GuideTripDetailsState({
    required this.details,
    required this.selectedTab,
  });

  GuideTripDetailsState copyWith({
    GuideTripDetails? details,
    int? selectedTab,
  }) {
    return GuideTripDetailsState(
      details: details ?? this.details,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
